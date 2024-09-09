const { db, firebase } = require("./firebase.js");
const axios = require("axios");
const qs = require("qs");
const { request } = require("graphql-request");
const { parse } = require("qs");
const e = require("express");
require("dotenv").config({ path: "../../.env" });

const userCollection = "Users";
var userRef = db.collection(userCollection);
const tournamentCollection = "Tournaments";

// Import the userFunctions.js file
const userFunctions = require("./userFunctions.js");

const ironSightClientSecret =
    process.env.IRON_SIGHT_CLIENT_SECRET;


const redirect_url = process.env.REDIRECT_URL;


////////////////////////////////////////////////////
// Google and Start.gg functions
////////////////////////////////////////////////////

// Google Login
// Export the functions
async function googleLogin(code) {
    //extracting tokens from the code
    const { id_token, access_token } = await getGoogleOauthTokens(code);
    // now exchanging the tokens with user info

    const userInfo = await getGoogleUserInfo(id_token, access_token);
    //console.log("got user info from google: " + JSON.stringify(userInfo));
    //register user in firebase, get user info and generate custom token
    const userGivenName = userInfo.given_name;
    const userEmail = userInfo.email;
    const userPhoto = userInfo.picture;
    try {
        let userRecord;
        let userRecordId;
        let isNewUser = false;

        try {
            // Check if the user already exists
            userRecord = await firebase.auth().getUserByEmail(userEmail);
            userRecordId = userRecord.uid;
        } catch (error) {
            if (error.code === "auth/user-not-found") {
                // If the user doesn't exist, create a new user
                userRecord = await firebase.auth().createUser({
                    email: userEmail,
                    emailVerified: true,
                    displayName: userGivenName,
                    Profile_Picture: userPhoto,
                });
                userRecordId = userRecord.uid;
                isNewUser = true;
            } else {
                throw error;
            }
        }

        if (isNewUser) {
            // save the user in the firestore db
            // console.log("creating user document");
            // console.log(userRecordId);
            await userRef.doc(userRecordId).set({
                createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                Email: userEmail,
                Display_Name: userGivenName,
                Profile_Picture: userPhoto,
                Role: "User",
                Followers: [],
                Following: [],
                Mobile_Number: "0505050505",
                Preferences: [],
                Age: 0,
                Banner: "",
                Bio: "",
                Communities: [],
                Badges: {},
                Tournaments: {
                    Current: [],
                    Followed: [],
                    Organized: [],
                    Previous: [],
                    Upcoming: [],
                },
                User_Name: "@" + userEmail,
                User_Name_Lower: "@" + userEmail.toLowerCase()
            });
            //console.log("User document created successfully");
        }

        const customToken = await firebase.auth().createCustomToken(userRecordId);
        // console.log("custom token created: " + customToken);
        return { userRecordId, customToken, isNewUser };
    } catch (error) {
        console.error("Error in user creation or token generation:", error);
    }
}

async function getGoogleOauthTokens(code) {
    //console.log("getting tokens from google");
    //console.log(code);
    const url = "https://oauth2.googleapis.com/token";
    googleClientId =
        process.env.GOOGLE_CLIENT_ID;
    googleClientSecret = process.env.GOOGLE_CLIENT_SECRET;
    googleOauthRedirectUrl = redirect_url+"/api/sessions/oauth/google";
    const values = {
        code: code,
        client_id: googleClientId,
        client_secret: googleClientSecret,
        redirect_uri: googleOauthRedirectUrl,
        grant_type: "authorization_code",
    };
    const queryString = qs.stringify(values);

    //console.log("queryString test: " + qs.stringify(values));
    try {
        const res = await axios.post(url, queryString, {
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
            },
        });
        //console.log(res.data);
        return res.data;
    } catch (error) {
        console.log("failed to fetch google oAuth tokens becuase of : " + error);
    }
}
async function getGoogleUserInfo(id_token, access_token) {
    //console.log(access_token);
    try {
        const res = await axios.get(
            `https://www.googleapis.com/oauth2/v2/userinfo?alt=json&access_token=${access_token}`,
            {
                headers: {
                    Authorization: `Bearer ${id_token}`,
                },
            }
        );
        return res.data;
    } catch (error) {
        console.log("failed to fetch google oAuth tokens becuase of :" + error);
    }
}


//////////////////////////////////////////////////////////////////////////

// Start.gg Login

// function to get the tokens from start.gg
async function startGGLogin(code) {
    try {
        const { access_token } = await getStartGGOauthTokens(code);
        const userInfo = await getStartGGUserInfo(access_token);
        const userEmail = userInfo.currentUser.email;
        const userRecord = await createUserInFirebase(userEmail, userInfo);
        const customToken = await generateCustomToken(userRecord.uid);
        return { userRecord, customToken };
    } catch (error) {
        console.error("Error in startGGLogin:", error);
    }
}
async function createUserInFirebase(userEmail, userInfo) {
    try {
        return await firebase.auth().getUserByEmail(userEmail);
    } catch (error) {
        //   console.log("User does not exist: 931 " + error.message);
        if (error.code === "auth/user-not-found") {
            // console.log("User does not exist: 933");
            return await createNewUser(userEmail, userInfo);
        } else {
            throw error;
        }
    }
}
async function createNewUser(userEmail, userInfo) {
    try {
        // console.log("creating user in firebase gg");
        //console.log("user email from start.gg: " + userEmail);
        // console.log("userInfo" + JSON.stringify(userInfo));
        const { userRecord } = await firebase.auth().createUser({
            email: userEmail,
            emailVerified: true,
            Profile_Picture: "https://start.gg/favicon.ico",
        });
        // console.log("userRecord" + JSON.stringify(userRecord));
        await userRef.doc(userRecord.uid).set({
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            Email: userEmail,
            Display_Name: "",
            Profile_Picture: "https://start.gg/favicon.ico",
            Role: "User",
            Followers: [],
            Following: [],
            Mobile_Number: "0505050505",
            Preferences: [],
            Age: 0,
            Banner: "",
            Bio: "",
            Communities: [],
            Badges: {},
            Tournaments: {
                Current: [],
                Followed: [],
                Organized: [],
                Previous: [],
                Upcoming: [],
            },
            User_Name: "@" + userEmail,
            User_Name_Lower: "@" + userEmail.toLowerCase()
        });

        return userRecord;
    } catch (error) {
        console.error("Error creating new user:", error);
        // await firebase.auth().deleteUser(userRecord.uid);
        // console.error("Error creating new user:", error);
    }
}
async function generateCustomToken(uid) {
    try {
        return await firebase.auth().createCustomToken(uid);
    } catch (error) {
        console.error("Error generating custom token:", error);
    }
}
async function getStartGGUserInfo(accessToken) {
    // console.log("getting user info is pending");
    const query = `
    query {
      currentUser {
        id
        name
        email
        birthday
        player {
          gamerTag
        }
      }
    }
  `;

    try {
        const headers = {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
        };

        const response = await request(
            "https://api.start.gg/gql/alpha",
            query,
            undefined,
            headers
        );
        return response;
    } catch (error) {
        console.log(error);
    }
}
async function getStartGGOauthTokens(code) {
    startGGClientId = process.env.START_GG_CLIENT_SECRET_KEY;   
    startGGClientSecret = process.env.START_GG_CLIENT_SECRET;
    const startGgRedirectUrl = redirect_url+"/api/sessions/oauth/startgg";
    const scope = "user.identity user.email";
    // console.log("getting tokens from start.gg");
    // console.log(code);
    const url = "https://api.start.gg/oauth/access_token";
    const values = {
        grant_type: "authorization_code",
        client_secret: ironSightClientSecret,
        code: code,
        scope: scope,
        client_id: startGGClientId,
        redirect_uri: startGgRedirectUrl,
    };
    const queryString = qs.stringify(values);

    try {
        const res = await axios.post(url, queryString, {
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
            },
        });
        // console.log(res.data)
        return res.data;
    } catch (error) {
        console.log("failed to fetch start.gg oAuth tokens becuase of : " + error);
    }
}


//////////////////////////////////////////////////////////////////////////

// normal sign up
// signUp function
async function signup(uid, email) {
    try {
        // Check if the user email is valid
        const userEmailValid = await checkUserEmail(email);
        if (!userEmailValid) {
            throw new Error("Invalid email");
        }

        // call the create user profile function
        const userRecord = await createUserProfile(uid, email);

        // Return the user's ID and custom token
        return userRecord;
    } catch (error) {
        console.error("Error creating new user:", error);
        if (error.message === "Invalid email") {
            return { error: error.message };
        }
        return { error: "Internal server error" };
    }
}

// Function to create a user profile in Firestore with default values, given the uid automatically generated by Firebase
async function createUserProfile(uid, email) {
    try {
        const userData = {
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            Email: email,
            Display_Name: "",
            Profile_Picture: "",
            Role: "User",
            Followers: [],
            Following: [],
            Mobile_Number: "",
            Preferences: [],
            Age: 0,
            Banner: "",
            Bio: "",
            Communities: [],
            Badges: {},
            Tournaments: {
                Current: [],
                Followed: [],
                Organized: [],
                Previous: [],
                Upcoming: [],
            },
            User_Name: "@" + email,
            User_Name_Lower: "@" + email.toLowerCase()
        }
        // Create the user profile in Firestore
        await userRef.doc(uid).set(userData);
        console.log('going to call get user { User_Id: uid } = '+ { User_Id: uid });
        // const userRecord = await userFunctions.get_user({ User_Id: uid });
        // return userRecord;
        // include the user ID in the user object with the name 'User_Id'
        userData.User_Id = uid;
        return userData;
    } catch (error) {
        console.error("Error creating user profile:", error);
        throw error;
    }
}

// async function get_user(options) {
//     try {
//       // If the request query contains an ID, retrieve the user information with that ID
//       if (options.User_Id) {
//         const userID = options.User_Id;
//         // Call the function to get user information
//         var user = (await userRef.doc(userID).get()).data();
//         // Include the user ID in the user object with the name 'User_Id'
//         user.User_Id = userID;
//         delete userID; // Remove the original ID property if 
//         delete user.User_Name_Lower; // Remove the User_Name_Lower property
//         // call replaceReferences to replace the references in the object with the id

//         // Changed to get the function from userFunctions.js
//         user = userFunctions.replaceReferences(user);
  
//         // Respond with user information
//         return user;
//       } else {
//         // If the request query contains attributes, retrieve the tournament information with those attributes
//         const keys = Object.keys(options);
//         for (const key of keys) {
//           userRef = userRef.where(key, "==", options[key]);
//         }
//         const snapshot = await userRef.get();
  
//         if (snapshot.empty) {
//           console.log("No matching documents.");
//           return null;
//         }
        
//         // call replaceReferences to replace the references in the object with the id
//         var documents = [];
//         snapshot.forEach((doc) => {
//           var user = doc.data();
//           user.User_Id = doc.id;
//           delete user.User_Name_Lower; // Remove the User_Name_Lower property
//           //user = replaceReferences(user);
//           documents.push(user);
//         });
  
//         return documents;
//       }
//     } catch (error) {
//       console.error("Error getting user:", error.message);
//       return { error: error.message };
//     }
//   } // End of get_user function
  


/////////////////////////////////////////////
////// functions for checking user name, user email, user password
/////////////////////////////////////////////

async function checkUserName(userName) {
    const userDoc = await userRef.where("User_Name", "==", userName).get();
    // Check if the user name already exists
    if (!userDoc.empty) {
        return false;
    }

    if (userName.length < 3 || userName.length > 15) {
        return false;
    }

    // Regular expression to match any character that is not a letter, number, underscore or hyphen
    const invalidCharacterRegex = /[^a-zA-Z0-9_-]/;
    if (invalidCharacterRegex.test(userName)) {
        return false;
    }

    return true;
}

async function checkUserEmail(userEmail) {
    const userDoc = await userRef.where("User_Email", "==", userEmail).get();

    if (!userDoc.empty) {
        return false;
    }

    // Regular expression for email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(userEmail)) {
        return false;
    }

    return true;
}

function checkUserPassword(userPassword) {
    // Check if password length is less than 8
    if (userPassword.length < 8) {
        return false;
    }

    // Regular expressions for password validation
    const lowerCaseRegex = /[a-z]/;
    const upperCaseRegex = /[A-Z]/;
    const numberRegex = /[0-9]/;
    const specialCharacterRegex = /[!@#$%^&*]/;

    // Check if password contains at least one lowercase letter, one uppercase letter, one number, and one special character
    if (
        !lowerCaseRegex.test(userPassword) ||
        !upperCaseRegex.test(userPassword) ||
        !numberRegex.test(userPassword) ||
        !specialCharacterRegex.test(userPassword)
    ) {
        return false;
    }

    return true;
}

// Function to check phone number
// The phone number must be a 10-digit number
// example: 0505050505
function checkPhoneNumber(phoneNumber) {
    // Regular expression for phone number validation
    const phoneRegex = /^\d{10}$/;
    if (!phoneRegex.test(phoneNumber)) {
        return false;
    }

    return true;
}

///////////////////////////////////////////////

module.exports = {
    googleLogin,
    startGGLogin,
    signup,
    // checkUserName,
    // checkUserEmail,
    // checkUserPassword,
    // checkPhoneNumber,
};

