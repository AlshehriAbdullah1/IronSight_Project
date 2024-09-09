const { db, firebase } = require("./firebase.js");

const communityCollection = "Community";
const usersCollection = "Users";
const tournamentsCollection = "Tournaments";
const gamesCollection = "Games";

const commuintyRef = db.collection(communityCollection);
const usersRef = db.collection(usersCollection);
const tournamentsRef = db.collection(tournamentsCollection);
const gamesRef = db.collection(gamesCollection);


// This function is a generic search function that will search for a given query in a given collection
// It will return a list of documents that contain the query in their fields
// The query is case-insensitive
// The query can be a substring of the field
async function search(collection, query) {
    if(!collection || !query) {
        return [];
    }
    if(typeof collection !== "string" || typeof query !== "string") {
        return [];
    }
    
    var name;
    var selectedCollection;
    if(collection.trim().toLowerCase() == "community") {
        selectedCollection = commuintyRef;
        name = "Community_Name";
    }
    if(collection.trim().toLowerCase() == "games") {
        selectedCollection = gamesRef;
        name = "Game_Name";
    }
    if(collection.trim().toLowerCase() == "tournaments") {
        selectedCollection = tournamentsRef;
        name = "Tournament_Name";
    }
    if(collection.trim().toLowerCase() == "users") {   
        selectedCollection = usersRef;
        name = "User_Name";
        query = "@"+query
    }
    if(!selectedCollection) {
        return [];
    }
    // convert the query to lowercase
    query = query.toLowerCase();
    // searching will start from the beginning of the name
    let startAt = query;
    
    // searching will end at a very high Unicode value
    let endAt = query + '\uf8ff'; // '\uf8ff' is a very high Unicode value
    const snapshot = await selectedCollection
    .where(name + '_Lower', '>=', startAt)
    .where(name + '_Lower', '<', endAt)
    .get();

    const results = snapshot.docs.map(doc => {
        let data = doc.data();
        data.Game_Id = doc.id;
        return data;
    }
    );
    // console.log(results);
    // const snapshot = await collection.where('name', '>=', query).get();
    return results;
}


// Functions to filter the database
module.exports = { search };