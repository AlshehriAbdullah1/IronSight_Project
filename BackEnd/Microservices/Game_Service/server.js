const express = require("express");
const cors = require("cors");
const axios = require("axios");
const path = require("path");
const multer = require("multer");
const fs = require("fs");
const FormData = require("form-data");
require("dotenv").config({ path: "../../.env" });
const gameFunctions = require("./gameFunctions.js");

const app = express();
app.use(cors());
app.use(express.json());

const port = process.env.GAME_PORT || 4003;
const MediaMicro = process.env.MEDIA_HOST || "http://localhost:4005";
const upload = multer({ dest: "uploads/" });


// Add a new game to the database
app.post("/gamesM", (req, res) => {
  try {
    gameFunctions.add_game(req.body).then((Game_Id) => {
      res.send(Game_Id);
    });
  } catch (err) {
    res.send(err);
  }
});

// store the game image in the media service and store the image url in the database
app.post("/gamesM/upload", upload.single("file"), (req, res) => {
  get_image_URL(req).then((url) => {
    // edit and Add the image url to the game in the database
    const updateObject = { [req.body.image_name]: url };
    gameFunctions.edit_game(req.body.id, updateObject).then((result) => {
      res.send(result);
    });
  });
});

// Get all games or a specific game by options from the database
// To retrieve all games, send an empty request query
// To retrieve a game with a specific parameter, send a request query with the parameter
app.get("/gamesM", (req, res) => {
  var options = req.query;
  gameFunctions.get_games(options).then((result) => {
    res.send(result);
  });
});

// edit a game in the database
app.put("/gamesM/:Game_Id", (req, res) => {
  var Game_Id = req.params.Game_Id;
  gameFunctions.edit_game(Game_Id, req.body).then((result) => {
    res.send(result);
  });
});

// delete a game from the database
app.delete("/gamesM/:Game_Id", (req, res) => {
  var Game_Id = req.params.Game_Id;
  gameFunctions.delete_game(Game_Id).then((result) => {
    res.send(result);
  });
});

// make a suggestion for a game
app.post("/gamesM/suggestGame", (req, res) => {
  gameFunctions.suggest_game(req.body).then((result) => {
    res.send(result);
  });
});

// get all suggestions games from the database
app.get("/gamesM/suggestions", (req, res) => {
  gameFunctions.get_suggestions().then((result) => {
    res.send(result);
  });
});

// edit a suggestion game in the database
app.put("/gamesM/suggestions/:Suggestion_Id", (req, res) => {
  var Suggestion_Id = req.params.Suggestion_Id;
  gameFunctions.edit_suggestion(Suggestion_Id, req.body).then((result) => {
    res.send(result);
  });
});


////////////////////////////////////////////////////
// Small APIs functions for communication between microservices
////////////////////////////////////////////////////

// Get the game image url from the media service
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
  formData.append("collection", req.body.collection);
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

app.get("/hi", (req, res) => {
  res.send("Hello World");
});

app.listen(port, () => {
  console.log("Game Server is running on port " + port);
});
