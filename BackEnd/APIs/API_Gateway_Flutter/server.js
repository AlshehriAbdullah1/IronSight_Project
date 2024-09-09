const express = require("express");
const cors = require("cors");
const request = require("request");
const axios = require("axios");
const app = express();
app.use(express.json());
app.use(cors());
var jwt = require("jsonwebtoken");
const qs = require("qs");
const FormData = require("form-data");
const fs = require("fs");
const multer = require("multer");
require("dotenv").config({ path: "../../.env" });

// Set up multer for file uploads
const upload = multer({ dest: "uploads/" });

const port = process.env.API_FLUTTER_PORT || 3001;
// Microservices PORTS
const TournamentMicro = process.env.TOURNAMENT_HOST;
const UserMicro = process.env.USER_HOST;
const GameMicro = process.env.GAME_HOST;
const CommunityMicro = process.env.COMMUNITY_HOST;
//const ChatMicro = process.env.CHAT_HOST;
const SearchMicro = process.env.SEARCH_HOST;

/////////////////////////////////////////////////
// Endpoint for uploading images
/////////////////////////////////////////////////

// Endpoint to store image/s in the media service
/*
  General Description: This endpoint is used to store images in the media service in 3 scenarios:
  1. collection - single
  2. collection - multiple
  3. sub-collection - multiple

  from_micro: User - Community - Game - Tournament
  collection: Users - Community - Games - Tournaments - Posts
  sub_collection: Replies

  Endpoint: /upload
  ex. /upload

  1. collection - single
  Description: This scenario is used to store a single image to a collection.
  Request:
  body:
  {
    file: image file,
    image_name: "image_name",
    from_micro: "microservice_name",
    id: "id",
    collection: "collection_name"
  }
  response:
  the collection document object

  2. collection - multiple
  Description: This scenario is used to store multiple images to a collection.
  Request:
  body:
  {
    file: image file,
    image_name: "image_name",
    from_micro: "microservice_name",
    id: "id",
    collection: "collection_name",
    map_key: "map_key_name"
  }
  response:
  the collection document object

  3. sub-collection - multiple
  Description: This scenario is used to store multiple images to a sub-collection.
  Request:
  body:
  {
    file: image file,
    image_name: "image_name",
    from_micro: "microservice_name",
    collection: "collection_name",
    id: "id",
    sub_collection: "sub_collection_name",  
    sub_id: "sub_id",
    map_key: "map_key_name"
  }
  response:
  the collection document object

*/
app.post("/upload", upload.single("file"), (req, res) => {
  const formData = new FormData();
  // check the file image type to be one of the following types, otherwise return an error
  if (
    req.file.mimetype !== "image/jpeg" &&
    req.file.mimetype !== "image/png" &&
    req.file.mimetype !== "image/jpg" &&
    req.file.mimetype !== "image/gif" &&
    req.file.mimetype !== "image/webp" &&
    req.file.mimetype !== "image/svg+xml"
  ) {
    return res.status(400).send("Invalid image type");
  }
  // Append the file, image_name, from_micro, and id to formData
  formData.append(
    "file",
    fs.createReadStream(req.file.path),
    req.file.originalname
  );
  formData.append("image_name", req.body.image_name);
  formData.append("from_micro", req.body.from_micro);
  formData.append("id", req.body.id);
  formData.append("collection", req.body.collection);
  //formData.append("sub_collection", req.body.sub_collection);

  let forwardMicro = "";
  // check if the req.body has the map_key field
  if (!req.body.map_key) {
    // Switch to the from_micro service
    switch (req.body.from_micro) {
      case "Game":
        forwardMicro = GameMicro + "/gamesM/upload";
        break;
      case "Community":
        forwardMicro = CommunityMicro + "/communitiesM/upload";
        break;
      case "User":
        forwardMicro = UserMicro + "/usersM/upload";
        break;
      case "Tournament":
        forwardMicro = TournamentMicro + "/tournamentsM/upload";
        break;
      default:
        res.status(500).send("Invalid from_micro");
    }
  } else {
    formData.append("map_key", req.body.map_key);
    if (req.body.sub_collection) {
      formData.append("sub_collection", req.body.sub_collection);
      formData.append("sub_id", req.body.sub_id);
    }
    // Switch to the from_micro service
    switch (req.body.from_micro) {
      case "Community":
        forwardMicro = CommunityMicro + "/communitiesM/uploads";
        break;
      default:
        res.status(500).send("Invalid from_micro");
    }
  }
  // Send the file to the appropriate microservice
  axios
    .post(forwardMicro, formData, {
      headers: formData.getHeaders(),
    })
    .then((response) => {
      fs.unlink(req.file.path, (err) => {
        if (err) {
          console.error("Error deleting file:", err);
        }
        console.log(
          "return from " +
            req.body.from_micro +
            " microservice, uploading image"
        );
      });
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

/////////////////////////////////////////////////
// Endpoint for Tournament Microservice
/////////////////////////////////////////////////

// Endpoint for creating a new tournament
/**
  Description: This endpoint is used to create a new tournament in the database.
                After creating the tournament, the tournament will be added to the user's organized tournaments.
  
  Endpoint: 
  @api /tournaments
  ex. /tournaments
  
  Request:
  body:
  IMPORTANT: These are the required fields to create a tournament
  {
    "Tournament_Name": "Overwatch 2 Saudi tournament",
    "Tournament_Org": "BQEEuiEotoYX2gyYrtaNIUmk6FU2",
    "Game_Name": "Overwatch 2",
    "Type": "Online",
    "Date": "5/1/2024",
    "Time": "12:00",
    "Max_Participants": "8"
  }

  Response:
  {
    "Registration_Link": "",
    "Description": "This tournament has no description",
    "Matches": {
        "Active": [],
        "Ended": []
    },
    "Streaming_Link": "",
    "Participants": [],
    "In_House": false,
    "Date_Time": {
        "_seconds": 1714554000,
        "_nanoseconds": 0
    },
    "Type": "Online",
    "Prize_Pool": "0 SAR",
    "Results": "Pending",
    "Game_Name": "Overwatch 2",
    "Tournament_Name": "Overwatch 2 Saudi tournament",
    "Tournament_Org": {
        "_firestore": {
            "projectId": "tour-firebase-ebd9d"
        },
        "_path": {
            "segments": [
                "Users",
                "BQEEuiEotoYX2gyYrtaNIUmk6FU2"
            ]
        },
        "_converter": {}
    },
    "Location": "Online",
    "Max_Participants": 8,
    "Date_Created": {
        "_seconds": 1714349610,
        "_nanoseconds": 918000000
    },
    "Tour_Id": "MNkPJ6CoheSo19GImACZ"
  }
 */
app.post("/tournaments", (req, res) => {
  try {
    axios
      .post(TournamentMicro + "/tournamentsM", req.body)
      .then((response) => {
        // After creating the tournament, add the tournament to the user's organized tournaments
        return axios
          .post(UserMicro + "/usersM/addParticipatedTournaments", {
            User_Id: req.body.Tournament_Org,
            Tour_Id: response.data.Tour_Id,
            Tour_Type: "organized",
          })
          .then(() => {
            console.log(
              "return from Tournament microservice, creating tournament"
            );
            res.status(200).send(response.data);
          })
          .catch((error) => {
            console.log(error);
            res
              .status(500)
              .send(error.message + " Error in creating tournament");
          });
      })
      .catch((error) => {
        console.log(error);
        res.status(500);
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in creating tournament`);
  }
});

// Endpoint for getting tournaments with the same game name
/**
  Description: This endpoint is used to get tournaments with the same game name from the database.

  Endpoint:
  @api /tournaments/game/:gameName
  ex. /tournaments/game/Overwatch2
  
  Request:
  params: gameName
  
  Response:
  return list of tournaments with the same game name
*/
app.get("/tournaments/game/:gameName", (req, res) => {
  const gameName = req.params.gameName;
  try {
    axios.get(TournamentMicro + "/tournamentsM/game/" + gameName)
      .then((response) => {
        console.log(
          "return from Tournament microservice, getting tournaments with the same game name"
        );
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(
            error.message + " Error in getting tournaments with the same game name"
          );
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting tournaments with the same game name`);
  }
});


// Endpoint for getting specific/all tournaments
/**
  Description: This endpoint is used to get specific/all tournaments from the database.

  Endpoint:
  @api /tournaments
  ex. /tournaments
  
  Request:
  query: if you want to get a specific tournament, you can use the query parameter and provide the Tour_Id
  if you want to get all tournaments, you can send an empty query
  
  Response:
  return list of tournaments from the database
  
*/
app.get("/tournaments", (req, res) => {
  try {
    axios
      .get(TournamentMicro + "/tournamentsM/", { params: req.query })
      .then((response) => {
        console.log("return from Tournament microservice, getting tournaments");
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(error.message + " Error in getting tournaments");
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting tournaments`);
  }
});

// Endpoint for deleting a tournament
/**
  Description: This endpoint is used to delete a tournament from the database using the given tournament id.

  Endpoint:
  @api /tournaments/:Tour_Id
  ex. /tournaments/eybanhD9AgkVxgBWzvIC

  Request:
  params: Tour_Id

  Response:
  return "Success"
*/
app.delete("/tournaments/:Tour_Id", (req, res) => {
  try {
    const Tour_Id = req.params.Tour_Id;
    axios
      .delete(TournamentMicro + "/tournamentsM/" + Tour_Id)
      .then((response) => {
        console.log("return from Tournament microservice, deleting tournament");
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(error.message + " Error in deleting tournament");
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in deleting tournament`);
  }
});

// Endpoint for match winner update
app.put("/tournaments/:Tour_Id/matchWin/:Winner_Id", (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  const Winner_Id = req.params.Winner_Id;
  console.log("winning the winner : " + Tour_Id + " " + Winner_Id)
  axios
    .put(TournamentMicro + "/tournamentsM/matchWin", { Tour_Id, Winner_Id })
    .then((response) => {
      console.log("Success in updating tournament matches");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in updating tournament");
    });
});

// Endpoint to get tournament matches
/**
  Description: This endpoint is used to get the matches of a specific tournament.
  
  Endpoint:
  @api /tournaments/:Tour_Id/matches
  ex. /tournaments/eybanhD9AgkVxgBWzvIC/matches

  Request:
  params: Tour_Id
  
  Response:
  return the list of matches in the tournament

*/
app.get("/tournaments/:Tour_Id/matches", (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  try {
    axios
      .get(TournamentMicro + "/tournamentsM/" + Tour_Id + "/matches")
      .then((response) => {
        console.log("return from Tournament microservice, getting matches");
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(error.message + " Error in getting matches");
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting matches`);
  }
});


// Endpoint for editing tournament information
/**
  Description: This endpoint is used to edit tournament information in the database using the given tournament id.

  Endpoint:
  @api /tournaments/:Tour_Id
  ex. /tournaments/eybanhD9AgkVxgBWzvIC

  Request:
  params: Tour_Id
  body:
  the fields that you want to edit
  {
    "Tournament_Name": "Editied Tournament Name"
  }

  Response:
  return the updated tournament information
  {
    "Registration_Link": "overwatch.com",
    "Description": "Tournament to establish the best Overwatch player",
    "Streaming_Link": "Twitter.com",
    "In_House": true,
    "Date_Time": {
        "_seconds": 1749747600,
        "_nanoseconds": 0
    },
    "Type": "On Premise",
    "Prize_Pool": "3000 SAR",
    "Results": "Pending",
    "Game_Name": "Overwatch2",
    "Tournament_Org": "P13",
    "Location": "Saudi Arabia, Riadyh",
    "Max_Participants": 4,
    "Date_Created": {
        "_seconds": 1708269960,
        "_nanoseconds": 180000000
    },
    "Participants": [
        {
            "Participant_Id": "p1",
            "Record": {
                "Losses": 0,
                "Wins": 2
            },
            "Participant_Name": "Ali"
        },
        {
            "Participant_Id": "p2",
            "Record": {
                "Losses": 2,
                "Wins": 0
            },
            "Participant_Name": "Turki"
        }
    ],
    "Matches": {
        "Active": [
            {
                "Player2": {
                    "Status": "Pending",
                    "Id": "",
                    "Name": ""
                },
                "Player1": {
                    "Status": "Pending",
                    "Id": "p1",
                    "Name": "Ali"
                }
            }
        ],
        "Ended": [
            {
                "Player2": {
                    "Status": "Loser",
                    "Id": "p2",
                    "Name": "Turki"
                },
                "Player1": {
                    "Status": "Winner",
                    "Id": "p1",
                    "Name": "Ali"
                }
            },
            {
                "Player2": {
                    "Status": "Loser",
                    "Id": "p2",
                    "Name": ""
                },
                "Player1": {
                    "Status": "Winner",
                    "Id": "p1",
                    "Name": "Ali"
                }
            }
        ]
    },
    "Tournament_Name": "Editing",
    "Tour_Id": "f8ojvGB3Y3yLx6e8ug5e"
}
*/
app.put("/tournaments/:Tour_Id", (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  axios
    .put(TournamentMicro + "/tournamentsM/" + Tour_Id, req.body)
    .then((response) => {
      console.log("return from Tournament microservice, updating tournament");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in updating tournament");
    });
});

// Endpoint for removing/unregistering a participant from a tournament
/**
  Description: This endpoint is used to remove/unregister a participant from a tournament.
  The participant will be removed from the tournament's participants list.
  The tournament will be removed from the user's participated tournaments list.

  Endpoint:
  @api /tournaments/:Tour_Id/removeParticipant
  ex. /tournaments/MNkPJ6CoheSo19GImACZ/removeParticipant

  Request:
  params: Tour_Id
  query:
  {
    "Participant_Id":"HsryFLUJ71VyeVy4QpS3S1vt9CL2"
  }

  Response:
  return the updated list of participants in the tournament
  [
    {
        "Participant_Id": "CefzN51SirQ8eja1ov9FvY65RvS2",
        "Record": {
            "Losses": 0,
            "Wins": 0
        },
        "Participant_Name": "@aprilx4@mail.com"
    },
    {
        "Participant_Id": "GeFKvyqUBgY9bq5piq8yJiipF783",
        "Record": {
            "Losses": 0,
            "Wins": 0
        },
        "Participant_Name": "@aprilx13@mail.com"
    }
]
*/
app.delete("/tournaments/:Tour_Id/removeParticipant", async (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  const Participant_Id = req.query.Participant_Id;
  const Tour_Type = req.query.Tour_Type;
  axios
    .delete(
      TournamentMicro +
        "/tournamentsM/" +
        Tour_Id +
        "/removeParticipant/" +
        Participant_Id
    )
    .then((response) => {
      // After removing the participant from the tournament,
      // Remove the tournament from the user's participated tournaments
      return axios
        .delete(
          UserMicro +
            "/usersM/" +
            Participant_Id +
            "/removeParticipatedTournaments",
          {
            params: {
              User_Id: Participant_Id,
              Tour_Id: Tour_Id,
              Tour_Type: Tour_Type,
            },
          }
        )
        .then(() => {
          console.log(
            "return from Tournament microservice, removing participant"
          );
          res.status(200).send(response.data);
        })
        .catch((error) => {
          console.log(error);
          res
            .status(500)
            .send(error.message + " Error in removing participant");
        });
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in removing participant");
    });
});

// Register a participant to a tournament
/**
  Description: This endpoint is used to register a participant to a tournament.
  The participant will be added to the tournament's participants list.
  The tournament will be added to the user's upcoming particpated tournaments list.
  
  Endpoint:
  @api /tournaments/:Tour_Id/registerParticipant
  ex. /tournaments/T1/registerParticipant

  Request:
  params: Tour_Id
  body:
  {
    Participant_Id: "otWWAMxB67cn0XyKp0aNAEloRBm2"
  }

  Response:
  return the updated list of participants in the tournament
[
    {
        "Participant_Id": "otWWAMxB67cn0XyKp0aNAEloRBm2",
        "Record": {
            "Losses": 0,
            "Wins": 0
        },
        "Participant_User_Name": "@apriluuser",
        "Participant_Profile": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2FotWWAMxB67cn0XyKp0aNAEloRBm2%2FProfile_Picture?generation=1714113679473351&alt=media",
        "Participant_Display_Name": "april name"
    },
    {
        "Participant_Id": "pFZibr4pVOhpIcytthCKsrx8uAl1",
        "Record": {
            "Losses": 0,
            "Wins": 0
        },
        "Participant_User_Name": "@aprilusername",
        "Participant_Profile": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2FpFZibr4pVOhpIcytthCKsrx8uAl1%2FProfile_Picture?generation=1713761301248438&alt=media",
        "Participant_Display_Name": "april name"
    }
]
  
*/
app.post("/tournaments/:Tour_Id/registerParticipant", async (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  const Participant_Id = req.body.Participant_Id;
  try {
    axios
      .post(TournamentMicro + "/tournamentsM/registerParticipant", {
        Tour_Id,
        Participant_Id,
      })
      .then((response) => {
        // After registering the participant to the tournament,
        // Add the tournament to the user's participated tournaments
        return axios
          .post(UserMicro + "/usersM/addParticipatedTournaments", {
            User_Id: Participant_Id,
            Tour_Id: Tour_Id,
            Tour_Type: "upcoming",
          })
          .then(() => {
            console.log(
              "return from Tournament microservice, registering participant"
            );
            res.status(200).send(response.data);
          })
          .catch((error) => {
            console.log(error);
            res

              .status(500)
              .send(error.message + " Error in registering participant");
          });
      })
      .catch((error) => {
        console.log(error);
        res
          .status(500)
          .send(error.message + " Error in registering participant");
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in registering participant`);
  }
});

// Endpoint for getting tournament participants
/**
  
  Description: This endpoint is used to get the participants of a specific tournament.
  
  Endpoint:
  @api /tournaments/:Tour_Id/participants
  ex. /tournaments/eybanhD9AgkVxgBWzvIC/participants
  
  Request:
  params: Tour_Id

  Response:
  return the list of participants in the tournament
[
    {
        "Participant_Id": "otWWAMxB67cn0XyKp0aNAEloRBm2",
        "Record": {
            "Losses": 0,
            "Wins": 0
        },
        "Participant_User_Name": "@apriluuser",
        "Participant_Profile": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2FotWWAMxB67cn0XyKp0aNAEloRBm2%2FProfile_Picture?generation=1714113679473351&alt=media",
        "Participant_Display_Name": "april name"
    },
    {
        "Participant_Id": "pFZibr4pVOhpIcytthCKsrx8uAl1",
        "Record": {
            "Losses": 0,
            "Wins": 0
        },
        "Participant_User_Name": "@aprilusername",
        "Participant_Profile": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Users%2FpFZibr4pVOhpIcytthCKsrx8uAl1%2FProfile_Picture?generation=1713761301248438&alt=media",
        "Participant_Display_Name": "april name"
    }
]
*/
app.get("/tournaments/:Tour_Id/participants", (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  try {
    axios
      .get(TournamentMicro + "/tournamentsM/" + Tour_Id + "/participants")
      .then((response) => {
        console.log(
          "return from Tournament microservice, getting participants"
        );
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(error.message + " Error in getting participants");
      });
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting participants`);
  }
});



// Endpoint for starting a tournament match
/*
  Description: This endpoint is used to foclibly start a tournament match.

  Endpoint:
  @api /tournaments/:Tour_Id/startTournament
  ex. /tournaments/eybanhD9AgkVxgBWzvIC/startTournament

  Request:
  params: Tour_Id

  Response:
  return "success"
*/
app.put("/tournaments/:Tour_Id/startTournament", (req, res) => {
  const Tour_Id = req.params.Tour_Id;
  axios
    .put(TournamentMicro + "/tournamentsM/" + Tour_Id + "/startTournament")
    .then((response) => {
      console.log("return from Tournament microservice, starting tournament");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in starting tournament");
    });
});

/////////////////////////////////////////////////
// Endpoint for User Microservice
/////////////////////////////////////////////////

// Endpoint for getting specific/all users
/*
  Description: This endpoint is used to get specific/all users from the database.

  Endpoint: /users
  ex. /users

  Request:
  query: if you want to get a specific user, you can use the query parameter
  {
    User_Id: "user_id",
  }

  Response:
  return list of users from the database
*/

app.get("/users", async (req, res) => {
  try {
    const response = await axios.get(UserMicro + "/usersM/", {
      params: req.query,
    });
    console.log("return from User microservice, getting users");
    res.status(200).send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting users`);
  }
});


// Endpoint for deleting a user
/*
  Description: This endpoint is used to delete a user from the database using the given user id.

  Endpoint: /users/:User_Id
  ex. /users/0jQ7hhSn3u8S8zOCugdS

  Request:
  params: User_Id

  Response:
  return "Success"
*/
app.delete("/users/:User_Id", async (req, res) => {
  const User_Id = req.params.User_Id;
  try {
    const response = await axios.delete(UserMicro + "/usersM/" + User_Id);
    console.log("return from User microservice, deleting user");
    res.status(200).send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).send(error.message + " Error in deleting user");
  }
});

// Endpoint for editing user information
/*
  Description: This endpoint is used to edit user information in the database using the given user id.

  Endpoint: /users/:User_Id
  ex. /users/0jQ7hhSn3u8S8zOCugdS

  Request:
  params: User_Id
  body:
  {
    Age: 20,
  }

  for complete user signup info:
  {
    User_Name: "@mockDataUser7",
    Display_Name: "MockData3",
    Bio: "This is mock bio"
  }

  Response:
  return the updated user information
  {
    "User_Name": "@mockDataUser7",
    "Email": "mockEmail7@mail.com",
    "Communities": [],
    "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
    "Banner": "",
    "Following": [],
    "Display_Name": "MockData3",
    "Bio": "This is mock bio",
    "Followers": [],
    "Role": "User",
    "Badges": [],
    "Mobile_Number": "+966543211234",
    "Tournaments": {
        "Upcoming": [],
        "Followed": [],
        "Previous": [],
        "Organized": [],
        "Current": []
    },
    "Preferences": [],
    "createdAt": {
        "_seconds": 1710023431,
        "_nanoseconds": 488000000
    },
    "Age": 55
  }
*/
app.put("/users/:User_Id", (req, res) => {
  const User_Id = req.params.User_Id;
  axios
    .put(UserMicro + "/usersM/" + User_Id, req.body)
    .then((response) => {
      console.log("return from User microservice, updating user");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in updating user");
    });
});

// Endpoint for getting user's participated tournaments
/** 
  Description: This endpoint is used to get user's participated tournaments from the database.
              If you want to get a specific type of tournament, you can use the query parameter.
              @param Tour_Type is used to identify the type of the tournament.
              If not provided, all participated tournaments will be returned.
  Endpoint: /users/:User_Id/participatedTournaments
  ex. /users/0jQ7hhSn3u8S8zOCugdS/participatedTournaments

  Request:
  params: User_Id
  query: if you want to get a specific type of tournament, you can use the query parameter
  {
    Tour_Type: "upcoming",
  }

  Response:
  return list of user's participated tournaments from the database (Response is too long for an example)
  
*/
app.get("/users/:User_Id/participatedTournaments", (req, res) => {
  const User_Id = req.params.User_Id;
  const Tour_Type = req.query.Tour_Type;
  let url = `${UserMicro}/usersM/${User_Id}/participatedTournaments`;
  if (Tour_Type) {
    url += `?Tour_Type=${Tour_Type}`;
  }
  axios
    .get(url)
    .then((response) => {
      console.log(
        "return from User microservice, getting user's participated tournaments : type is " +
          Tour_Type
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res
        .status(500)
        .send(
          error.message + " Error in getting user's participated tournaments"
        );
    });
});

// Add participated tournaments to the user
/** 

  Description: This endpoint is used to add participated tournaments to the user.
    The  @param {user id} is used to identify the user whose participated tournaments are to be updated.
    The  @param Tour_Id is used to identify which tournament is being added to the user.
    The  @param Tour_Type is used to identify the type of the tournament 
                (upcoming, previous, organized, current, followed).

  **@important NOTE: **
  If the @param Tour_Type is not provided, 
  the value will be determined based on the tournament status.
              
  Endpoint: 
  @api /users/:User_Id/addParticipatedTournaments
  ex. /users/gWi0CJnCNuUpjhpnRio48c9PnJh2/addParticipatedTournaments

  Request:
  params: User_Id
  body:
  {
    Tour_Id: "tour_id",
    Tour_Type: "upcoming"
  }

  Response:
  return list of user's participated tournaments in specific type after adding the new 
  [
    "0jQ7hhSn3u8S8zOCugdS",
    "0MWzjERANTDyjAlVBlDE"
  ]
              
*/
app.post("/users/:User_Id/addParticipatedTournaments", (req, res) => {
  const User_Id = req.params.User_Id;
  const { Tour_Id, Tour_Type } = req.body;
  axios
    .post(UserMicro + "/usersM/addParticipatedTournaments", {
      User_Id,
      Tour_Id,
      Tour_Type,
    })
    .then((response) => {
      console.log(
        "return from User microservice, adding user's participated tournaments"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res
        .status(500)
        .send(
          error.message + " Error in adding user's participated tournaments"
        );
    });
});

//Endpoint to remove participated tournaments from the user
/**
  Description: This endpoint is used to remove participated tournaments from the user.
  The @param {user id} is used to identify the user whose participated tournaments are to be updated.
  The @param Tour_Id is used to identify which tournament is being removed from the user.
  The @param Tour_Type is used to identify the type of the tournament
                (upcoming, previous, organized, current, followed).
  If the @param Tour_Type is not provided, the value will be determined based on the tournament status.
   
  Endpoint:
  @api /users/:User_Id/removeParticipatedTournaments
  ex. /users/gbZr8FIdS2I2rDwJW4Hx/removeParticipatedTournaments
  
  Request:
    params: User_Id
    query:
    {
    Tour_Id: "tour_id",
    Tour_Type: "upcoming"
    }
 Response:
  return list of user's participated tournaments in specific type after removing the new
  [
    "0jQ7hhSn3u8S8zOCugdS",
    "0MWzjERANTDyjAlVBlDE"
  ]
*/
app.delete("/users/:User_Id/removeParticipatedTournaments", (req, res) => {
  const User_Id = req.params.User_Id;
  const Tour_Id = req.query.Tour_Id;
  const Tour_Type = req.query.Tour_Type;
  axios
    .delete(
      UserMicro + "/usersM/" + User_Id + "/removeParticipatedTournaments",
      { params: { Tour_Id, Tour_Type } }
    )
    .then((response) => {
      console.log(
        "return from User microservice, removing user's participated tournaments"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res
        .status(500)
        .send(
          error.message + " Error in removing user's participated tournaments"
        );
    });
});

// Endpoint to add game preferences to the user
/*
  Description: This endpoint is used to add game preferences to the user.

  Endpoint: /users/:User_Id/addGamePreferences
  ex. /users/gbZr8FIdS2I2rDwJW4Hx/addGamePreferences

  Request:
  params: User_Id
  body: Game_Ids as a list
  {
    Game_Ids: ["game_id1", "game_id2"]
  }
  
  
  Response: 
  return the updated list of game preferences of the user
  [
    "0jQ7hhSn3u8S8zOCugdS",
    "0MWzjERANTDyjAlVBlDE"
  ]
*/
app.put("/users/:User_Id/addGamePreferences", (req, res) => {
  const User_Id = req.params.User_Id;
  // the game ids are sent in the body as list
  const Game_Ids = req.body.Game_Ids;
  axios
    .put(UserMicro + `/usersM/${User_Id}/addGamePreferences`, {
      Game_Ids: Game_Ids,
    })
    .then((response) => {
      console.log("return from user microservice, adding game preferences");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in adding game preferences");
    });
});

// Endpoint to remove game preferences from the user
/*
  Description: This endpoint is used to remove game preferences from the user.

  Endpoint: /users/:User_Id/removeGamePreferences
  ex. /users/gbZr8FIdS2I2rDwJW4Hx/removeGamePreferences

  Request:
  params: User_Id
  query:
  {
    Game_Id: "game_id"
  }

  Response:
  return the updated list of game preferences of the user
  [
    "0jQ7hhSn3u8S8zOCugdS",
    "0MWzjERANTDyjAlVBlDE"
  ]
*/

app.delete("/users/:User_Id/removeGamePreferences", (req, res) => {
  const User_Id = req.params.User_Id;
  const Game_Id = req.query.Game_Id;
  axios
    .delete(UserMicro + `/usersM/${User_Id}/removeGamePreferences`, {
      params: { Game_Id: Game_Id },
    })
    .then((response) => {
      console.log("return from user microservice, removing game preferences");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res
        .status(500)
        .send(error.message + " Error in removing game preferences");
    });
});

// Endpoint to get all game preferences of the user
/*
  Description: This endpoint is used to get all game preferences of the user.

  Endpoint: /users/:User_Id/gamePreferences
  ex. /users/gbZr8FIdS2I2rDwJW4Hx/gamePreferences

  Request:
  params: User_Id

  Response:
  return the list of game preferences of the user
     {
        "Game_Genre": [
            "Battle Royale",
            "FPS"
        ],
        "Game_Name": "Apex Legends",
        "Release_Date": "4/2/2019",
        "Developer": "Respawn Entertainment",
        "Game_Description": "Battle Royale, FPS",
        "Game_Img_Main": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Games%2F2lDpkC67LgxHBxEmFQyo%2FGame_Img_Main.jpg?generation=1713762244515420&alt=media",
        "Game_Img_Banner": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Games%2F2lDpkC67LgxHBxEmFQyo%2FGame_Img_Banner.jpg?generation=1713762371027324&alt=media"
    }
*/
app.get("/users/:User_Id/gamePreferences", (req, res) => {
  const User_Id = req.params.User_Id;
  axios
    .get(UserMicro + `/usersM/${User_Id}/gamePreferences`)
    .then((response) => {
      console.log("return from user microservice, getting game preferences");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res
        .status(500)
        .send(error.message + " Error in getting game preferences");
    });
});

// Endpoint to add a new commuinty to the user's followed communities
// To add a new community to the user's followed communities, send the user id in the request
// The community id is the body of the request
// After a user has followed a community, the community will have a new member
/*
  Description: This endpoint is used to add a new community to the user's followed communities.
                The community will have a new member added to it.

  Endpoint: /users/:User_Id/followCommunity
  ex. /users/gWi0CJnCNuUpjhpnRio48c9PnJh2/followCommunity

  Request:
  params: User_Id
  body:
  {
    Community_Id: "community_id"
  }

  Response:
  Success
*/
app.put("/users/:User_Id/followCommunity", (req, res) => {
  let User_Id = req.params.User_Id;
  let Community_Id = req.body.Community_Id;

  axios
    .put(UserMicro + `/usersM/${User_Id}/followCommunity`, {
      Community_Id: Community_Id,
    })
    .then((response) => {
      // This is the second call to the community microservice
      // The community will have a new member added to it
      return axios
        .put(CommunityMicro + `/communitiesM/${Community_Id}/addMember`, {
          User_Id: User_Id,
        })
        .then(() => {
          console.log(response.data);
          res.status(200).send(response.data);
        })
        .catch((err) => {
          res.status(500).send(err.message);
        });
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get all the communities that the user is following
// The user id is used to identify the user whose followed communities are to be retrieved
// The returned value here is the list of communities (as objects) that the user is following
/*

  Description: This endpoint is used to get all the communities that the user is following.

  Endpoint: /users/:User_Id/followedCommunities
  ex. /users/gWi0CJnCNuUpjhpnRio48c9PnJh2/followedCommunities
  Request:
  params: User_Id
  
  Response:
  [
    {
        "Community_Id": "HUHqxjyDotmVe9p8Xofn",
        "Community_Name": "cvvbh",
        "Description": "gjvggs",
        "Thumbnail": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ6IdH99WaM9JLAvOnSEANFBHh3sdta32njL0GI9E9Yg&s"
    }
]
*/
app.get("/users/:User_Id/followedCommunities", (req, res) => {
  let User_Id = req.params.User_Id;
  axios
    .get(UserMicro + `/usersM/${User_Id}/followedCommunities`)
    // This is the second call to the community microservice
    // The returned value here is the list of communities (as objects) that the user is following
    .then((commuintyReferences) => {
      return axios
        .get(CommunityMicro + `/communitiesM/followedCommunities`, {
          params: {
            CommunitiesReferences: commuintyReferences.data,
          },
        })
        .then((response) => {
          console.log(
            "return from both Community and User microservices, getting followed communities"
          );
          res.status(200).send(response.data);
        });
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to remove a community from the user's followed communities
// To remove a community from the user's followed communities, send the user id in the request
// The community id is the body of the request
// After a user has unfollowed a community, the community will have a member removed from it
/*

  Description: This endpoint is used to remove a community from the user's followed communities.
                The community will have a member removed from it.

  Endpoint: /users/:User_Id/unfollowCommunity
  ex. /users/gWi0CJnCNuUpjhpnRio48c9PnJh2/unfollowCommunity

  Request:
  params: User_Id
  query:
  {
    Community_Id: "community_id"
  }

  Response:
  Success
*/
app.delete("/users/:User_Id/unfollowCommunity", (req, res) => {
  var User_Id = req.params.User_Id;
  let Community_Id = req.query.Community_Id;

  axios
    .delete(UserMicro + `/usersM/${User_Id}/unfollowCommunity`, {
      params: { Community_Id: Community_Id },
    })
    .then((response) => {
      // This is the second call to the community microservice
      // The community will have a member removed from it
      return axios
        .delete(CommunityMicro + `/communitiesM/${Community_Id}/removeMember/?User_Id=${User_Id}`) 
        .then(() => {
          console.log(response.data);
          res.status(200).send("success");
        });
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

/////////////////////////////////////////////////
// Endpoint for Game Microservice
/////////////////////////////////////////////////

// Endpoint for creating a new game
/*
  Description: This endpoint is used to create a new/requested game in the database.

  Endpoint: /games
  ex. /games

  Request:
  body:
  {
    "Game_Name": "Sekiro: Shadows Die Twice",
    "Game_Description": "Carve your own clever path to vengeance in an all-new adventure from developer FromSoftware, creators of Bloodborne and the Dark Souls series.",
    "Game_Genre": ["Action", "Adventure"],
    "Release_Date": "2019-03-22",
    "Developer": "FromSoftware"
  }

  Response:
  return the the Game_Id of the created game
  {
    "Game_Id": "0jQ7hhSn3u8S8zOCugdS"
  }
*/
app.post("/games", (req, res) => {
  axios
    .post(GameMicro + "/gamesM", req.body)
    .then((response) => {
      if (response.data === "Game already exists") {
        return res.status(409).send(response.data);
      }
      console.log("return from Game microservice, creating game");
      res.status(201).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500);
    });
});

// Endpoint for getting specific/all games
/*
  Description: This endpoint is used to get specific/all games from the database.

  Endpoint: /games
  ex. /games

  Request:
  query: if you want to get a specific game, you can use the query parameter
  {
    Game_Id: "game_id",
  }

  Response:
  return list of games from the database
  {
    "Game_Id": "0jQ7hhSn3u8S8zOCugdS",
    "Game_Genre": [
        "FPS"
    ],
    "Game_Name": "Call of Duty: Modern Warfare III",
    "Release_Date": "10/11/2023",
    "Game_Img_Main": "",
    "Developer": "Sledgehammer Games",
    "Game_Description": "FPS",
    "Game_Img_Banner": ""
  }
*/
app.get("/games", (req, res) => {
  axios
    .get(GameMicro + "/gamesM/", { params: req.query })
    .then((response) => {
      console.log("return from Game microservice, getting games");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in getting games");
    });
});

// endpoint for editing game information
/*
  Description: This endpoint is used to edit game information in the database using the given game id.

  Endpoint: /games/:Game_Id
  ex. /games/0jQ7hhSn3u8S8zOCugdS

  Request:
  params: Game_Id
  body:
  {
    Developer: "Sledgehammer Games"
  }

  Response:
  return the updated game information
  {
    "Game_Id": "0jQ7hhSn3u8S8zOCugdS",
    "Game_Genre": [
        "FPS"
    ],
    "Game_Name": "Call of Duty: Modern Warfare III",
    "Release_Date": "10/11/2023",
    "Game_Img_Main": "",
    "Developer": "Sledgehammer Games",
    "Game_Description": "FPS",
    "Game_Img_Banner": ""
  }
*/
app.put("/games/:Game_Id", (req, res) => {
  const Game_Id = req.params.Game_Id;
  axios
    .put(GameMicro + "/gamesM/" + Game_Id, req.body)
    .then((response) => {
      console.log("return from Game microservice, updating game");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in updating game");
    });
});

// Endpoint for deleting a game
/*
  Description: This endpoint is used to delete a game from the database using the given game id.

  Endpoint: /games/:Game_Id
  ex. /games/0jQ7hhSn3u8S8zOCugdS

  Request:
  params: Game_Id
  
  Response:
  return "Success"
*/
app.delete("/games/:Game_Id", (req, res) => {
  const Game_Id = req.params.Game_Id;
  axios
    .delete(GameMicro + "/gamesM/" + Game_Id)
    .then((response) => {
      console.log("return from Game microservice, deleting game");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in deleting game");
    });
});

// Endpoint for adding a new suggestion to a new game
/*
  Description: This endpoint is used to suggest a new game

  Endpoint: /games/suggestGame
  ex. /games/suggestGame

  Request:
  body:
  {
    "Name": "Sekiro: Shadows Die Twice",
    "Description": "i love sekiro",
    "Genre": ["Action", "Adventure"]
  }

  Response:
  return "Success"
*/
app.post("/games/suggestGame", (req, res) => {
  console.log("request body: ", req.body);
  axios
    .post(GameMicro + "/gamesM/suggestGame", req.body)
    .then((response) => {
      console.log("return from Game microservice, suggesting game");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in suggesting game");
    });
});

/////////////////////////////////////////////////
// Endpoint for login and sign up
/////////////////////////////////////////////////

// app.get("/api/sessions/oauth/google", googleOauthHandler);
// // app.get('/api/sessions/oauth/google/callback',googleOauthHandler)
// async function googleOauthHandler(req, res) {
//   const code = req.query.code;
//   // return {userRecordId, customToken, isNewUser};
//   request.post(
//     UserMicro + "/usersM/sessions/oauth/google",
//     { json: { code } },
//     (err, response, body) => {
//       if (err) {
//         console.log("Error:", err);
//       } else {
//         //console.log("Response status code:", response.statusCode);
//         //console.log("Body:", body);
//         if (body.customToken && body.userRecordId) {
//           // console.log(
//           //   "sending to client the custom token: " +
//           //   body.customToken +
//           //   " and user record: "
//           // );
//           res.redirect(
//             `ironsight://auth/google/?customToken=${body.customToken}&userId=${body.userRecordId}&isNewUser=true&source=google`
//           );

//           // res.redirect(`ironsight://auth/google/?customToken=${body.customToken}&userId=${body.userRecordId}&isNewUser=${body.isNewUser}&source=google`,);
//         } else if (body.customToken) {
//           res.redirect(
//             `ironsight://auth/google/?customToken=${body.customToken}&isNewUser=${body.isNewUser}&source=google`
//           );
//         } else {
//           res.redirect(`ironsight://auth/google/?error=authentication failed`);

//           //console.log("customToken or userRecord not found in body");
//         }
//       }
//     }
//   );
// }

// google OAuth
app.get("/api/sessions/oauth/google", googleOauthHandler);
async function googleOauthHandler(req, res) {
  try {
    const code = req.query.code;
    const response = await axios.post(
      UserMicro + "/usersM/sessions/oauth/google",
      { code }
    );

    if (response.data.customToken && response.data.userRecordId) {
      res.redirect(
        `ironsight://auth/google/?customToken=${response.data.customToken}&userId=${response.data.userRecordId}&isNewUser=true&source=google`
      );
    } else if (response.data.customToken) {
      res.redirect(
        `ironsight://auth/google/?customToken=${response.data.customToken}&isNewUser=${response.data.isNewUser}&source=google`
      );
    } else {
      res.redirect(`ironsight://auth/google/?error=authentication failed`);
    }
    console.log("return from User microservice, googel oauth");
  } catch (error) {
    console.error("Error:", error);
    console.log("return from User microservice, googel oauth in catch block");
    res.redirect(`ironsight://auth/google/?error=authentication failed`);
  }
}

// startgg OAuth
app.get("/api/sessions/oauth/startgg", startGgOauthHandler);
async function startGgOauthHandler(req, res) {
  try {
    const code = req.query.code;
    const response = await axios.post(
      UserMicro + "/usersM/sessions/oauth/startgg",
      { code }
    );

    if (response.data.customToken && response.data.userRecord) {
      res.redirect(
        `ironsight://auth/startgg/?customToken=${response.data.customToken}`
      );
    } else {
      console.log("return from User microservice, startgg oauth 2");
      res.status(400).send("customToken or userRecord not found in body");
    }
    console.log("return from User microservice, startgg oauth");
  } catch (error) {
    console.error("Error:", error);
    console.log("return from User microservice, startgg oauth in catch block");
    res.status(500).send("Server error");
  }
}

// API endpoint for initial signup
app.post("/users/:uid/signup", async (req, res) => {
  const email = req.body.email;
  //const phone_number = req.body.phone_number;
  const uid = req.params.uid;
  try {
    const signupResponse = await axios.post(UserMicro + "/usersM/signup", {
      uid,
      email,
    });
    console.log("return from User microservice, signup");
    res.send(signupResponse.data);
  } catch (error) {
    console.error("Error:", error);
    console.log("return from User microservice, signup in catch block");
    return res.status(500).json({ error: "Internal server error" });
  }
});

/////////////////////////////////////////////////
// Endpoint for Community Microservice
/////////////////////////////////////////////////

// Endpoint to retrieve community information from the database using the given request query
// To retrieve all communities, send an empty request query
// To retrieve a community with a specific parameter, send a request query with the parameter
/*
  Description: This endpoint is used to retrieve community information from the database using the given request query or getting all communities.

  Endpoint: /communities
  ex. /communities

  Request:
  query: 
  {
    Community_Id: "community_id",
  }

  Response:
  return the community information from the database using the given request query or getting all communities

*/
app.get("/communities", (req, res) => {
  axios
    .get(CommunityMicro + "/communitiesM/", { params: req.query })
    .then((response) => {
      console.log("return from Community microservice, getting communities");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in getting communityes");
    });
});

// Endpoint to delete
/*
  Description: This endpoint is used to delete a community from the database using the given community id.

  Endpoint: /communities/:Community_Id
  ex. /communities/0jQ7hhSn3u8S8zOCugdS

  Request:
  params: Community_Id

  Response:
  return "Community deleted successfully"
*/
app.delete("/communities/:Community_Id", (req, res) => {
  const Community_Id = req.params.Community_Id;
  axios
    .delete(CommunityMicro + "/communitiesM/" + Community_Id)
    .then((response) => {
      console.log("return from Community microservice, deleting community");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in deleting community");
    });
});

// Endpoint to edit community information
/*
  Description: This endpoint is used to edit community information in the database using the given community id.

  Endpoint: /communities/:Community_Id
  ex. /communities/0jQ7hhSn3u8S8zOCugdS

  Request:
  params: Community_Id
  body:
  {
    Description: "description",
  }

  Response:
  return the updated community information
    
*/
app.put("/communities/:Community_Id", (req, res) => {
  const Community_Id = req.params.Community_Id;
  axios
    .put(CommunityMicro + "/communitiesM/" + Community_Id, req.body)
    .then((response) => {
      console.log("return from Community microservice, updating community");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in updating community");
    });
});

// Endpoint to create new community
/*
  Description: This endpoint is used to create a new community in the database.

  Endpoint: /communities
  ex. /communities

  Request:
  body:
  {
  "Community_Name": "Test Community",
  "Community_Tag": "test_community",
  "Description": "This is a test community",
  "Owner": "P1",
  "isPrivate": false
  }

  Response:
  return the created community information
*/
app.post("/communities", (req, res) => {
  axios
    .post(CommunityMicro + "/communitiesM", req.body)
    .then((response) => {
      console.log("return from Community microservice, creating community");
      res.status(201).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500);
    });
});

// Endpoint to add a new member to the community
/*
  Description: This endpoint is used to add a new member to the community.

  Endpoint: /communities/:Community_Id/addMember
  ex. /communities/F6PjGYXY4XXACnMzlOPw/addMember

  Request:
  params: Community_Id
  body:
  {
    User_Id: "user_id"
  }

  Response:
  return the community information after adding the new member.
 {
    "Owner": "P1",
    "Description": "newc",
    "isVerified": false,
    "Banner": "https://t4.ftcdn.net/jpg/04/74/44/85/360_F_474448512_w2NP8jcwfKKX9rIballVuxSqQK4rNRbE.jpg",
    "isPrivate": false,
    "Thumbnail": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ6IdH99WaM9JLAvOnSEANFBHh3sdta32njL0GI9E9Yg&s",
    "Moderators": [],
    "Third_Party_Link": {},
    "Community_Tag": "#newc",
    "Blocked_Users": [],
    "Community_Name": "newc",
    "Password": "",
    "Created_At": {
        "_seconds": 1712713329,
        "_nanoseconds": 730000000
    },
    "Community_Picture": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Community%2FF6PjGYXY4XXACnMzlOPw%2FCommunity_Picture?generation=1712724303061029&alt=media",
    "Members": [
        "HLjOjd1C1IUcFE9oX30QtqIj05z2",
        "NQJ97lxPzwNjDCruBeYoNtbQBp53",
        "Yj7tyl9s1SUu8yrLiYoypV3SZH72",
        "dJXc36YpoggsB8YoE48EQk4aTUk2"
    ],
    "Community_Id": "F6PjGYXY4XXACnMzlOPw"
}
*/
app.put("/communities/:Community_Id/addMember", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let User_Id = req.body.User_Id;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/addMember`, {
      User_Id: User_Id,
    })
    .then((response) => {
      console.log(
        "return from Community microservice, adding member to community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to remove a member from the community
/*
  Description: This endpoint is used to remove a member to the community.

  Endpoint: /communities/:Community_Id/removeMember
  ex. /communities/F6PjGYXY4XXACnMzlOPw/removeMember

  Request:
    params: Community_Id
    Query:
    {
      User_Id: "user_id"
    }

  Response:
  return the community information after removing the member.
 {
    "Owner": "P1",
    "Description": "newc",
    "isVerified": false,
    "Banner": "https://t4.ftcdn.net/jpg/04/74/44/85/360_F_474448512_w2NP8jcwfKKX9rIballVuxSqQK4rNRbE.jpg",
    "isPrivate": false,
    "Thumbnail": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ6IdH99WaM9JLAvOnSEANFBHh3sdta32njL0GI9E9Yg&s",
    "Moderators": [],
    "Third_Party_Link": {},
    "Community_Tag": "#newc",
    "Blocked_Users": [],
    "Community_Name": "newc",
    "Password": "",
    "Created_At": {
        "_seconds": 1712713329,
        "_nanoseconds": 730000000
    },
    "Community_Picture": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Community%2FF6PjGYXY4XXACnMzlOPw%2FCommunity_Picture?generation=1712724303061029&alt=media",
    "Members": [
        "HLjOjd1C1IUcFE9oX30QtqIj05z2",
        "NQJ97lxPzwNjDCruBeYoNtbQBp53",
        "Yj7tyl9s1SUu8yrLiYoypV3SZH72"
    ],
    "Community_Id": "F6PjGYXY4XXACnMzlOPw"
}
*/
app.delete("/communities/:Community_Id/removeMember", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let User_Id = req.query.User_Id;
  axios
    .delete(CommunityMicro + `/communitiesM/${Community_Id}/removeMember`, {
      params: { User_Id: User_Id },
    })
    .then((response) => {
      console.log(
        "return from Community microservice, removing member from community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get all members of a community
/*
  Description: This endpoint is used to get all members of a community.

  Endpoint: /communities/:Community_Id/members
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/members

  Request:
  params: Community_Id

  Response:
  return the list of members of the community
  each member will contain
  {
        "User_Id": "llgjGsEJ0OQ8tT5qUccXWkDryf13",
        "User_Name": "@mockDataUser7",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Bio": "This is mock bio",
        "Display_Name": "MockData3"
    },
*/
app.get("/communities/:Community_Id/members", (req, res) => {
  let Community_Id = req.params.Community_Id;
  axios
    .get(CommunityMicro + `/communitiesM/${Community_Id}/members`)
    .then((response) => {
      console.log(
        "return from Community microservice, getting members of community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to block a member from the community
/*
  Description: This endpoint is used to block a member from the community.

  Endpoint: /communities/:Community_Id/blockMember
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/blockMember

  Request:
  params: Community_Id
  body:
  {
    User_Id: "user_id"
  }

  Response:
  return "Success"
*/
app.put("/communities/:Community_Id/blockMember", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let User_Id = req.body.User_Id;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/blockMember`, {
      User_Id: User_Id,
    })
    .then((response) => {
      console.log(
        "return from Community microservice, blocking member from community"
      );
      res.status(200).send("Success");
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send("Error :" + error.message);
    });
});

// Endpoint to unblock a member from the community
/*
  Description: This endpoint is used to unblock a member from the community.

  Endpoint: /communities/:Community_Id/unblockMember
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/unblockMember

  Request:
  params: Community_Id
  body:
  {
    User_Id: "user_id"
  }

  Response:
  return "Success"
*/
app.put("/communities/:Community_Id/unblockMember", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let User_Id = req.body.User_Id;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/unblockMember`, {
      User_Id: User_Id,
    })
    .then((response) => {
      console.log(
        "return from Community microservice, unblocking member from community"
      );
      res.status(200).send("Success");
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get all blocked members of a community
/*
  Description: This endpoint is used to get all blocked members of a community.

  Endpoint: /communities/:Community_Id/blockedMembers
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/blockedMembers

  Request:
  params: Community_Id

  Response:
  return the list of blocked members of the community
  each member will contain
  {
        "User_Id": "llgjGsEJ0OQ8tT5qUccXWkDryf13",
        "User_Name": "@mockDataUser7",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Bio": "This is mock bio",
        "Display_Name": "MockData3"
    },
*/
app.get("/communities/:Community_Id/blockedMembers", (req, res) => {
  let Community_Id = req.params.Community_Id;
  axios
    .get(CommunityMicro + `/communitiesM/${Community_Id}/blockedMembers`)
    .then((response) => {
      console.log(
        "return from Community microservice, getting blocked members of community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to add a moderator to the community
/*
  Description: This endpoint is used to add a moderator to the community.

  Endpoint: /communities/:Community_Id/addModerator
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/addModerator

  Request:
  params: Community_Id
  body:
  {
    User_Id: "user_id"
  }

  Response:
  return "Success"
*/
app.put("/communities/:Community_Id/addModerator", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let User_Id = req.body.User_Id;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/addModerator`, {
      User_Id: User_Id,
    })
    .then((response) => {
      console.log(
        "return from Community microservice, adding moderator to community"
      );
      res.status(200).send("Success");
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to remove a moderator from the community
/*
  Description: This endpoint is used to remove a moderator from a community.

  Endpoint: /communities/:Community_Id/removeModerator
  ex. /communities/F6PjGYXY4XXACnMzlOPw/removeModerator

  Request:
  params: Community_Id
  body:
  {
    User_Id: "user_id"
  }

  Response:
  return "Success"
*/
app.put("/communities/:Community_Id/removeModerator", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let User_Id = req.body.User_Id;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/removeModerator`, {
      User_Id: User_Id,
    })
    .then((response) => {
      if (response.status === 200) {
        res.status(200).send("Success");
      } else {
        res.status(response.status).send(response.data);
      }
      console.log(
        "return from Community microservice, removing moderator from community"
      );
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get all moderators of a community
/*
  Description: This endpoint is used to get all moderators of a community.

  Endpoint: /communities/:Community_Id/moderators
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/moderators

  Request:
  params: Community_Id

  Response:
  return the list of moderators of the community
  each moderator will contain
  {
        "User_Id": "llgjGsEJ0OQ8tT5qUccXWkDryf13",
        "User_Name": "@mockDataUser7",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Bio": "This is mock bio",
        "Display_Name": "MockData3"
    },
*/
app.get("/communities/:Community_Id/moderators", (req, res) => {
  let Community_Id = req.params.Community_Id;
  axios
    .get(CommunityMicro + `/communitiesM/${Community_Id}/moderators`)
    .then((response) => {
      console.log(
        "return from Community microservice, getting moderators of community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get the owner of a community
/*
  Description: This endpoint is used to get the owner of a community.

  Endpoint: /communities/:Community_Id/owner
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/owner

  Request:
  params: Community_Id

  Response:
  return the owner of the community
  {
        "User_Id": "llgjGsEJ0OQ8tT5qUccXWkDryf13",
        "User_Name": "@mockDataUser7",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Bio": "This is mock bio",
        "Display_Name": "MockData3"
    },
*/
app.get("/communities/:Community_Id/owner", (req, res) => {
  let Community_Id = req.params.Community_Id;
  axios
    .get(CommunityMicro + `/communitiesM/${Community_Id}/owner`)
    .then((response) => {
      console.log(
        "return from Community microservice, getting owner of community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to make a community private
/*
  Description: This endpoint is used to make a community private. The community will have a password to join.

  Endpoint: /communities/:Community_Id/makePrivate
  ex. /communities/F6PjGYXY4XXACnMzlOPw/makePrivate

  Request:
  params: Community_Id
  body:
  {
    Password: "password"
  }

  Response:
  return the updated community information.
  {
    "Owner": "P1",
    "Description": "newc",
    "isVerified": false,
    "Banner": "https://t4.ftcdn.net/jpg/04/74/44/85/360_F_474448512_w2NP8jcwfKKX9rIballVuxSqQK4rNRbE.jpg",
    "Thumbnail": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ6IdH99WaM9JLAvOnSEANFBHh3sdta32njL0GI9E9Yg&s",
    "Third_Party_Link": {},
    "Community_Tag": "#newc",
    "Community_Name": "newc",
    "Created_At": {
        "_seconds": 1712713329,
        "_nanoseconds": 730000000
    },
    "Community_Picture": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Community%2FF6PjGYXY4XXACnMzlOPw%2FCommunity_Picture?generation=1712724303061029&alt=media",
    "Blocked_Users": [],
    "Moderators": [
        "Yj7tyl9s1SUu8yrLiYoypV3SZH72"
    ],
    "Members": [
        "HLjOjd1C1IUcFE9oX30QtqIj05z2",
        "NQJ97lxPzwNjDCruBeYoNtbQBp53"
    ],
    "isPrivate": true,
    "Password": "Hello",
    "Community_Id": "F6PjGYXY4XXACnMzlOPw"
}
*/
app.put("/communities/:Community_Id/makePrivate", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let Password = req.body.Password;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/makePrivate`, {
      Password: Password,
    })
    .then((response) => {
      console.log(
        "return from Community microservice, making community private"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to make a community public
/*

  Description: This endpoint is used to make a community public.

  Endpoint: /communities/:Community_Id/makePublic
  ex. /communities/F6PjGYXY4XXACnMzlOPw/makePublic

  Request:
  params: Community_Id

  Response:
  return the updated community information.
  {
    "Owner": "P1",
    "Description": "newc",
    "isVerified": false,
    "Banner": "https://t4.ftcdn.net/jpg/04/74/44/85/360_F_474448512_w2NP8jcwfKKX9rIballVuxSqQK4rNRbE.jpg",
    "Thumbnail": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ6IdH99WaM9JLAvOnSEANFBHh3sdta32njL0GI9E9Yg&s",
    "Third_Party_Link": {},
    "Community_Tag": "#newc",
    "Community_Name": "newc",
    "Created_At": {
        "_seconds": 1712713329,
        "_nanoseconds": 730000000
    },
    "Community_Picture": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Community%2FF6PjGYXY4XXACnMzlOPw%2FCommunity_Picture?generation=1712724303061029&alt=media",
    "Blocked_Users": [],
    "Moderators": [
        "Yj7tyl9s1SUu8yrLiYoypV3SZH72"
    ],
    "Members": [
        "HLjOjd1C1IUcFE9oX30QtqIj05z2",
        "NQJ97lxPzwNjDCruBeYoNtbQBp53"
    ],
    "isPrivate": false,
    "Password": "",
    "Community_Id": "F6PjGYXY4XXACnMzlOPw"
}
*/
app.put("/communities/:Community_Id/makePublic", (req, res) => {
  let Community_Id = req.params.Community_Id;
  axios
    .put(CommunityMicro + `/communitiesM/${Community_Id}/makePublic`)
    .then((response) => {
      console.log(
        "return from Community microservice, making community public"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to add a new post to the community
// To add a new post to a community, send the community id in the request
// The post part is the body of the request and it conatins the post information
/*
  Description: This endpoint is used to add a new post to the community.

  Endpoint: /communities/:Community_Id/posts/addPost
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/posts/addPost

  Request:
  params: Community_Id
  body:
  {
    "User_Id": "P1",
    "Post_Content": "This is a test post"
  }

  Response:
  return the created post information
  {
    "Post_Id": "N65Lu51yZkCJx3UKEX0M",
    "Poster": {
        "User_Id": "P1",
        "User_Name": "@otariko",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Display_Name": "Turki Alduhami"
    },
    "Post_Content": "This is a test post",
    "Post_Likes_Count": 0,
    "Post_Media": [],
    "Created_At": {
        "_seconds": 1713413514,
        "_nanoseconds": 742000000
    }
  }
*/
app.post("/communities/:Community_Id/posts/addPost", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let post = req.body;
  axios
    .post(CommunityMicro + `/communitiesM/${Community_Id}/posts/addPost`, {
      post,
    })
    .then((response) => {
      console.log(
        "return from Community microservice, adding post to community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to retrieve posts of a community
// To get all posts of a community, provide the community id in the request
// To retrieve a specific post within a community, include the post id in the request
/*
  Description: This endpoint is used to retrieve posts of a community.

  Endpoint: /communities/:Community_Id/posts
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/posts

  Request:
  params: Community_Id
  query: if you want to get a specific post, include the post id in the query
  {
    Post_Id: "post_id"
  }

  Response:
  return the list of posts of the community
  each post will contain
  {
    "Post_Id": "N65Lu51yZkCJx3UKEX0M",
    "Poster": {
        "User_Id": "P1",
        "User_Name": "@otariko",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Display_Name": "Turki Alduhami"
    },
    "Post_Content": "This is a test post",
    "Post_Likes_Count": 0,
    "Post_Media": [],
    "Created_At": {
        "_seconds": 1713413514,
        "_nanoseconds": 742000000
    },
    "Post_Likes": [
        "QL7CunPRWhQX7Fy4Pdx2s1ZCtaw2",
        "pCErnee4w5VPbfUulGLAilRVtsm2"
    ]
  }
  */
app.get("/communities/:communityId/posts", (req, res) => {
  const communityId = req.params.communityId;
  const postId = req.query.Post_Id

  let url = `${CommunityMicro}/communitiesM/${communityId}/posts`;
  if (postId) {
    url += `?Post_Id=${postId}`;
  }

  axios
    .get(url)
    .then((response) => {
      console.log(
        "return from Community microservice, getting posts of community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.error(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get top posts in a community (most liked posts)
/*
  Description: This endpoint is used to get top posts in a community (most liked posts).

  Endpoint: /communities/:Community_Id/posts/topPosts
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/posts/topPosts

  Request:
  params: Community_Id
  
  Response:
  return the list of top posts in the community in descending order "descending is like 9 to 0"
  each post will contain
  {
        "Post_Id": "WV2O4rELr7ZKodqYwYMC",
        "Poster": {
            "User_Id": "P1",
            "User_Name": "@otariko",
            "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
            "Display_Name": "Turki Alduhami"
        },
        "Post_Content": "uplading",
        "Post_Likes_Count": 999,
        "Post_Media": [],
        "Created_At": {
            "_seconds": 1713280441,
            "_nanoseconds": 524000000
        },
        "Post_Likes": [
            "QL7CunPRWhQX7Fy4Pdx2s1ZCtaw2",
            "pCErnee4w5VPbfUulGLAilRVtsm2"
        ]
    },
*/
app.get("/communities/:Community_Id/posts/topPosts", (req, res) => {
  let Community_Id = req.params.Community_Id;
  axios
    .get(CommunityMicro + `/communitiesM/${Community_Id}/posts/topPosts`)
    .then((response) => {
      console.log(
        "return from Community microservice, getting top posts of community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to delete a post from the community
/*
  Description: This endpoint is used to delete a post from the community.

  Endpoint: /communities/:Community_Id/posts/removePost
  ex. /communities/0jQ7hhSn3u8S8zOCugdS/posts/removePost

  Request:
  params: Community_Id
  query:
  {
    Post_Id: "post_id"
  }

  Response:
  return the list of posts of the community
*/
app.delete("/communities/:Community_Id/posts/removePost", (req, res) => {
  let Community_Id = req.params.Community_Id;
  let Post_Id = req.query.Post_Id;
  axios
    .delete(
      CommunityMicro +
        `/communitiesM/${Community_Id}/posts/removePost/${Post_Id}`
    )
    .then((response) => {
      console.log(
        "return from Community microservice, removing post from community"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to add a new reply to the post
// To add a new reply to a post, send the post id in the request
// The reply part is the body of the request and it conatins the reply information
/*

  Description: This endpoint is used to add a new reply to the post.

  Endpoint: /communities/posts/:Post_Id/replies/addReply
  ex. /communities/posts/6yFSqL5theEFa4TTBP6x/replies/addReply
  
  Request:
  params: Post_Id
  body:
  {
    "User_Id": "P1",
    "Reply_Content": "This is a test reply",
    "Reply_Media":[
      "Picture link 1",
    ]
  }

  Response:
  return the created reply information along with the post information.

  {
    "Replier": {
        "User_Id": "dJXc36YpoggsB8YoE48EQk4aTUk2",
        "User_Name": "@aprilx18@mail.com",
        "Profile_Picture": "",
        "Display_Name": ""
    },
    "Reply_Content": "Hey",
    "Reply_Likes_Count": 0,
    "Reply_Media": [],
    "Reply_Likes": [],
    "Created_At": {
        "_seconds": 1713811913,
        "_nanoseconds": 394000000
    },
    "Reply_Id": "IrA90SG167CjPmSf4rdZ",
    "Post_Replies_Count": 1,
    "Post_Id": "9vQRw0azYJfyOLz5lbuS"
}
*/
app.post("/communities/posts/:Post_Id/replies/addReply", (req, res) => {
  let Post_Id = req.params.Post_Id;
  let reply = req.body;
  axios
    .post(CommunityMicro + `/communitiesM/posts/${Post_Id}/replies/addReply`, {
      reply,
    })
    .then((response) => {
      console.log("return from Community microservice, adding reply to post");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get all replies of a post
// To retrieve all replies of a particular post, send the post id in the request
// To retrieve a specific reply of a particular post, send the reply id in the request
/*
  Description: This endpoint is used to retrieve replies of a post.

  Endpoint: /communities/posts/:Post_Id/replies
  ex. /communities/posts/9vQRw0azYJfyOLz5lbuS/replies

  Request:
  params: Post_Id
  query: if you want to get a specific reply, include the reply id in the query
  {
    Reply_Id: "reply_id"
  }

  Response:
  return the list of replies of the post
  [
    {
        "Reply_Id": "IrA90SG167CjPmSf4rdZ",
        "Replier": {
            "User_Id": "dJXc36YpoggsB8YoE48EQk4aTUk2",
            "User_Name": "@aprilx18@mail.com",
            "Profile_Picture": "",
            "Display_Name": ""
        },
        "Reply_Content": "Hey",
        "Reply_Likes_Count": 0,
        "Reply_Media": [],
        "Created_At": {
            "_seconds": 1713811913,
            "_nanoseconds": 394000000
        },
        "Reply_Likes": []
    }
]
*/
app.get("/communities/posts/:Post_Id/replies", (req, res) => {
  let Post_Id = req.params.Post_Id;
  let Reply_Id = req.query.Reply_Id;

  let url = `${CommunityMicro}/communitiesM/posts/${Post_Id}/replies`;
  if (Reply_Id) {
    url += `?Reply_Id=${Reply_Id}`;
  }
  axios
    .get(url)
    .then((response) => {
      console.log(
        "return from Community microservice, getting replies of post"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to get the number of replies in a post
/*
  Description: To retrieve the number of replies in a particular post, send the post id in the request

  Endpoint: /communities/posts/:Post_Id/replies/repliesCount
  ex. /communities/posts/6yFSqL5theEFa4TTBP6x/replies/repliesCount

  Request:
    params: Post_Id

  Response: 
    return the count of replies in the post
    [
      "Post_Id": "6yFSqL5theEFa4TTBP6x",
      "Reply_Count": 1
    ]
*/
app.get("/communities/posts/:Post_Id/replies/repliesCount", (req, res) => {
  let Post_Id = req.params.Post_Id;
  axios
    .get(CommunityMicro + `/communitiesM/posts/${Post_Id}/replies/repliesCount`)
    .then((response) => {
      console.log(
        "return from Community microservice, getting replies count of post"
      );
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to delete a reply from the post
/*
  Description: This endpoint is used to delete a reply from the post.

  Endpoint: /communities/posts/:Post_Id/replies/removeReply
  ex. /communities/posts/9vQRw0azYJfyOLz5lbuS/replies/removeReply
  
  Request:
  params: Post_Id
  query:
  {
    Reply_Id: "reply_id"
  }
  
  Response:
  "Success"
*/

app.delete("/communities/posts/:Post_Id/replies/removeReply", (req, res) => {
  let Post_Id = req.params.Post_Id;
  let Reply_Id = req.query.Reply_Id;
  axios
    .delete(
      CommunityMicro +
        `/communitiesM/posts/${Post_Id}/replies/removeReply/${Reply_Id}`
    )
    .then((response) => {
      console.log(
        "return from Community microservice, removing reply from post"
      );
      res.status(200).send("Success");
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to like a post
// The post id is used to identify the post that the user wants to like
// The user id is used to identify the user that wants to like the post
// The same user can not like the same post multiple times
/*
  Description: This endpoint is used to like a post.

  Endpoint: /communities/posts/:Post_Id/likePost
  ex. /communities/posts/9vQRw0azYJfyOLz5lbuS/likePost

  Request:
  params: Post_Id
  body:
  {
    User_Id: "P1"
  }
  
  Response:
    {
    "Post_Id": "9vQRw0azYJfyOLz5lbuS",
    "Poster": {
        "User_Id": "P1",
        "User_Name": "@otariko",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Display_Name": "Turki Alduhami"
    },
    "Post_Content": "HEY ABDULLAH",
    "Post_Likes_Count": 668,
    "Post_Media": [
        "https://www.google.com/logos/doodles/2024/alfonso-casos-128th-birthday-6753651837109183.4-2x.png"
    ],
    "Created_At": {
        "_seconds": 1713071863,
        "_nanoseconds": 842000000
    },
    "Post_Likes": [
        "P1",
        "dJXc36YpoggsB8YoE48EQk4aTUk2"
    ]
}
*/
app.put("/communities/posts/:Post_Id/likePost", (req, res) => {
  let Post_Id = req.params.Post_Id;
  let User_Id = req.body.User_Id;

  axios
    .put(CommunityMicro + `/communitiesM/posts/${Post_Id}/likePost`, {
      User_Id: User_Id,
    })
    .then((response) => {
      console.log("return from Community microservice, liking post");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to unlike a post
// The post id is used to identify the post that the user wants to unlike
// The user id is used to identify the user that wants to unlike the post
// The same user can not unlike the same post multiple times
/*
  Description: This endpoint is used to unlike a post.

  Endpoint: /communities/posts/:Post_Id/unlikePost
  ex. /communities/posts/9vQRw0azYJfyOLz5lbuS/unlikePost

  Request:
  params: Post_Id
  body:
  {
    User_Id: "P1"
  }

  Response:
    {
    "Post_Id": "9vQRw0azYJfyOLz5lbuS",
    "Poster": {
        "User_Id": "P1",
        "User_Name": "@otariko",
        "Profile_Picture": "https://www.kfupm.edu.sa/images/default-source/default-album/about-img.jpg?sfvrsn=ac61bc94_0Pdf95B/PyzgU57ylKc85SlPecpTnvKUpzzlKU95ylOe8pSnPOUpT9lS/hdbdm13anf/EgAAAABJRU5ErkJggg==",
        "Display_Name": "Turki Alduhami"
    },
    "Post_Content": "HEY ABDULLAH",
    "Post_Likes_Count": 668,
    "Post_Media": [
        "https://www.google.com/logos/doodles/2024/alfonso-casos-128th-birthday-6753651837109183.4-2x.png"
    ],
    "Created_At": {
        "_seconds": 1713071863,
        "_nanoseconds": 842000000
    },
    "Post_Likes": [
        "P1",
        "dJXc36YpoggsB8YoE48EQk4aTUk2"
    ]
}
*/
app.put("/communities/posts/:Post_Id/unlikePost", (req, res) => {
  let Post_Id = req.params.Post_Id;
  let User_Id = req.body.User_Id;

  axios
    .put(CommunityMicro + `/communitiesM/posts/${Post_Id}/unlikePost`, {
      User_Id: User_Id,
    })
    .then((response) => {
      console.log("return from Community microservice, unliking post");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

// Endpoint to like a reply
// The reply id is used to identify the reply that the user wants to like
// The user id is used to identify the user that wants to like the reply
// The same user can not like the same reply multiple times
/*
  Description: This endpoint is used to like a reply.

  Endpoint: /communities/posts/:Post_Id/replies/:Reply_Id/likeReply
  ex. /communities/posts/9vQRw0azYJfyOLz5lbuS/replies/IrA90SG167CjPmSf4rdZ/likeReply

  Request:
  params: Post_Id, Reply_Id
  body:
  {
    User_Id: "dJXc36YpoggsB8YoE48EQk4aTUk2"
  }

  Response:
    {
    "Replier": "dJXc36YpoggsB8YoE48EQk4aTUk2",
    "Reply_Content": "Hey",
    "Reply_Media": [],
    "Created_At": {
        "_seconds": 1713813752,
        "_nanoseconds": 38000000
    },
    "Reply_Likes_Count": 2,
    "Reply_Likes": [
        "dJXc36YpoggsB8YoE48EQk4aTUk2",
        "fhSQneSadnfVy5TWnA6ZBPH0Inh1"
    ]
}
*/
app.put(
  "/communities/posts/:Post_Id/replies/:Reply_Id/likeReply",
  (req, res) => {
    let Reply_Id = req.params.Reply_Id;
    let User_Id = req.body.User_Id;
    let Post_Id = req.params.Post_Id;

    axios
      .put(
        CommunityMicro +
          `/communitiesM/posts/${Post_Id}/replies/${Reply_Id}/likeReply`,
        { User_Id: User_Id }
      )
      .then((response) => {
        console.log("return from Community microservice, liking reply");
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(error.message);
      });
  }
);

// Endpoint to unlike a reply
// The reply id is used to identify the reply that the user wants to unlike
// The user id is used to identify the user that wants to unlike the reply
// The same user can not unlike the same reply multiple times
/*
  Description: This endpoint is used to unlike a reply.

  Endpoint: /communities/posts/:Post_Id/replies/:Reply_Id/unlikeReply
  ex. /communities/posts/9vQRw0azYJfyOLz5lbuS/replies/IrA90SG167CjPmSf4rdZ/unlikeReply

  Request:
  params: Post_Id, Reply_Id
  body:
  {
    User_Id: "dJXc36YpoggsB8YoE48EQk4aTUk2"
  }

  Response:
  {
    "Replier": "dJXc36YpoggsB8YoE48EQk4aTUk2",
    "Reply_Content": "Hey",
    "Reply_Media": [],
    "Created_At": {
        "_seconds": 1713813752,
        "_nanoseconds": 38000000
    },
    "Reply_Likes_Count": 1,
    "Reply_Likes": [
        "dJXc36YpoggsB8YoE48EQk4aTUk2"
    ]
}
*/
app.put(
  "/communities/posts/:Post_Id/replies/:Reply_Id/unlikeReply",
  (req, res) => {
    let Reply_Id = req.params.Reply_Id;
    let User_Id = req.body.User_Id;
    let Post_Id = req.params.Post_Id;

    axios
      .put(
        CommunityMicro +
          `/communitiesM/posts/${Post_Id}/replies/${Reply_Id}/unlikeReply`,
        { User_Id: User_Id }
      )
      .then((response) => {
        console.log("return from Community microservice, unliking reply");
        res.status(200).send(response.data);
      })
      .catch((error) => {
        console.log(error);
        res.status(500).send(error.message);
      });
  }
);

/////////////////////////////////////////////////
// Endpoint for Chat Microservice
/////////////////////////////////////////////////

// // Endpoint to start a new chat
// /*
//   Description: This endpoint is used to start a new chat.

//   Endpoint: /chats/startChat
//   ex. /chats/startChat

//   Request:
//   body:
//   {
//     "Members": [
//         "member1",
//         "member2"
//     ]
//   }

//   Response:
//   return the created chat information
//   {
//     "Chat_Id": "chat_id",
//     "Chat_Name": "chat_name",
//     "Members": [
//         "member1",
//         "member2"
//     ],
//     "Last_Message": {
//         "Sender": "sender",
//         "Content": "content",
//         "Time": {
//             "_seconds": 1713413514,
//             "_nanoseconds": 742000000
//         }
//     }
//   }
// */
// app.post("/chats/startChat", (req, res) => {
//   axios
//     .post(ChatMicro + "/chatsM/startChat", req.body)
//     .then((response) => {
//       console.log("return from Chat microservice, starting chat");
//       res.status(201).send(response.data);
//     })
//     .catch((error) => {
//       console.error(error);
//       res.status(500).send(error.message);
//     });
// });

// // Endpoint to get all chats of a user
// /*
//   Description: This endpoint is used to get all chats of a user.

//   Endpoint: /chats
//   ex. /chats

//   Request:
//   query:
//   {
//     User_Id: "user_id"
//   }

//   Response:
//   return the list of chats of the user
//   each chat will contain
//   {
//     "Chat_Id": "chat_id",
//     "Chat_Name": "chat_name",
//     "Members": [
//         "member1",
//         "member2"
//     ],
//     "Last_Message": {
//         "Sender": "sender",
//         "Content": "content",
//         "Time": {
//             "_seconds": 1713413514,
//             "_nanoseconds": 742000000
//         }
//     }
//   }
// */
// app.get("/chats", (req, res) => {
//   axios
//     .get(ChatMicro + "/chatsM", { params: req.query })
//     .then((response) => {
//       console.log("return from Chat microservice, getting chats");
//       res.status(200).send(response.data);
//     })
//     .catch((error) => {
//       console.error(error);
//       res.status(500).send(error.message);
//     });
// });

// // Endpoint to get all messages of a chat
// /*
//   Description: This endpoint is used to get all messages of a chat.

//   Endpoint: /chats/:Chat_Id/messages
//   ex. /chats/0jQ7hhSn3u8S8zOCugdS/messages

//   Request:
//   params: Chat_Id

//   Response:
//   return the list of messages of the chat
//   each message will contain
//   {
//     "Message_Id": "message_id",
//     "Sender": "sender",
//     "Content": "content",
//     "Time": {
//         "_seconds": 1713413514,
//         "_nanoseconds": 742000000
//     }
//   }
// */
// app.get("/chats/:Chat_Id/messages", (req, res) => {
//   let Chat_Id = req.params.Chat_Id;
//   axios
//     .get(ChatMicro + `/chatsM/${Chat_Id}/messages`)
//     .then((response) => {
//       console.log("return from Chat microservice, getting messages of chat");
//       res.status(200).send(response.data);
//     })
//     .catch((error) => {
//       console.error(error);
//       res.status(500).send(error.message);
//     });
// });

// // Endpoint to add a new message to the chat
// /*
//   Description: This endpoint is used to add a new message to the chat.

//   Endpoint: /chats/:Chat_Id/messages/addMessage
//   ex. /chats/0jQ7hhSn3u8S8zOCugdS/messages/addMessage

//   Request:
//   params: Chat_Id
//   body:
//   {
//     "Sender": "sender",
//     "Content": "content"
//   }

//   Response:
//   return the created message information
//   {
//     "Message_Id": "message_id",
//     "Sender": "sender",
//     "Content": "content",
//     "Time": {
//         "_seconds": 1713413514,
//         "_nanoseconds": 742000000
//     }
//   }
// */
// app.post("/chats/:Chat_Id/messages/addMessage", (req, res) => {
//   let Chat_Id = req.params.Chat_Id;
//   let message = req.body;
//   axios
//     .post(ChatMicro + `/chatsM/${Chat_Id}/messages/addMessage`, {
//       message,
//     })
//     .then((response) => {
//       console.log("return from Chat microservice, adding message to chat");
//       res.status(200).send(response.data);
//     })
//     .catch((error) => {
//       console.error(error);
//       res.status(500).send(error.message);
//     });
// });

// // Endpoint to delete a message from the chat
// /*
//   Description: This endpoint is used to delete a message from the chat.

//   Endpoint: /chats/:Chat_Id/messages/removeMessage
//   ex. /chats/0jQ7hhSn3u8S8zOCugdS/messages/removeMessage

//   Request:
//   params: Chat_Id
//   body:
//   {
//     Message_Id: "message_id"
//   }

//   Response:
//   return the list of messages of the chat
// */
// app.delete("/chats/:Chat_Id/messages/removeMessage", (req, res) => {
//   let Chat_Id = req.params.Chat_Id;
//   let Message_Id = req.body.Message_Id;
//   axios
//     .delete(ChatMicro + `/chatsM/${Chat_Id}/messages/removeMessage/${Message_Id}`)
//     .then((response) => {
//       console.log("return from Chat microservice, removing message from chat");
//       res.status(200).send(response.data);
//     })
//     .catch((error) => {
//       console.error(error);
//       res.status(500).send(error.message);
//     });
// });

// // test chat microservice
// app.get("/chats/test", (req, res) => {
//   axios
//     .get(ChatMicro + "/chatsM/test")
//     .then((response) => {
//       console.log("return from Chat microservice, testing");
//       res.status(200).send(response.data);
//     })
//     .catch((error) => {
//       console.error(error);
//       res.status(500).send(error.message);
//     });
// }
// );

/////////////////////////////////////////////////
// Endpoint for Search Microservice
/////////////////////////////////////////////////

// This endpoint is used as a general search for all microservices
// You can search for games,tournaments,communities and users
// provdie the search query in the request
// provide the collection you want to search in

// [
//   {
//       "Game_Genre": [
//           "Fighting"
//       ],
//       "Game_Name": "Tekken 8",
//       "Release_Date": "26-1-2024",
//       "Developer": "Bandai Namco Studios",
//       "Game_Description": "Fighting",
//       "Game_Img_Banner": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Games%2FmLLN9qHeOlEzAa20AwmK%2FGame_Img_Banner.jpg?generation=1713762623341685&alt=media",
//       "Game_Img_Main": "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Games%2FmLLN9qHeOlEzAa20AwmK%2FGame_Img_Main.jpg?generation=1713762629367471&alt=media",
//       "Game_Name_Lower": "tekken 8"
//   }
// ]
app.get("/search/:collection", (req, res) => {
  var collection = req.params.collection;
  axios
    .get(SearchMicro + "/searchM/" + collection, { params: req.query })
    .then((response) => {
      console.log("return from Search microservice, searching");
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.error(error);
      res.status(500).send(error.message);
    });
});

app.listen(port, () => {
  console.log("API_Flutter Server is running on port " + port);
});
