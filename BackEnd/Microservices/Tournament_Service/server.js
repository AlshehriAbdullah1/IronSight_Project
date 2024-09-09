const express = require("express");
const cors = require("cors");
const axios = require("axios");
const path = require("path");
const multer = require("multer");
const fs = require("fs");
const FormData = require("form-data");
require("dotenv").config({ path: "../../.env" });
const tournamentFunctions = require("./tournamentFunctions.js");

const app = express();
app.use(express.json());
app.use(cors());

const port = process.env.TOURNAMENT_PORT || 4001;
const MediaMicro = process.env.MEDIA_HOST || "http://localhost:4005";
const UserMicro = process.env.USER_HOST || "http://localhost:4002";
const upload = multer({ dest: "uploads/" });

//////////////////////////////////////////////
// Endpoint for Tournament Microservice
//////////////////////////////////////////////

// Endpoint to create tournament information
app.post("/tournamentsM", async (req, res) => {
  try {
    const options = req.body;
    // Call the function to create tournament information
    var response = await tournamentFunctions.create_tournament(options);
    res.send(response);
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message + ", Error creating tournament");
  }
});


// Endpoint to get the tournaments with the same game name
app.get("/tournamentsM/game/:gameName", async (req, res) => {
  const gameName = req.params.gameName;
  try {
    const tournaments = await tournamentFunctions.get_tournaments_by_game(
      gameName
    );
    res.send(tournaments);
  } catch (error) {
    res.send("Error getting tournaments by game: " + error);
  }
});




// Endpoint to retrieve tournament information from the database using the given request query
// To retrieve all tournaments, send an empty request query
// To retrieve a tournament with a specific ID, send a request query with the ID
app.get("/tournamentsM/", async (req, res) => {
  var options = req.query;
  response = await tournamentFunctions.get_tournament(options);
  // Depending on thw response, respond with the tournament information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});

// Endpoint to delete tournament information from the database using the given request parameter
app.delete("/tournamentsM/:Tour_Id", async (req, res) => {
  const tournamentID = req.params.Tour_Id;
  // Call the function to delete tournament information
  await tournamentFunctions
    .delete_tournament(tournamentID)
    .then(() => {
      res.send("Success");
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});


// Endpoint to set the winner of a match in the tournament
app.put("/tournamentsM/matchWin", async (req, res) => {
  const tour_id = req.body.Tour_Id;
  const winner_id = req.body.Winner_Id;

  try {
    var response = await tournamentFunctions.match_win(tour_id, winner_id);
    // Check if the response is an object with length 2
    if(Object.keys(response).length == 2){
      // Add the tournament to the user's participated tournaments for each participant
      var tourID = tour_id;
      // remove the tournament from the user's current tournaments
      var tourTYPE = "Current";
      response.Participants.forEach(user => {
        axios.post(UserMicro + "/usersM/addParticipatedTournaments", {
          User_Id: user.Participant_Id,
          Tour_Id: tourID,
          Tour_Type: "Previous"
        }).then(async () => {
        
          
        
        axios.delete(UserMicro + "/usersM/"+user.Participant_Id+"/removeParticipatedTournaments/?Tour_Id="+tourID+"&Tour_Type="+tourTYPE,
        
        );
        })
      }
      
    );
    response = response.Matches;
    res.send(response);
    }
    else{
      res.send(response);
    }
  } 
  catch (error) {
    res.send("Error setting match winner: " + error);
  }
});

// Endpoint to get the tournament matches
app.get("/tournamentsM/:Tour_Id/matches", async (req, res) => {
  const tournamentID = req.params.Tour_Id;
  try {
    const matches = await tournamentFunctions.get_matches(tournamentID);
    res.send(matches);
  } catch (error) {
    res.send("Error getting matches: " + error);
  }
});




// Endpoint to start the tournament. This will forcibly start the tournament.
app.put("/tournamentsM/:Tour_Id/startTournament", async (req, res) => {
  var tournamentID = req.params.Tour_Id;
  try {
    var response = await tournamentFunctions.start_tournament(tournamentID);
    

    // Add the tournament to the user's participated tournaments for each participant
    var tourID = tournamentID;
    // remove the tournament from the user's upcoming tournaments
    var tourTYPE = "Upcoming";
    response.Participants.forEach(user => {
      // Add the tournament to the user's current tournaments
      axios.post(UserMicro + "/usersM/addParticipatedTournaments", {
        User_Id: user.Participant_Id,
        Tour_Id: tourID,
        Tour_Type: "Current"
      }).then(async () => {

      axios.delete(UserMicro + "/usersM/"+user.Participant_Id+"/removeParticipatedTournaments/?Tour_Id="+tourID+"&Tour_Type="+tourTYPE,
      
      );
      })
    }
    
  );
  response = response.Matches;
  res.send(response);
  } catch (error) {
    res.send("Error starting tournament: " + error);
  }


   
});


// Endpoint to edit tournament information in the database using the given request parameter
// this one causes problem
app.put("/tournamentsM/:Tour_Id", async (req, res) => {
  console.log("edit tournament");
  const tournamentID = req.params.Tour_Id;
  const params = req.body;
  // Call the function to edit tournament information
  await tournamentFunctions
    .edit_tournament(tournamentID, params)
    .then(async () => {
      // return the edited tournament information by calling the get tournament api
      const tour = await tournamentFunctions.get_tournament({
        Tour_Id: tournamentID,
      });

      res.send(tour);
    })
    .catch((err) => {
      console.log(err);
    });
});

// Endpoint to remove/unregister a participant from a tournament
app.delete(
  "/tournamentsM/:Tour_Id/removeParticipant/:Participant_Id",
  async (req, res) => {
    const Tour_Id = req.params.Tour_Id;
    const Participant_Id = req.params.Participant_Id;
    // Call the function to remove a participant
    try {
      const response = await tournamentFunctions.remove_participant(
        Tour_Id,
        Participant_Id
      );
      res.send(response);
    } catch (error) {
      if (error.message === "Participant is not part of the tournament") {
        res.status(400).send(error.message);
      } else {
        res.status(500).send("error removing participant " + error);
      }
    }
  }
);

app.post("/tournamentsM/registerParticipant", async (req, res) => {
  try {
    const Tour_Id = req.body.Tour_Id;
    const Participant_Id = req.body.Participant_Id;
    // Call the function to register a participant
    var response = await tournamentFunctions.register_participant(
      Tour_Id,
      Participant_Id
    );
    // Respond with the list of participants
    res.send(response);

  } catch (err) {
    console.log(err);
    res.status(500).send("Error registering participant: " + err);
  }
});

app.post("/test", async (req, res) => {
  console.log(req.body);
  res.send("Success");
});

//for testing purposes
app.get("/tournamentsM/:Tour_Id/participants", async (req, res) => {
  const tournamentID = req.params.Tour_Id;
  try{
    var response = await tournamentFunctions.get_participants(tournamentID);
    res.send(response);
  }
  catch(err){
      console.log(err);
      res.send("Error getting participants: " + err);
    }
});

//for testing purposes
// app.get("/tournamentM/copyTournament", async (req, res) => {
//   const tournamentID = req.body.Tour_Id;
//   const doc_id = req.body.doc_id;
//   const participants = await tournamentFunctions.copy_tournament(tournamentID,doc_id);
//   res.send(participants);
// });
//for testing purposes
// app.get("/tournamentM/tournamentResult", async (req, res) => {
//   const tournamentID = req.body.Tour_Id;
//   const participants = await tournamentFunctions.tournament_result(
//     tournamentID
//   );
//   res.send(participants);
// });


// Endpoint to add participated tournaments of a specific user
app.post("/usersM/addBadges", async (req, res) => {
  var tournamentID = req.body.Tour_Id;
  var Tour_Type = req.body.Tour_Type;
  response = await tournamentFunctions.add_badges(tournamentID, Tour_Type);
  // Depending on thw response, respond with the tournament information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});

// Endpoint to get the tournament badges of a specific user
app.get("/usersM/getBadges", async (req, res) => {
  var userID = req.query.User_Id;
  response = await tournamentFunctions.get_badges(userID);
  // Depending on thw response, respond with the tournament information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});



// Endpoint to check if the tournament is ready to start
// this api will call check_to_start function in the tournamentFunctions.js
app.get("/tournamentM/checkStart", async (req, res) => {
  try {
    const result = await tournamentFunctions.check_to_start();
    res.send(result);
  } catch (err) {
    console.log(err);
    res.send("Error checking tournament start: " + err);
  }
});

// store the tournament image in the media service and store the image url in the database
app.post("/tournamentsM/upload", upload.single("file"), (req, res) => {
  get_image_URL(req).then((url) => {
    // edit and Add the image url to the tournament in the database
    const updateObject = { [req.body.image_name]: url };
    tournamentFunctions
      .edit_tournament(req.body.id, updateObject)
      .then((result) => {
        res.send(result);
      });
  });
});

//////////////////////////////////////////////
// Small APIs functions for communication between microservices
//////////////////////////////////////////////

// Function to get the image URL from the media service
function get_image_URL(req) {
  // Get the original file extension
  const originalExtension = path.extname(req.file.originalname);

  // Rename the image original name to the Image_Name, preserving the original extension
  req.file.originalname = `${req.body.image_name}${originalExtension}`;

  // Create a new FormData instance
  const formData = new FormData();

  // Append the file and other data to formData
  formData.append(
    "file",
    fs.createReadStream(req.file.path),
    req.file.originalname
  );
  formData.append("from_micro", req.body.from_micro);
  formData.append("id", req.body.id);

  // Return the Promise chain
  return axios
    .post(MediaMicro + "/mediaM/upload", formData, {
      headers: formData.getHeaders(),
    })
    .then((response) => {
      fs.unlink(req.file.path, (err) => {
        if (err) {
          console.error("Error deleting file:", err);
        }
      });
      return response.data;
    })
    .catch((error) => {
      console.error("Error uploading file:", error);
    });
}

// Start the server
app.listen(port, () => {
  console.log("Tournament Server is running on port " + port);
});
