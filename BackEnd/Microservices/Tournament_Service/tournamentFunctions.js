const { db, firebase } = require("./firebase.js");

const tournamentCollection = "Tournaments"; 
const userCollection = "Users";
const tournamentRef = db.collection(tournamentCollection);
const userRef = db.collection(userCollection);
const gameCollection = "Games";
const gameRef = db.collection(gameCollection);

const defaultBanner =
  "https://static-cdn.jtvnw.net/jtv_user_pictures/477c699a-413a-4200-bd91-ecf5c3800876-profile_banner-480.pnghttps://static-cdn.jtvnw.net/jtv_user_pictures/477c699a-413a-4200-bd91-ecf5c3800876-profile_banner-480.png";
const defaultThumbnail =
  "https://t4.ftcdn.net/jpg/04/74/44/85/360_F_474448512_w2NP8jcwfKKX9rIballVuxSqQK4rNRbE.jpg";
// Function to create tournament information in the database
async function create_tournament(options) {
  // Check if the required attributes are present in the request
  if (
    !options.Tournament_Name ||
    !options.Tournament_Org ||
    !options.Game_Name ||
    !options.Type ||
    !options.Date ||
    !options.Time ||
    !options.Max_Participants
  ) {
    throw new Error("Missing required attributes");
  }

  try {
    if (options.Tournament_Name.trim() == "") {
      throw new Error("Tournament Name cannot be empty");
    }
    // Check if the owner is a valid user
    var tournamentOrganizer = await userRef.doc(options.Tournament_Org).get();
    if (!tournamentOrganizer) {
      throw new Error("Tournament Organizer does not exist");
    }
    //Get the path of the tournament organizer
    tournamentOrganizer = tournamentOrganizer.ref;

    // Check if the tournament type is valid
    if (
      options.Type.trim().toLowerCase() != "on oremise" &&
      options.Type.trim().toLowerCase() != "online"
    ) {
      throw new Error("Invalid Tournament Type");
    }
    // Check if the tournament is on premise, the country and city must be provided
    if (options.Type.trim().toLowerCase() == "on premise") {
      options.Type = "On Premise";
      if (!options.Country || !options.City) {
        throw new Error(
          "Country and City must be provided for On Premise tournaments"
        );
      }
      let countryPart = options.Country;
      let cityPart = options.City;
      var combinedCountryCity = countryPart + ", " + cityPart;
    }
    // Check if the tournament is online, the location must be "Online"
    if (options.Type.trim().toLowerCase() == "online") {
      options.Type = "Online";
      var combinedCountryCity = "Online";
    }
    var prizePool = 0;
    if (options.Prize_Pool != null) {
      if (options.Prize_Pool < 0) {
        throw new Error("Prize Pool must be a positive number");
      }
      prizePool = options.Prize_Pool;
    }

    //Combine date and time to create a single date timestamp object
    let combinedDateTime = new Date(options.Date + " " + options.Time);

    if (combinedDateTime < firebase.firestore.Timestamp.now()) {
      throw new Error("Date and Time must be in the future");
    }
    if (options.Max_Participants != null) {
      if (options.Max_Participants < 2) {
        throw new Error("Max Participants must be at least 2");
      }
      if (options.Max_Participants % 2 != 0) {
        throw new Error("Max Participants must be an even number");
      }
      if (options.Max_Participants > 64) {
        throw new Error("Max Participants must be less than 64");
      }
    }

    // Access the tournaments collection in the database and add the new tournament's information
    const tournament = await db.collection(tournamentCollection).add({
      Description: options.Description || "This tournament has no description",
      Location: combinedCountryCity,
      Max_Participants: parseInt(options.Max_Participants),
      Prize_Pool: prizePool + " SAR",
      Registration_Link: options.Registration_Link || "",
      Results: "Pending",
      Streaming_Link: options.Streaming_Link || "",
      Date_Time: combinedDateTime,
      Tournament_Name: options.Tournament_Name,
      Tournament_Name_Lower: options.Tournament_Name.toLowerCase(),
      //Added the id of the tournament organizer to the tournament object just so it doesn't break
      Tournament_Org: tournamentOrganizer,
      Participants: [],
      Matches: {
        Active: [],
        Ended: [],
      },
      Date_Created: firebase.firestore.FieldValue.serverTimestamp(),
      Game_Name: options.Game_Name,
      Type: options.Type,
      In_House: options.In_House || false,
      Banner: options.Banner || defaultBanner,
      Thumbnail: options.Thumbnail || defaultThumbnail,
      isStarted: false,
    });
    const tourObject = await get_tournament({ Tour_Id: tournament.id });
    return tourObject;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
} // End of create_tournament

async function get_tournament(options) {
  var tournamentRef = db.collection(tournamentCollection);
  // If the request query contains an ID, retrieve the tournament information with that ID
  if (options.Tour_Id) {
    const tournamentID = options.Tour_Id;
    // Call the function to get tournament information
    const tournament = (await tournamentRef.doc(tournamentID).get()).data();
    // If no tournament is found with the given ID, respond with an error message
    if (!tournament) {
      console.log(`No tournament found with ID: ${tournamentID}`);
      return null;
    }
    // Include the tournament ID in the tournament object with the name 'tour_id'
    tournament.Tour_Id = tournamentID;
    delete tournamentID; // Remove the original ID property if necessary
    delete tournament.Tournament_Name_Lower; // Remove the original Tournament_Org property if necessary
    // Respond with tournament information
    var orgName = await userRef.doc(tournament.Tournament_Org.id).get();
    if (!orgName.exists) {
      throw new Error("Tournament Organizer does not exist");
    }
    // Add the ID of the tournament organizer to the tournament object
    tournament.Tournament_Org_Id = tournament.Tournament_Org.id;

    tournament.Tournament_Org = orgName.data().User_Name;
    return tournament;
  } else {
    // If the request query contains attributes, retrieve the tournament information with those attributes
    const keys = Object.keys(options);
    for (const key of keys) {
      tournamentRef = tournamentRef.where(key, "==", options[key]);
    }
    const snapshot = await tournamentRef.orderBy("Date_Created", "desc").get();

    if (snapshot.empty) {
      console.log("No matching documents.");
      return null;
    }
    // Map documents to include the ID with the name 'tour_id'
    const documents = await Promise.all(
      snapshot.docs.map(async (doc) => {
        const data = doc.data();
        data.Tour_Id = doc.id;
        var orgName = await userRef.doc(data.Tournament_Org.id).get();
        if (!orgName.exists) {
          throw new Error("Tournament Organizer does not exist");
        }
        data.Tournament_Org_Id = data.Tournament_Org.id;
        data.Tournament_Org = orgName.data().User_Name;
        delete data.Tournament_Name_Lower; // Remove the original Tournament_Org property if necessary
        return data;
      })
    );
    return documents;
  }
} // End of get_tournament

// Function to delete tournament information from the database
async function delete_tournament(tournamentID) {
  // Access the tournaments collection in the database
  const tournamentRef = db.collection(tournamentCollection);
  // Delete tournament information
  await tournamentRef.doc(tournamentID).delete();
  if ((await tournamentRef.doc(tournamentID).get()).exists) {
    throw new Error("Tournament was not deleted");
  }
  return "Success";
} // End of delete_tournament

// Function to start the tournament
async function start_tournament(tour_id) {
  const tournamentDoc = await tournamentRef.doc(tour_id).get();
  
  if (!tournamentDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  try {
    // To check if the tournament has already started
    // ****IF YOU WANT TO TEST THE FUNCTIONALITY OF THIS FUNCTION, COMMENT THE FOLLOWING LINE****

    if(tournamentDoc.data().isStarted){
      throw new Error("Tournament has already started");
    }
    if (tournamentDoc.data().Matches.Active.length > 0) {
      throw new Error("Tournament has already started");
    }
    const Max_Participants = tournamentDoc.data().Max_Participants;

    // To check if the tournament has already ended
    if (tournamentDoc.data().Matches.Ended.length == Max_Participants - 1) {
      throw new Error("Tournament has already ended");
    }

    const currentParticipants = tournamentDoc.data().Participants || [];
    // To check if the number of participants is enough to start the tournament
    if (currentParticipants.length < 2) {
      throw new Error("Not enough participants to start the tournament");
    }
    // To check if the number of participants is too much to start the tournament
    if (currentParticipants.length > Max_Participants) {
      throw new Error("Too many participants to start the tournament");
    }
    // To check if the number of participants is an odd number
    if (currentParticipants.length % 2 != 0) {
      throw new Error("Number of participants must be an even number");
    }

    const matches = {
      Active: [],
      Ended: [],
    };
       // To create the matches array initally
  for (let index = 0; index < Max_Participants - 1; index++) {
    matches["Active"].push({
      Player1: {
        Id: "Pending",
        Status: "Pending",
      },
      Player2: {
        Id: "Pending",
        Status: "Pending",
      },
    });

    
  }

  //  for (
  //   let index = 0, j = 0;
  //   j < currentParticipants.length - 1;
  //   index = index + 1, j = j + 2
  // ) {
  //   // console.log(currentParticipants[index]);
  //   matches["Active"][index].Player1 = {
  //     Id: currentParticipants[j].Participant_Id,
  //     Name: currentParticipants[j].Participant_Name,
  //     Status: "Pending",
  //   };
  //   matches["Active"][index].Player2 = {
  //     Id: currentParticipants[j + 1].Participant_Id,
  //     Name: currentParticipants[j + 1].Participant_Name,
  //     Status: "Pending",
  //   };
  // }
    for (
      let matchIndex = 0, participantIndex = 0;
      participantIndex < currentParticipants.length-1 ;
      matchIndex = matchIndex + 1, participantIndex = participantIndex + 2
    ) {
      // Check the ID of the participants
      if (
        !currentParticipants[participantIndex].Participant_Id ||
        !currentParticipants[participantIndex + 1].Participant_Id
      ) {
        throw new Error("Participant ID not found");
      }

      // Check if the participants are the same
      if (
        currentParticipants[participantIndex].Participant_Id ===
        currentParticipants[participantIndex + 1].Participant_Id
      ) {
        throw new Error("Participants cannot be the same");
      }

      // Check that each participant is a user in the database
      const player1 = await userRef
        .doc(currentParticipants[participantIndex].Participant_Id)
        .get();
      const player2 = await userRef
        .doc(currentParticipants[participantIndex + 1].Participant_Id)
        .get();
      if (!player1.exists || !player2.exists) {
        throw new Error("Participant not found");
      }
      // change the state of isStarted to true
      await tournamentRef.doc(tour_id).update({ isStarted: true });

      // Create a match object with the two participants
      matches["Active"][matchIndex].Player1 ={
        Id: currentParticipants[participantIndex].Participant_Id,
        Status: "Pending",
      };

      matches["Active"][matchIndex].Player2 ={
        Id: currentParticipants[participantIndex + 1].Participant_Id,
        Status: "Pending",
      };
       
      
    }
    // Update the tournament document with the matches array
    await tournamentRef
      .doc(tour_id)
      .update({ Matches: matches, Results: "Pending" });

    // change the state of isStarted to true
    await tournamentRef.doc(tour_id).update({ isStarted: true });
    
    var returnedMatches= await get_matches(tour_id);
    var players = tournamentDoc.data().Participants;
    // Create a new object that holds the returned matches and the participants
    var tournamentData = {
      Matches: returnedMatches,
      Participants: players,
    };
    return tournamentData;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
} // End of start_tournament

// Function to handle match winner logic and update the matches array
async function match_win(tour_id, winner_id) {
  var tournament = await tournamentRef.doc(tour_id).get();
  if (!tournament.exists) {
    throw new Error("Tournament does not exist");
  }
  tournament = tournament.data();
  // Access the Matches collection in the database
  const matchesRef = tournament.Matches;
  // first check if the tournament has ended
  if (
    matchesRef["Active"].length == 0 &&
    matchesRef["Ended"].length == tournament.Max_Participants - 1
  ) {
    throw new Error("Tournament has already ended");
  }

  // Find the match that the winner is in
  const match = matchesRef["Active"].find(
    (match) => match.Player1.Id === winner_id || match.Player2.Id === winner_id
  );
  if (!match) {
    throw new Error(
      "No Active Match Found, Maybe the tournament is over or it has not started yet!"
    );
  }
  // Check if the player is in the match
  if (!match.Player1 || !match.Player2) {
    throw new Error("Player not found");
  }
  // Check if the match is complete
  if (match.Player1.Id === "Pending" || match.Player2.Id === "Pending") {
    throw new Error("Match is not complete!"); // no 2 players in the match
  }
  // Check if the match has already ended
  if (match.Player1.Status === "Winner" || match.Player2.Status === "Winner") {
    throw new Error("Match has already ended");
  }
  // Check if the winner is in the match
  if (match.Player1.Id === winner_id) {
    match.Player1.Status = "Winner";
    match.Player2.Status = "Loser";
    var playerWinner = match.Player1;
    var loser_id = match.Player2.Id;
  } else if (match.Player2.Id === winner_id) {
    match.Player2.Status = "Winner";
    match.Player1.Status = "Loser";
    var playerWinner = match.Player2;
    var loser_id = match.Player1.Id;
  }
  // Create a deep copy of the match object
  let matchCopy = JSON.parse(JSON.stringify(match));

  // Push the copy to matchesRef["Ended"]
  matchesRef["Ended"].push(matchCopy);
  // Add the winner to the next match
  for (let index = 0; index < matchesRef["Active"].length; index++) {
    // if there is an empty slot in the match's first spot (player1)
    if (matchesRef["Active"][index].Player1.Id === "Pending") {
      matchesRef["Active"][index].Player1 = playerWinner;
      matchesRef["Active"][index].Player1.Status = "Pending";
      break;
    }

    // if there is an empty slot in the match's second spot (player2)
    else if (matchesRef["Active"][index].Player2.Id === "Pending") {
      matchesRef["Active"][index].Player2 = playerWinner;
      matchesRef["Active"][index].Player2.Status = "Pending";
      break;
    }
  }
  // remove the match from the active matches
  matchesRef["Active"].splice(matchesRef["Active"].indexOf(match), 1);
  // call a function to update number of loss and wins for the players
  await updateRecord(tour_id, winner_id, loser_id);
  await tournamentRef.doc(tour_id).update({ Matches: matchesRef });
  // Check if the tournament has ended
  if (
    matchesRef["Active"].length == 0 &&
    matchesRef["Ended"].length == tournament.Max_Participants - 1
  ) {
    console.log("Tournament has ended");
    // call a function to get the result of the tournament
    await tournament_result(tour_id);
    // call a function to add badges to the first,second and third place
    await add_badges(tour_id, "previous");
    

    var returnedMatches= await get_matches(tour_id);
    var players = tournament.Participants;
    // Create a new object that holds the returned matches and the participants
    var tournamentData ={
      Matches: returnedMatches,
      Participants: players,
    };
    return tournamentData;
  }
  return await get_matches(tour_id);
} // End of match_win

// Function to get the matches of a tournament
async function get_matches(tournamentID) {
  const tournamentDoc = await tournamentRef.doc(tournamentID).get();
  if (!tournamentDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  try {
    const tournament = tournamentDoc.data();
    var matches = tournament.Matches;
    // First check if the matches array is empty
    if (matches.Active.length == 0 && matches.Ended.length == 0) {
      return matches;
    }
    // by using this function, we can get the user information of the players in the matches
    const addUserDataToMatches = async (matchArray) => {
      // Loop through the matches array
      for (let i = 0; i < matchArray.length; i++) {
        var player1 = matchArray[i].Player1;
        var player2 = matchArray[i].Player2;

        // Get the user information of the players
        if(player1.Id=='Pending'|| player2.Id=='Pending'){
          break;
        }
        var user1 = await userRef.doc(player1.Id).get();
        var user2 = await userRef.doc(player2.Id).get();

        if (!user1.exists || !user2.exists) {
          throw new Error("User does not exist");
        }
        user1 = user1.data();
        user2 = user2.data();
        // Add the user information to the player object
        player1.User_Name = user1.User_Name;
        player1.Profile_Picture = user1.Profile_Picture;
        player1.Display_Name = user1.Display_Name;
        // Add the user information to the player object
        player2.User_Name = user2.User_Name;
        player2.Profile_Picture = user2.Profile_Picture;
        player2.Display_Name = user2.Display_Name;
      }
    };
    // Call the function to add user information to the matches
    await Promise.all([
      addUserDataToMatches(matches.Active),
      addUserDataToMatches(matches.Ended),
    ]);
    return matches;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
} // End of get_matches

// Function to add badges to a user
async function add_badges(tournamentID, tourType) {
  try {
    const tournamentDoc = await tournamentRef.doc(tournamentID).get();
    if (!tournamentDoc.exists) {
      throw new Error("Tournament does not exist");
    }

    if (!tourType) {
      var tourStatus = await tournamentRef.doc(tournamentID).get();
      if (!tourStatus.exists) {
        throw new Error("Tournament does not exist");
      }
      let activeMatches = tourStatus.data().Matches.Active;
      let endedMatches = tourStatus.data().Matches.Ended;
      var tourType = "";
      tourStatus = tourStatus.data();
      // If the ended matches are not empty and the started matches are empty, the tournament is previous
      if (activeMatches.length == 0 && endedMatches.length > 0) {
        tourType = "Previous";
      } else {
        throw new Error("Tournament is not over yet");
      }
    }

    tourType = tourType.trim();
    if (tourType.toLowerCase() !== "previous") {
      throw new Error("Tournament must be over to add badges");
    }

    var tournamentEnded = tournamentDoc.data().Matches.Ended;
    // Get the last 3 matches of the tournament to determine the first, second, and third place
    var matches = tournamentEnded.slice(-3);
    // if the tournament has only 2 matches, the third place will be the loser of the first match
    if (matches.length < 3) {
      // award the first and second place
      var [secondPlace] = matches.map((match) => {
        return match.Player1.Status === "Loser" ? match.Player1 : match.Player2;
      });
      var [firstPlace] = matches.map((match) => {
        return match.Player1.Status === "Winner"
          ? match.Player1
          : match.Player2;
      });
      var places = [firstPlace, secondPlace];
      var placeNames = ["First_Place", "Second_Place"];
      for (let i = 0; i < places.length; i++) {
        var placeDoc = await userRef.doc(places[i].Id).get();
        if (!placeDoc.exists) {
          throw new Error(`${places[i].Id} : does not exist`);
        }
        var placeBadges = placeDoc.data().Badges || {
          First_Place: 0,
          Second_Place: 0,
          Third_Place: 0,
        };
        placeBadges[placeNames[i]] = (placeBadges[placeNames[i]] || 0) + 1;
        await userRef.doc(places[i].Id).update({ Badges: placeBadges });
      }
      return "Success";
    }

    // This array will assign the losers of the the matches to their respective places
    var [thirdPlace1, thirdPlace2, secondPlace] = matches.map((match) => {
      return match.Player1.Status === "Loser" ? match.Player1 : match.Player2;
    });
    // thirdPlace1 is the loser of the first match which makes him 4th place
    // thirdPlace2 is the loser of the second match which makes him 3rd place

    // The first place will be the winner of the last match
    var firstPlace =
      matches[2].Player1.Status === "Winner"
        ? matches[2].Player1
        : matches[2].Player2;

    var places = [firstPlace, secondPlace, thirdPlace1, thirdPlace2];
    var placeNames = [
      "First_Place",
      "Second_Place",
      "Third_Place",
      "Third_Place",
    ];

    for (let i = 0; i < places.length; i++) {
      var placeDoc = await userRef.doc(places[i].Id).get();
      if (!placeDoc.exists) {
        throw new Error(`${places[i].Id} : does not exist`);
      }
      var placeBadges = placeDoc.data().Badges || {
        First_Place: 0,
        Second_Place: 0,
        Third_Place: 0,
      };
      placeBadges[placeNames[i]] = (placeBadges[placeNames[i]] || 0) + 1;
      await userRef.doc(places[i].Id).update({ Badges: placeBadges });
    }

    return "Success";
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
}

// Function to get the badges of a user
async function get_badges(userID) {
  const userDoc = await userRef.doc(userID).get();
  if (!userDoc.exists) {
    throw new Error("User does not exist");
  }
  if (!userDoc.data().Badges) {
    return {
      First_Place: 0,
      Second_Place: 0,
      Third_Place: 0,
    };
  }
  const userBadges = userDoc.data().Badges;
  return userBadges;
}

async function updateRecord(tour_id, winner_id, loser_id) {
  const tournamentRef = db.collection(tournamentCollection);

  const currentParticipants =
    (await tournamentRef.doc(tour_id).get()).data().Participants || [];

  // Update the record of the winner and loser
  for (let index = 0; index < currentParticipants.length; index++) {
    if (currentParticipants[index].Participant_Id === winner_id) {
      currentParticipants[index].Record.Wins =
        currentParticipants[index].Record.Wins + 1;
    } else if (currentParticipants[index].Participant_Id === loser_id) {
      currentParticipants[index].Record.Losses =
        currentParticipants[index].Record.Losses + 1;
    }
  }
  await tournamentRef
    .doc(tour_id)
    .update({ Participants: currentParticipants });
} // End of updateRecord

// Function to edit tournament information in the database
async function edit_tournament(tournamentID, options) {
  try {
    // Check if the tournament exists
    const tournamentDoc = await tournamentRef.doc(tournamentID).get();
    if (!tournamentDoc.exists) {
      throw new Error("Tournament does not exist");
    }
    var tournament = tournamentDoc.data();
    // Check if the tournament has already started
    if (tournament.Date_Time < firebase.firestore.Timestamp.now()) {
      throw new Error("Tournament has already started");
    }
    // Check if the tournament is over
    if (
      tournament.Matches.Active.length == 0 &&
      tournament.Matches.Ended.length == tournament.Max_Participants - 1
    ) {
      throw new Error("Tournament has already ended");
    }

    if (options.Tournament_Name != null) {
      if (options.Tournament_Name.trim() == "") {
        throw new Error("Tournament Name cannot be empty");
      }
    }
    if (options.Type != null) {
      if (
        options.Type.trim().toLowerCase() != "on premise" &&
        options.Type.trim().toLowerCase() != "online"
      ) {
        throw new Error("Invalid Tournament Type");
      }
    }

    if (options.Banner != null) {
      if (options.Banner.trim() == "") {
        options.Banner = defaultBanner;
      }
    }
    if (options.Thumbnail != null) {
      if (options.Thumbnail.trim() == "") {
        options.Thumbnail = defaultThumbnail;
      }
    }

    // Combine date and time to create a single date timestamp object
    if (options.Date != null && options.Time != null) {
      let combinedDateTime = new Date(options.Date + " " + options.Time);
      delete options.Time;
      delete options.Date;
      options.Date_Time = combinedDateTime;
    }
    // Combine country and city to create a single location string
    if (options.Country != null && options.City != null) {
      let countryPart = options.Country;
      let cityPart = options.City;
      delete options.City;
      delete options.Country;
      options.Location = countryPart + ", " + cityPart;
    }
    if (options.Prize_Pool != null) {
      options.Prize_Pool = options.Prize_Pool + " SAR";
    }
    if (options.Max_Participants != null) {
      if (options.Max_Participants < 2) {
        throw new Error("Max Participants must be at least 2");
      }
      if (options.Max_Participants % 2 != 0) {
        throw new Error("Max Participants must be an even number");
      }
      if (options.Max_Participants > 64) {
        throw new Error("Max Participants must be less than 64");
      }
      options.Max_Participants = parseInt(options.Max_Participants);
    }
    if (options.Description != null) {
      if (options.Description.trim() == "") {
        options.Description = "This tournament has no description";
      }
    }
    if (options.Type != null) {
      if (options.Type.trim().toLowerCase() == "on premise") {
        options.Type = "On Premise";
      }
      if (options.Type.trim().toLowerCase() == "online") {
        options.Type = "Online";
        options.Location = "Online";
      }
    }

    await tournamentRef.doc(tournamentID).update(options);
    const tour = await get_tournament({ Tour_Id: tournamentID });
    if (!tour) {
      throw new Error("Tournament does not exist");
    }
    return tour;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
} // End of edit_tournament

// Function to remove a participant from a tournament
async function remove_participant(tour_id, participant_id) {
  if (!participant_id || !tour_id) {
    throw new Error("Participant ID and Name must be provided");
  }
  // Remove participant
  const tournamentDoc = await tournamentRef.doc(tour_id).get();
  if (!tournamentDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  var tournament = tournamentDoc.data();
  const currentParticipants = tournament.Participants || [];
  // Check if the participant is part of the tournament
  var participant = currentParticipants.find(
    (participant) => participant.Participant_Id === participant_id
  );
  if (!participant) {
    throw new Error("Participant is not part of the tournament");
  }
  // Check if the tournament has already started
  if (tournament.Date_Time < firebase.firestore.Timestamp.now()) {
    throw new Error("Tournament has already started");
  }
  // Remove the participant from the tournament
  const newParticipants = currentParticipants.filter(
    (participant) => participant.Participant_Id !== participant_id
  );
  // Update the document in the database
  await tournamentRef.doc(tour_id).update({ Participants: newParticipants });
  return await get_participants(tour_id);
} // End of remove_participant

// Function to register a participant to a tournament
async function register_participant(tour_id, participant_id) {
  try {
    if (!participant_id || !tour_id) {
      throw new Error("Participant ID and Name must be provided");
    }
    // Register participant
    const tournamentDoc = await tournamentRef.doc(tour_id).get();
    if (!tournamentDoc.exists) {
      throw new Error("Tournament does not exist");
    }
    var tournament = tournamentDoc.data();
    //check the participant
    var user = await userRef.doc(participant_id).get();
    if (!user.exists) {
      throw new Error("Participant does not exist");
    }
    var user = user.data();

    const currentParticipants = tournament.Participants || [];
    // Check if the participant is already part of the tournament
    for (let index = 0; index < currentParticipants.length; index++) {
      if (currentParticipants[index].Participant_Id === participant_id) {
        throw new Error("Participant is already part of the tournament");
      }
    }
    // Check if the tournament is full
    if (currentParticipants.length >= tournament.Max_Participants) {
      throw new Error("Tournament is full");
    }
    // Check if the tournament has already started
    if (tournament.Date_Time < firebase.firestore.Timestamp.now()) {
      throw new Error("Tournament has already started");
    }
    // Add new participant
    const participant = {
      Participant_Id: participant_id,
      Record: {
        Wins: 0,
        Losses: 0,
      },
    };
    currentParticipants.push(participant);
    // Update the document in the database
    await tournamentRef
      .doc(tour_id)
      .update({ Participants: currentParticipants });

    const participantsList = await get_participants(tour_id);
    return participantsList;
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
} // End of register_participant

// for testing purposes
async function get_participants(tournamentID) {
  const tournamentDoc = await tournamentRef.doc(tournamentID).get();
  if (!tournamentDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  try {
    const tournament = tournamentDoc.data();
    var participants = tournament.Participants;

    // First check if the participants array is empty
    if (participants.length == 0) {
      return [];
    }
    // Get the participants of the tournament and add their user information
    return Promise.all(
      participants.map(async (participant) => {
        // Get the user information of the participant
        let user = await userRef.doc(participant.Participant_Id).get();
        if (!user.exists) {
          throw new Error("User does not exist");
        }
        user = user.data();
        return {
          Participant_Id: participant.Participant_Id,
          Record: participant.Record,
          // Add the user information to the participant object
          Participant_User_Name: user.User_Name,
          Participant_Profile: user.Profile_Picture,
          Participant_Display_Name: user.Display_Name,
        };
      })
    );
  } catch (error) {
    console.error("Caught error: ", error);
    throw error;
  }
}
// End of get_participants

// function to copy tournament
// This is for testing purposes only
async function copy_tournament(tour_id, doc_id) {
  const tournamentRef = db.collection(tournamentCollection);
  const tournamentDoc = await tournamentRef.doc(tour_id).get();
  if (!tournamentDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  const tournament = tournamentDoc.data();
  const newTournament = await tournamentRef.doc(doc_id).update({
    Description: tournament.Description,
    Location: tournament.Location,
    Max_Participants: tournament.Max_Participants,
    Prize_Pool: tournament.Prize_Pool,
    Registration_Link: tournament.Registration_Link,
    Results: "Pending",
    Streaming_Link: tournament.Streaming_Link,
    Date_Time: tournament.Date_Time,
    Tournament_Name: tournament.Tournament_Name,
    Tournament_Name_Lower: tournament.Tournament_Name.toLowerCase(),
    Tournament_Org: tournament.Tournament_Org,
    Participants: [],
    Matches: {
      Active: [],
      Ended: [],
    },
    Date_Created: firebase.firestore.FieldValue.serverTimestamp(),
    Game_Name: tournament.Game_Name,
    Type: tournament.Type,
    In_House: tournament.In_House,
    Banner: tournament.Banner,

    Thumbnail: tournament.Thumbnail,
  });
  // const newTournamentDoc = await tournamentRef.doc(newTournament.id).get();
  // if (!newTournamentDoc.exists) {
  //   throw new Error("Tournament does not exist");
  // }
  // return newTournament;
  return "Success";
}

// Function to get the result of the tournament
async function tournament_result(tour_id) {
  const tournamentDoc = await tournamentRef.doc(tour_id).get();
  if (!tournamentDoc.exists) {
    throw new Error("Tournament does not exist");
  }
  const tournamentData = tournamentDoc.data();

  // To check if the tournament has not ended yet
  if (
    tournamentData.Matches.Active.length > 0 ||
    tournamentData.Matches.Ended.length == 0
  ) {
    throw new Error("Tournament has not ended yet");
  }
  if (tournamentData.Matches.Ended < tournamentData.Max_Participants - 1) {
    throw new Error("Tournament has not ended yet");
  }
  // Get the result of the tournament by accessing the last match in the ended matches array
  // And getting the winner of that match

  var lastMatch =
    tournamentData.Matches.Ended[tournamentData.Matches.Ended.length - 1];
  var tournamentResult = {};
  if (lastMatch.Player1.Status == "Winner") {
    tournamentResult = lastMatch.Player1;
  } else {
    tournamentResult = lastMatch.Player2;
  }
  // Update the tournament document with the result of the tournament
  await tournamentRef.doc(tour_id).update({ Results: tournamentResult.Id });
  return tournamentResult;
}

// Function to check the Date_Time of the tournament to see if it is ready to start
// The Date_Time is an attribute of the tournament object
// The Date_Time is a timestamp object
// The isStarted is a boolean attribute of the tournament object
// the function will get the a list of tournaments that are ready to start
// the function will then start the tournament
// async function check_to_start() {
//   const snapshot = await tournamentRef
//     .where("Date_Time", "<=", firebase.firestore.Timestamp.now())
//     .where("isStarted", "==", false)
//     .get();
//   if (snapshot.empty) {
//     console.log("No matching documents.");
//     return null;
//   }
//   Promise.all(
//     snapshot.docs.map(async (doc) => {
//       const data = doc.data();
//       data.Tour_Id = doc.id;
//       start_tournament(data.Tour_Id);
//     })
//   );
//   return "success"
// } // End of check_to_start
async function check_to_start() {
  const threeHoursMillis = 3 * 60 * 60 * 1000; // 3 hours in milliseconds
  const currentTimePlusThreeHours = firebase.firestore.Timestamp.now().toMillis() + threeHoursMillis;

  const snapshot = await tournamentRef
    .where("Date_Time", "<=", firebase.firestore.Timestamp.fromMillis(currentTimePlusThreeHours))
    .where("isStarted", "==", false)
    .get();
  if (snapshot.empty) {
    console.log("No matching documents.");
    return null;
  }
  Promise.all(
    snapshot.docs.map(async (doc) => {
      const data = doc.data();
      data.Tour_Id = doc.id;
      start_tournament(data.Tour_Id);
    })
  );
  return "success"
} // End of check_to_start

// Function to get tournaments with the same game name
async function get_tournaments_by_game(gameName) {
  const snapshot = await tournamentRef
  .where("Game_Name", "==", gameName)
  .get();
  if (snapshot.empty) {
    console.log("No matching documents.");
    return null;
  }
  // Map documents to include the ID with the name 'tour_id'
  const documents = await Promise.all(
    snapshot.docs.map(async (doc) => {
      const data = doc.data();
      data.Tour_Id = doc.id;
      var orgName = await userRef.doc(data.Tournament_Org.id).get();
      if (!orgName.exists) {
        throw new Error("Tournament Organizer does not exist");
      }
      data.Tournament_Org_Id = data.Tournament_Org.id;
      data.Tournament_Org = orgName.data().User_Name;
      delete data.Tournament_Name_Lower; // Remove the original Tournament_Org property if necessary
      return data;
    })
  );
  console.log(documents);
  return documents;
} // End of get_tournaments_by_game

module.exports = {
  create_tournament,
  get_tournament,
  delete_tournament,
  start_tournament,
  match_win,
  edit_tournament,
  remove_participant,
  register_participant,
  copy_tournament,
  tournament_result,
  check_to_start,
  get_participants, // for testing purposes
  add_badges,
  get_badges,
  get_matches,
  get_tournaments_by_game,
}; // End of module.exports
