const express = require("express");
const cors = require("cors");
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

const port = process.env.API_REACT_PORT || 3002;
// Microservices PORTS
const TournamentMicro = process.env.TOURNAMENT_HOST;
const UserMicro = process.env.USER_HOST;
const GameMicro = process.env.GAME_HOST;
const CommunityMicro = process.env.COMMUNITY_HOST;
const AdminMicro = process.env.ADMIN_HOST;


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
  // if (
  //   req.file.mimetype !== "image/jpeg" &&
  //   req.file.mimetype !== "image/png" &&
  //   req.file.mimetype !== "image/jpg" &&
  //   req.file.mimetype !== "image/gif" &&
  //   req.file.mimetype !== "image/webp" &&
  //   req.file.mimetype !== "image/svg+xml"
  // ) {
  //   return res.status(400).send("Invalid image type");
  // }
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
        console.log("return from " + req.body.from_micro + " microservice, uploading image");
      });
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message);
    });
});

/////////////////////////////////////////////////
// Endpoint for Admin Microservice
/////////////////////////////////////////////////

// Endpoint for getting specific admin
/*
  Description: This endpoint is used to get specific admin from the database.

  Endpoint: /admins/:Admin_Id
  ex. /admins/1

  Request:
  params: Admin_Id

  Response:
  return specific admin from the database
*/
app.get("/admins/:Admin_Id", async (req, res) => {
  try {
    const response = await axios.get(
      AdminMicro + "/adminsM/" + req.params.Admin_Id
    );
    console.log("return from Admin microservice, getting admin");
    res.status(200).send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting admin`);
  }
});


/////////////////////////////////////////////////
// Endpoint for Game Microservice
/////////////////////////////////////////////////

// Endpoint for getting all suggestions games
/*
  Description: This endpoint is used to get all suggestions games from the database.

  Endpoint: /suggestions
  ex. /suggestions

  Response:
  return list of suggestions games from the database
*/
app.get("/games/suggestions", async (req, res) => {
  try {
    const response = await axios.get(GameMicro + "/gamesM/suggestions");
    console.log("return from Game microservice, getting suggestions");
    res.status(200).send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in getting suggestions`);
  }
});

// Endpoint for editing a suggestion game
/*
  Description: This endpoint is used to edit a suggestion game in the database.

  Endpoint: /games/suggestions/:Game_Id
  ex. /games/suggestions/1

  Request:
  params: Game_Id
  body: options to edit

  Response:
  return success message if the game is edited successfully
*/
app.put("/games/suggestions/:Suggestion_Id", async (req, res) => {
  try {
    const response = await axios.put(
      GameMicro + "/gamesM/suggestions/" + req.params.Suggestion_Id,
      req.body
    );
    console.log("return from Game microservice, editing suggestion");
    res.status(200).send(response.data);
  } catch (error) {
    console.error(error);
    res.status(500).send(`${error.message} Error in editing suggestion`);
  }
} );


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
      console.log("return from Community microservice, getting communities")
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in getting communityes");
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
      console.log("return from Community microservice, updating community")
      res.status(200).send(response.data);
    })
    .catch((error) => {
      console.log(error);
      res.status(500).send(error.message + " Error in updating community");
    });
});

// Port to listen on
app.listen(port, () => {
  console.log("API_React Server is running on port " + port);
});
