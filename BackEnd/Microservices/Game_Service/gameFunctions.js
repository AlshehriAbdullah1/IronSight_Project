const { db } = require("./firebase.js");
const gameFunctions = require("./gameFunctions.js");

const gameCollection = "Games";
var gameRef = db.collection(gameCollection);
const suggestCollection = "Suggestions";
var suggestRef = db.collection(suggestCollection);

// Add a new game to the database
async function add_game(object) {
  try {
    const game = await gameRef.add({
      Game_Name: object.Game_Name,
      Game_Name_Lower: object.Game_Name.toLowerCase(),
      Game_Description: object.Game_Description,
      Game_Genre: object.Game_Genre,
      Release_Date: object.Release_Date,
      Developer: object.Developer,
      Game_Img_Main: "",
      Game_Img_Banner: "",
    });
    return (Game_Id = game.id);
  } catch (err) {
    return err;
  }
}


// Get all games or a specific game by options from the database
async function get_games(options = {}) {
  try {
    // If Game_Id is present in options, fetch that specific game
    if (options.Game_Id) {
      const game = await gameRef.doc(options.Game_Id).get();
      // If the game does not exist, return an error
      if (!game.exists) {
        return "Game does not exist";
      }
      // Include the Game_Id in the returned data
      let gameData = { Game_Id: game.id, ...game.data() };
      delete gameData.Game_Name_Lower;
      return gameData;
    }

    // If no options are provided, fetch all games
    if (Object.keys(options).length === 0) {
      console.log('test1')
      const games = await gameRef.get();
      console.log('test2')
      // Include the Game_Id in the returned data
      return games.docs.map((doc) => {
        let gameData = { Game_Id: doc.id, ...doc.data() };
        delete gameData.Game_Name_Lower;
        return gameData;
    });
    }

    // If other options are provided, use them to filter games
    let query = gameRef;
    for (const key in options) {
      // Convert Age_Rating to a number if it's present in options
      const value = key === "Age_Rating" ? Number(options[key]) : options[key];
      query = query.where(key, "==", value);
    }
    var games = await query.get();
    if (games.empty) {
      return "No games found with the given options";
    }
    // Include the Game_Id in the returned data
    return games.docs.map((doc) => ({ Game_Id: doc.id, ...doc.data() }));
  } catch (err) {
    console.log("Error in get_games function: ", err.message);
    return err;
  }
} // end of get_games function

// edit a game in the database
async function edit_game(Game_Id, options) {
  try {
    const game = await gameRef.doc(Game_Id).get();
    // If the game does not exist, return an error
    if (!game.exists) {
      return "Game does not exist";
    }
    await gameRef.doc(Game_Id).update(options);
    const updatedGame = await gameRef.doc(Game_Id).get();
    // Include the Game_Id in the returned data
    return { Game_Id: Game_Id, ...updatedGame.data() };
  } catch (err) {
    return err;
  }
}

// delete a game from the database
async function delete_game(Game_Id) {
  try {
    const game = await gameRef.doc(Game_Id).get();
    // If the game does not exist, return an error
    if (!game.exists) {
      return "Game does not exist";
    }
    await gameRef.doc(Game_Id).delete();
    return "Success";
  } catch (err) {
    return err;
  }
} // end of delete_game function

// make a suggestion for a game
async function suggest_game(object) {
  try {
    const suggest = await suggestRef.add({
      Name : object.Name,
      Description : object.Description,
      Genre : object.Genre,
      State : "Pending"
    });
     return "Success";
  } catch (err) {
    return err;
  }
} // end of suggest_game function


// function to get all suggestions games from the database
async function get_suggestions() {
  try {
    const suggestions = await suggestRef.get();
    return suggestions.docs.map((doc) => ({ Suggestion_Id: doc.id, ...doc.data() }));
  } catch (err) {
    return err;
  }
} // end of get_suggestions function


// function to edit a suggestion game
async function edit_suggestion(Suggestion_Id, options) {
  try {
    const suggestion = await suggestRef.doc(Suggestion_Id).get();
    // If the suggestion does not exist, return an error
    if (!suggestion.exists) {
      return "Suggestion does not exist";
    }
    await suggestRef.doc(Suggestion_Id).update(options);
    const updatedSuggestion = await suggestRef.doc(Suggestion_Id).get();
    // Include the Suggestion_Id in the returned data
    return "Success"
  } catch (err) {
    return err;
  }
} // end of edit_suggestion function


module.exports = {
  add_game,
  get_games,
  edit_game,
  delete_game,
  suggest_game,
  get_suggestions,
  edit_suggestion
};
