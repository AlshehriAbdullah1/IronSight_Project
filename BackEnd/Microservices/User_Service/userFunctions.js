const { db, firebase } = require("./firebase.js");

const userCollection = "Users";
var userRef = db.collection(userCollection);
const tournamentCollection = "Tournaments";
var tournamentRef = db.collection(tournamentCollection);
const gameCollection = "Games";
var gameRef = db.collection(gameCollection);
const communityCollection = "Community";
var communityRef = db.collection(communityCollection);

const ironSightClientSecret =
  process.env.IRON_SIGHT_CLIENT_SECRET; // Client secret for start gg oauth

// Function to replace the references in the object with the id
function replaceReferences(object) {
  for (const key in object) {
    if (object[key] instanceof Array) {
      object[key] = object[key].map((item) => {
        if (item._path && item._path.segments) {
          return item._path.segments[item._path.segments.length - 1];
        }
        return item;
      });
    } else if (typeof object[key] === "object" && object[key] !== null) {
      object[key] = replaceReferences(object[key]);
    }
  }
  return object;
}

// Function to get user data
async function get_user(options) {
  try {
    // If the request query contains an ID, retrieve the user information with that ID
    if (options.User_Id) {
      const userID = options.User_Id;
      // Call the function to get user information
      var user = await userRef.doc(userID).get();
      if (!user.exists) {
        console.log("No such document!");
      }
      user = user.data();
      // Include the user ID in the user object with the name 'User_Id'
      user.User_Id = userID;
      delete userID; // Remove the original ID property if
      delete user.User_Name_Lower; // Remove the User_Name_Lower property
      // call replaceReferences to replace the references in the object with the id
      user = replaceReferences(user);

      // Respond with user information
      return user;
    } else {
      // If the request query contains attributes, retrieve the tournament information with those attributes
      const keys = Object.keys(options);
      for (const key of keys) {
        userRef = userRef.where(key, "==", options[key]);
      }
      const snapshot = await userRef.get();

      if (snapshot.empty) {
        console.log("No matching documents.");
        return null;
      }

      // call replaceReferences to replace the references in the object with the id
      var documents = [];
      snapshot.forEach((doc) => {
        var user = doc.data();
        user.User_Id = doc.id;
        delete user.User_Name_Lower; // Remove the User_Name_Lower property
        //user = replaceReferences(user);
        documents.push(user);
      });
      return documents;
    }
  } catch (error) {
    console.error("Error getting user:", error.message);
    return { error: error.message };
  }
} // End of get_user function

// Function to delete user information from the database
async function delete_user(userID) {
  try {
    // Delete user information
    await userRef.doc(userID).delete();

    // Check if user still exists
    const userSnapshot = await userRef.doc(userID).get();

    if (userSnapshot.exists) {
      throw new Error("User was not deleted");
    }

    return "Success";
  } catch (error) {
    console.error(error);
    throw error;
  }
} // End of delete_user function

// Function to edit user information in the database
async function edit_user(User_Id, options) {
  try {
    //console.log(options)
    if (!User_Id) {
      throw new Error("User ID is required");
    }
    // Check if the user exists
    const userSnapshot = await userRef.doc(User_Id).get();
    if (!userSnapshot.exists) {
      throw new Error("User does not exist");
    }

    // check if the User_Name is unique
    if (options.User_Name) {
      // convert the User_Name to lowercase
      options.User_Name = options.User_Name.toLowerCase();
      const user = await userRef
        .where("User_Name", "==", options.User_Name)
        .get();
      if (!user.empty) {
        throw new Error("User name already exists");
      }
    }

    // Update the user information in the database
    await userRef.doc(User_Id).update(options);

    // Get the updated user information
    var user = await userRef.doc(User_Id).get();
    if (!user.exists) {
      throw new Error("User does not exist");
    }

    // replace the references in the object with the id
    user = replaceReferences(user.data());

    // include the user ID in the user object with the name 'User_Id'
    user.User_Id = User_Id;

    return user;
  } catch (error) {
    console.error(error);
    return { error: error.message };
  }
} // End of edit_user function

// Function to copy tournament
async function copy_user(userID) {
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  const user = userDoc.data();
  const newUser = await create_tournament(user);
  return newUser;
} // End of copy_user function

// Function to get all participated tournaments of a user
async function get_participated_tournaments(userID, tourType) {
  try {
    const userDoc = await userRef.doc(userID).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }

    const userTournamentsData = userDoc.data().Tournaments;
    // console.log(userTournamentsData)
    // If the user wants to get all tournaments
    if (!tourType) {
      let userTournaments = {};
      // Get all the tournaments
      // Loop through the userTournamentsData object to get each type of tournament
      for (const key in userTournamentsData) {
        userTournaments[key] = [];
        // Loop through the tournaments in the type iteself
        for (let i = 0; i < userTournamentsData[key].length; i++) {
          var tournamentID = userTournamentsData[key][i].id;
          var tournament = await tournamentRef.doc(tournamentID).get();
          if (!tournament.exists) {
            throw new Error("Tournament does not exist");
          }
          tournament = tournament.data();
          let organizer = await userRef.doc(tournament.Tournament_Org.id).get();
          if (!organizer.exists) {
            throw new Error("Organizer does not exist");
          }
          // Add the organizer's name and id to the tournament object
          tournament.Tournament_Org_Id = tournament.Tournament_Org.id;
          organizer = organizer.data();
          tournament.Tournament_Org = organizer.User_Name;

          tournament.Tour_Id = tournamentID;

          // // Check if the tournament is not pending
          // if(tournament.Results !== "Pending"  && key !== "organized" && key !== "followed"){
          //   await add_participated_tournament(userID, tournamentID, "previous");
          //   await remove_participated_tournament(userID, tournamentID, key);
          // }

          userTournaments[key].push(tournament);
        }
      }
      return userTournaments;
    }

    if (typeof tourType !== "string") {
      throw new Error("Invalid tournament type (must be a string)");
    }

    // Trim the string to get rid of any white spaces
    tourType = tourType.trim().toLowerCase();

    const validTypes = [
      "current",
      "previous",
      "upcoming",
      "organized",
      "followed",
    ];
    if (!validTypes.includes(tourType)) {
      throw new Error("Invalid tournament type");
    }
    var userTournaments =
      userTournamentsData[tourType.charAt(0).toUpperCase() + tourType.slice(1)];
    for (let i = 0; i < userTournaments.length; i++) {
      var tournamentID = userTournaments[i].id;
      var tournament = await tournamentRef.doc(tournamentID).get();
      if (!tournament.exists) {
        throw new Error("Tournament does not exist");
      }
      tournament = tournament.data();

      let organizer = await userRef.doc(tournament.Tournament_Org.id).get();
      if (!organizer.exists) {
        throw new Error("Organizer does not exist");
      }
      // Add the organizer's name and id to the tournament object
      tournament.Tournament_Org_Id = tournament.Tournament_Org.id;
      organizer = organizer.data();
      tournament.Tournament_Org = organizer.User_Name;
      tournament.Tour_Id = tournamentID;

      // // Check if the tournament is not pending and the type is not organized or followed
      // if(tournament.Results !== "Pending" && tourType !== "organized" && tourType !== "followed"){
      //   await add_participated_tournament(userID, tournamentID, "previous").then((res) => {
      //     if(res !== "Success"){
      //       console.log(res);
      //     }
      //   }
      //   );
      //   await remove_participated_tournament(userID, tournamentID, tourType).then((res) => {
      //     if(res !== "Success"){
      //       console.log(res);
      //     }
      //   });
      // }

      userTournaments[i] = tournament;
    }

    return userTournaments;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
} // End of get_participated_tournaments function

// Function to add a new participated tournament to the user
// The tournament will be added to the user's list of tournaments
// The function takes the user ID and the tournament ID
// The function also takes the type of the tournament (organized, followed, upcoming, current, previous)
// If the type is not provided, the function will determine the type of the tournament based on the status of the tournament
async function add_participated_tournament(userID, tournamentID, tourType) {
  try {
    // Check if user and tournament exist
    const [userDoc, tournamentDoc] = await Promise.all([
      userRef.doc(userID).get(),
      tournamentRef.doc(tournamentID).get(),
    ]);

    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }

    if (!tournamentDoc.exists) {
      throw new Error("Tournament does not exist");
    }

    const user = userDoc.data();
    const userTournaments = user.Tournaments;
    let tournament = tournamentRef.doc(tournamentID);

    // Validate and process tourType
    if (tourType) {
      tourType = tourType.trim().toLowerCase();
      const validTypes = [
        "organized",
        "followed",
        "upcoming",
        "current",
        "previous",
      ];
      if (!validTypes.includes(tourType)) {
        throw new Error("Invalid tournament type");
      }
      tourType = tourType.charAt(0).toUpperCase() + tourType.slice(1);
    } else {
      const tourData = tournamentDoc.data();
      tourType = getTournamentType(tourData);
    }

    // Check if user is already part of the tournament
    if (
      userTournaments[tourType].some(
        (tournament) => tournament.id === tournamentID
      )
    ) {
      throw new Error(`User is already part of the ${tourType} tournament`);
    }

    userTournaments[tourType].push(tournament);
    await userRef.doc(userID).update({ Tournaments: userTournaments });

    const tourList = await get_participated_tournaments(userID, tourType);
    return tourList;

    // // Replace references in the object with the id
    // var userTournamentsType = userTournaments[tourType];
    // userTournamentsType = userTournamentsType.map(
    //   (tournament) => tournament.id
    // );
    // // I want to return the object of the user tournrmanets type ids

    // var tourList = [];
    // for (let i = 0; i < userTournamentsType.length; i++) {
    //   tourList.push(tournamentRef.doc(userTournamentsType[i]).get());
    // }
    // tourList = await Promise.all(tourList).then((res) => {
    //   for (let i = 0; i < res.length; i++) {
    //     res[i] = res[i].data();
    //   }
    //   return res;
    // });

    // // get the owner community object
    // for (let i = 0; i < tourList.length; i++) {
    //   let organizer = await userRef.doc(tourList[i].Tournament_Org.id).get();
    //   if (!organizer.exists) {
    //     throw new Error("Organizer does not exist");
    //   }
    //   // Add the organizer's name and id to the tournament object
    //   tourList[i].Tournament_Org_Id = tourList[i].Tournament_Org.id;
    //   organizer = organizer.data();
    //   tourList[i].Tournament_Org = organizer.User_Name;
    // }

    // return tourList;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
}

function getTournamentType(tourData) {
  let tourType = "";
  let activeMatches = tourData.Matches.Active;
  let endedMatches = tourData.Matches.Ended;

  if (activeMatches.length == 0 && endedMatches.length == 0) {
    tourType = "Upcoming";
  } else if (activeMatches.length == 0 && endedMatches.length > 0) {
    tourType = "Previous";
  } else if (activeMatches.length > 0 && endedMatches.length > 0) {
    tourType = "Current";
  }

  if (tourType == "") {
    throw new Error("Invalid tournament status, it is empty");
  }

  return tourType.charAt(0).toUpperCase() + tourType.slice(1);
}

// Function to remove a participated tournament from the user
async function remove_participated_tournament(userID, tournamentID, tourType) {
  try {
    // Check if user and tournament exist
    const [userDoc, tournamentDoc] = await Promise.all([
      userRef.doc(userID).get(),
      tournamentRef.doc(tournamentID).get(),
    ]);

    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }

    if (!tournamentDoc.exists) {
      throw new Error("Tournament does not exist");
    }

    let userTournaments = userDoc.data().Tournaments;

    // Validate and process tourType
    if (tourType) {
      tourType = tourType.trim().toLowerCase();
      const validTypes = [
        "organized",
        "followed",
        "upcoming",
        "current",
        "previous",
      ];
      if (!validTypes.includes(tourType)) {
        throw new Error("Invalid tournament type");
      }
      tourType = tourType.charAt(0).toUpperCase() + tourType.slice(1);
    } else {
      const tourData = tournamentDoc.data();
      tourType = getTournamentType(tourData);
      if (!tourType || typeof tourType !== "string") {
        throw new Error("Invalid tournament type");
      }
    }

    // Check if user is part of the tournament
    if (
      !userTournaments[tourType].some(
        (tournament) => tournament.id === tournamentID
      )
    ) {
      throw new Error(`User is not part of the ${tourType} tournament`);
    }

    // Remove the tournament from the user's tournaments
    userTournaments[tourType] = userTournaments[tourType].filter(
      (tournament) => tournament.id !== tournamentID
    );
    await userRef
      .doc(userID)
      .update({ [`Tournaments.${tourType}`]: userTournaments[tourType] });

    const tourList = await get_participated_tournaments(userID, tourType);
    return tourList;

    // // Replace references in the object with the id
    // var userTournamentsType = userTournaments[tourType];
    // userTournamentsType = userTournamentsType.map(
    //   (tournament) => tournament.id
    // );
    // var tourList = [];
    // for (let i = 0; i < userTournamentsType.length; i++) {
    //   tourList.push(tournamentRef.doc(userTournamentsType[i]).get());
    // }
    // tourList = await Promise.all(tourList).then((res) => {
    //   for (let i = 0; i < res.length; i++) {
    //     res[i] = res[i].data();
    //   }
    //   return res;
    // });

    // // get the owner community object
    // for (let i = 0; i < tourList.length; i++) {
    //   let organizer = await userRef.doc(tourList[i].Tournament_Org.id).get();
    //   if (!organizer.exists) {
    //     throw new Error("Organizer does not exist");
    //   }
    //   // Add the organizer's name and id to the tournament object
    //   tourList[i].Tournament_Org_Id = tourList[i].Tournament_Org.id;
    //   organizer = organizer.data();
    //   tourList[i].Tournament_Org = organizer.User_Name;
    // }

    // return tourList;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
}

// Function to follow an account of a specific user
// (User 1 will have following added to them, and User 2 will have a new follower added to them)
async function follow_user(user1ID, user2ID) {
  try {
    if (user1ID === "" || user2ID === "") {
      throw new Error("User ID cannot be empty");
    }
    if (user1ID === user2ID) {
      throw new Error("User cannot follow themselves");
    }
    // Get the user information and check if the user exists
    const user1Doc = await userRef.doc(user1ID).get();
    if (!user1Doc.exists) {
      throw new Error("User 1 does not exist");
    }
    // Get the user information and check if the user exists
    const user2Doc = await userRef.doc(user2ID).get();
    if (!user2Doc.exists) {
      throw new Error("User 2 does not exist");
    }
    const user1 = user1Doc.data();
    const user2 = user2Doc.data();
    const user1Following = user1.Following;
    const user2Followers = user2.Followers;
    // Check if the user is already following the account
    if (
      user1Following.some(
        (following) => following.User_Name === user2.User_Name
      )
    ) {
      throw new Error("User is already following the account");
    }
    // Add the account to the user's list of following
    user1Following.push({
      User_Name: user2.User_Name,
      Display_Name: user2.Display_Name,
    });
    // Add the user to the account's list of followers
    user2Followers.push({
      User_Name: user1.User_Name,
      Display_Name: user1.Display_Name,
    });
    // Update the user's list of following
    await userRef.doc(user1ID).update({ Following: user1Following });
    // Update the account's list of followers
    await userRef.doc(user2ID).update({ Followers: user2Followers });
    return "Success";
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
}

// Function to unfollow an account of a specific user
// (User 1 will have following of user2 removed from them, and User 2 will have the follower user1 removed from them)
async function unfollow_user(user1ID, user2ID) {
  try {
    if (user1ID === "" || user2ID === "") {
      throw new Error("User ID cannot be empty");
    }
    if (user1ID === user2ID) {
      throw new Error("User cannot unfollow themselves");
    }
    // Get the user information and check if the user exists
    const user1Doc = await userRef.doc(user1ID).get();
    if (!user1Doc.exists) {
      throw new Error("User 1 does not exist");
    }
    // Get the user information and check if the user exists
    const user2Doc = await userRef.doc(user2ID).get();
    if (!user2Doc.exists) {
      throw new Error("User 2 does not exist");
    }
    const user1 = user1Doc.data();
    const user2 = user2Doc.data();
    const user1Following = user1.Following;
    const user2Followers = user2.Followers;
    // Check if the user is already following the account
    const followingIndex = user1Following.findIndex(
      (following) => following.User_Name === user2.User_Name
    );
    if (followingIndex === -1) {
      throw new Error("User is not following the account");
    }
    user1Following.splice(followingIndex, 1);
    // Check if the user is already a follower of the account
    const followerIndex = user2Followers.findIndex(
      (follower) => follower.User_Name === user1.User_Name
    );
    if (followerIndex === -1) {
      throw new Error("User is not a follower of the account");
    }
    user2Followers.splice(followerIndex, 1);
    // Update the user's list of following
    await userRef.doc(user1ID).update({ Following: user1Following });
    // Update the account's list of followers
    await userRef.doc(user2ID).update({ Followers: user2Followers });
    return "Success";
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
}

// Function to get the followers of a user
async function get_followers(userID) {
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("User does not exist");
  }
  const userFollowers = userDoc.data().Followers;
  return userFollowers;
}

// Function to get the following of a user
async function get_following(userID) {
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("User does not exist");
  }
  const userFollowing = userDoc.data().Following;
  return userFollowing;
}

// Function to add game preferences to a user
async function add_game_preferences(userID, gameIDs) {
  try {
    const userDoc = await userRef.doc(userID).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }
    const user = userDoc.data();
    const userPreferences = user.Preferences || [];

    // Loop through the gameIDs
    for (let i = 0; i < gameIDs.length; i++) {
      const gameID = gameIDs[i];
      const gameDoc = await gameRef.doc(gameID).get();
      if (!gameDoc.exists) {
        throw new Error(`Game with id ${gameID} does not exist`);
      }

      // Check if the user already has the game in their preferences
      if (userPreferences.find((game) => game.id === gameID)) {
        throw new Error(
          `User already has the game with id ${gameID} in their preferences`
        );
      }

      // Add the game id in the user's preferences
      userPreferences.push(gameID);
    }

    // Update the user's list of game preferences
    await userRef.doc(userID).update({ Preferences: userPreferences });

    // return the updated list of game preferences, only the game IDs, not the references
    return userPreferences;
  } catch (error) {
    return error.message;
  }
}

// Function to remove game preferences from a user
async function remove_game_preferences(userID, gameID) {
  try {
    const userDoc = await userRef.doc(userID).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }
    const gameDoc = await gameRef.doc(gameID).get();
    if (!gameDoc.exists) {
      throw new Error("Game does not exist");
    }
    const user = userDoc.data();
    const userPreferences = user.Preferences;
    // Check if the user has the game in their preferences
    var found = false;
    for (let i = 0; i < userPreferences.length; i++) {
      if (userPreferences[i] === gameID) {
        found = true;
        userPreferences.splice(i, 1);
        break; // Exit the loop after deleting the element
      }
    }
    if (!found) {
      throw new Error("User does not have the game in their preferences");
    }
    // Update the user's list of game preferences
    await userRef.doc(userID).update({ Preferences: userPreferences });
    // return the list of game preferences, only the game IDs, not the references
    return userPreferences;
  } catch (error) {
    return error.message;
  }
}

// Function to get the game preferences of a user
async function get_game_preferences(userID) {
  try {
    const userDoc = await userRef.doc(userID).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }
    var userPreferences = userDoc.data().Preferences;
    // return the list of game preferences, including all the game information with Game_Id included
    for (let i = 0; i < userPreferences.length; i++) {
      const gameID = userPreferences[i];
      var game = await gameRef.doc(gameID).get();

      // Include the Game_Id in the game data
      userPreferences[i] = { ...game.data(), Game_Id: gameID };
    }
    return userPreferences;
  } catch (error) {
    return error.message;
  }
}

// Function to add a new community to the followed communities of the user
// The community will be added to the communities of the user
// The function takes the user ID and the community ID (the community will be added as a reference)
async function follow_community(userID, communityID) {
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("User does not exist");
  }
  const communityDoc = await communityRef.doc(communityID).get();
  if (!communityDoc.exists) {
    throw new Error("Community does not exist");
  }
  const user = userDoc.data();
  const userCommunities = user.Communities;
  // Check if the user is already part of the community
  for (let i = 0; i < userCommunities.length; i++) {
    if (userCommunities[i].id === communityID) {
      throw new Error("User is already part of the community");
    }
  }
  // Add the community to the user's list of communities
  userCommunities.push(communityRef.doc(communityID));
  // Update the user's list of communities
  await userRef.doc(userID).update({ Communities: userCommunities });
  return "Success";
}

// Function to get the communities of a user
async function get_communities(userID) {
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("User does not exist");
  }
  const userCommunities = userDoc.data().Communities;
  // Return a list of ids of the communities
  for (let i = 0; i < userCommunities.length; i++) {
    userCommunities[i] = userCommunities[i].id;
  }
  // Return the list of communities of the user
  // After being retrieved, the communities will be converted to objects in the API gateway
  return userCommunities;
}

// Function to remove a community from the followed communities of the user
// The community will be removed from the communities of the user
// The function takes the user ID and the community ID
async function unfollow_community(userID, communityID) {
  // console.log(userID, communityID)
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("User does not exist");
  }
  const communityDoc = await communityRef.doc(communityID).get();
  if (!communityDoc.exists) {
    throw new Error("Community does not exist");
  }
  const user = userDoc.data();
  const userCommunities = user.Communities;
  // Check if the user is part of the community and remove it
  var found = false;
  for (let i = 0; i < userCommunities.length; i++) {
    if (userCommunities[i].id === communityID) {
      found = true;
      userCommunities.splice(i, 1);
      break; // Exit the loop after deleting the element
    }
  }
  if (!found) {
    throw new Error("User is not part of the community");
  }
  // Update the user's list of communities
  await userRef.doc(userID).update({ Communities: userCommunities });
  return "Success";
}

// test furnction to test the connection to the firestore database
async function test() {
  try {
    const user = await userRef.doc("test").get();
    if (!user.exists) {
      console.log("No such document!");
    } else {
      console.log("Document data:", user.data());
    }
  } catch (error) {
    console.error("Error getting document:", error);
  }
}

module.exports = {
  get_user,
  delete_user,
  copy_user,
  edit_user,
  get_participated_tournaments,
  add_participated_tournament,
  remove_participated_tournament,
  follow_user,
  unfollow_user,
  get_followers,
  get_following,
  add_game_preferences,
  remove_game_preferences,
  get_game_preferences,
  follow_community,
  get_communities,
  unfollow_community,
};
