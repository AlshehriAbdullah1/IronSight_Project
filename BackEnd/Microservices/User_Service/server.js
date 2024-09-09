const express = require("express");
const app = express();
const cors = require("cors");
const axios = require("axios");
const path = require("path");
const multer = require("multer");
const fs = require("fs");
const FormData = require("form-data");
require("dotenv").config({ path: "../../.env" });
const userFunctions = require("./userFunctions.js");
const logFunction = require("./logFunctions.js");

app.use(cors());
app.use(express.json());

const port = process.env.USER_PORT || 4002;
const MediaMicro = process.env.MEDIA_HOST || "http://localhost:4005";
const upload = multer({ dest: "uploads/" });

//////////////////////////////////////////////
// Endpoint for User Microservice
//////////////////////////////////////////////

// endpoint to test the connection to the firestore database
app.get("/usersM/test", async (req, res) => {
  try {
    const response = await userFunctions.test();
    res.send(response);
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});

// Endpoint to retrieve user information from the database using the given request query
// To retrieve all users, send an empty request query
// To retrieve a user with a specific parameter, send a request query with the parameter
app.get("/usersM/", async (req, res) => {
  try {
    const options = req.query;
    const response = await userFunctions.get_user(options);
    // Depending on the response, respond with the user information or an error message
    if (response) {
      res.send(response);
    } else {
      res.status(404).send("No matching documents");
    }
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});


// Endpoint to delete tournament information from the database using the given request parameter
app.delete("/usersM/:User_Id", async (req, res) => {
  try {
    const userID = req.params.User_Id;
    // Call the function to delete tournament information
    await userFunctions.delete_user(userID);
    console.log(`User : ${userID} is deleted`);
    res.send("Success");
  } catch (err) {
    console.error(err);
    res.status(500).send(err);
  }
});


// Endpoint to edit user information in the database using the given request parameter
app.put("/usersM/:User_Id", async (req, res) => {
  try {
    const userID = req.params.User_Id;
    let response = await userFunctions.edit_user(userID, req.body);
    res.send(response);
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});


// Endpoint to get all participated tournaments of a specific user
app.get("/usersM/:User_Id/participatedTournaments", async (req, res) => {
  const User_Id = req.params.User_Id;
  const Tour_Type = req.query.Tour_Type;
  try {
    const response = await userFunctions.get_participated_tournaments(User_Id, Tour_Type);

    // If there's no response, send a 404 status code
    if (!response) {
      res.status(404).json({ message: "No matching documents" });
    } else {
      res.json(response);
    }
  } catch (error) {
    // If there's an error, send a 500 status code and the error message
    res.status(500).json({ message: error.message });
  }
});


// Endpoint to add participated tournaments of a specific user
app.post("/usersM/addParticipatedTournaments", async (req, res) => {
  const userID = req.body.User_Id;
  var tournamentID = req.body.Tour_Id;
  var Tour_Type = req.body.Tour_Type;
  response = await userFunctions.add_participated_tournament(
    userID,
    tournamentID,
    Tour_Type
  );
  // Depending on thw response, respond with the tournament information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});



// Endpoint to remove a participated tournaments of a specific user
app.delete(
  "/usersM/:User_Id/removeParticipatedTournaments",
  async (req, res) => {
    const userID = req.params.User_Id;
    var tournamentID = req.query.Tour_Id;
    var Tour_Type = req.query.Tour_Type;
    response = await userFunctions.remove_participated_tournament(
      userID,
      tournamentID,
      Tour_Type
    );
    // Depending on the response, respond with the tournament information or an error message
    if (response) {
      res.send(response);
    } else {
      res.send("Error in removing particpant's participated tournament");
    }
  }
);




app.post("/usersM/sessions/oauth/google", async (req, res) => {
  try {
    const { code } = req.body;
    const response = await logFunction.googleLogin(code);
    // console.log("got user info of " + JSON.stringify(response.userRecordId));
    // console.log(
    //   "got the costum token of " + JSON.stringify(response.customToken)
    // );
    res.send(response);
  } catch (error) { }
});

app.post("/usersM/sessions/oauth/startgg", async (req, res) => {
  try {
    const { code } = req.body;
    // console.log(
    //   "received login post request for startgg in usersM with req.body: " +
    //   JSON.stringify(req.body)
    // );
    //console.log("code in api usersM: " + JSON.stringify(code.substring(0, 10)));

    const response = await logFunction.startGGLogin(code);
    //console.log("got user info of " + JSON.stringify(response.userRecord));
    // console.log(
    //   "got the costum token of " + JSON.stringify(response.customToken)
    // );
    res.send(response);
  } catch (error) { }
});


// sign up
// Initial signup endpoint
app.post("/usersM/signup", async (req, res) => {
  try {
    const { uid, email } = req.body;

    // call signUp function
    const signUpResponse = await logFunction.signup(uid, email);

    res.send(signUpResponse);
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});






// Endpoint to add a new commuinty to the user's followed communities
app.put("/usersM/:User_Id/followCommunity", async (req, res) => {
  const userID = req.params.User_Id;
  const community = req.body.Community_Id;
  // Call the function to add a new community to the user's followed communities
  await userFunctions
    .follow_community(userID, community)
    .then((response) => {
      res.send(response);
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});

// Endpoint to remove a community from the user's followed communities
app.delete("/usersM/:User_Id/unfollowCommunity", async (req, res) => {
  const userID = req.params.User_Id;
  const community = req.query.Community_Id;
  // Call the function to remove a community from the user's followed communities
  await userFunctions
    .unfollow_community(userID, community)
    .then((response) => {
      res.send(response);
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});

// Endpoint to get all the communities that the user is following
app.get("/usersM/:User_Id/followedCommunities", async (req, res) => {
  const userID = req.params.User_Id;
  // Call the function to get all the communities that the user is following
  await userFunctions
    .get_communities(userID)
    .then((response) => {
      res.send(response);
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});

// Endpoint to add_game_preferences to the user's game preferences
app.put("/usersM/:User_Id/addGamePreferences", async (req, res) => {
  const user_id = req.params.User_Id;
  const game_ids = req.body.Game_Ids;
  // Call the function to add_game_preferences to the user's game preferences
  await userFunctions
    .add_game_preferences(user_id, game_ids)
    .then((response) => {
      res.send(response);
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});

// Endpoint to remove_game_preferences from the user's game preferences
app.delete("/usersM/:User_Id/removeGamePreferences", async (req, res) => {
  const user_id = req.params.User_Id;
  const game_id = req.query.Game_Id
  // Call the function to remove_game_preferences from the user's game preferences
  await userFunctions
    .remove_game_preferences(user_id, game_id)
    .then((response) => {
      res.send(response);
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});

// Endpoint to get_game_preferences of the user
app.get("/usersM/:User_Id/gamePreferences", async (req, res) => {
  const user_id = req.params.User_Id;
  // Call the function to get_game_preferences of the user
  await userFunctions
    .get_game_preferences(user_id)
    .then((response) => {
      res.send(response);
    })
    .catch((err) => {
      console.log(err);
      res.send(err);
    });
});



// store the user image in the media service and store the image url in the database
app.post("/usersM/upload", upload.single("file"), (req, res) => {
  get_image_URL(req).then((url) => {
    // edit and Add the image url to the user in the database
    const updateObject = { [req.body.image_name]: url };
    userFunctions.edit_user(req.body.id, updateObject).then((result) => {
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
} // end of get_image_URL

app.listen(port, () => {
  console.log("User Server is running on port " + port);
});
