const { db, firebase } = require("./firebase.js");
const communityCollection = "Community";
const postsCollection = "Posts";
const repliesCollection = "Replies";

var communityRef = db.collection(communityCollection);
var postsRef = db.collection(postsCollection);

// Import the user functions to be used in the community functions
var userRef = db.collection("Users");

// Default variables for the community functions
const defaultBanner =
  "https://t4.ftcdn.net/jpg/04/74/44/85/360_F_474448512_w2NP8jcwfKKX9rIballVuxSqQK4rNRbE.jpg";
const defaultCommunityPicture =
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2IW5EHQI2R5GXaXggNSEqdpcmR2Aboq1daot7NB5QSQ&s";
const defaultThumbnail =
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJ6IdH99WaM9JLAvOnSEANFBHh3sdta32njL0GI9E9Yg&s";

// Function to replace the references in the object with the id
function replaceReferences(object) {
  for (const key in object) {
    if (object[key] !== null && typeof object[key] === "object") {
      if (object[key].id) {
        object[key] = object[key].id;
      } else {
        replaceReferences(object[key]);
      }
    }
    if (object[key] !== null && Array.isArray(object[key])) {
      for (let i = 0; i < object[key].length; i++) {
        if (object[key][i] !== null && typeof object[key][i] === "object") {
          if (object[key][i].id) {
            object[key][i] = object[key][i].id;
          } else {
            replaceReferences(object[key][i]);
          }
        }
      }
    }
  }
  return object;
}

// Function to create a new community
async function create_community(options) {
  console.log(options);
  try {
    if (
      !options.Community_Name ||
      !options.Community_Tag ||
      options.isPrivate == undefined ||
      !options.Owner
    ) {
      throw new Error("Missing required fields");
    }
    if (options.Description.length == 0) {
      options.Description = "No Description";
    }
    if (options.Description.length > 500) {
      throw new Error("Description is too long");
    }

    // Using Regex to check if the community tag is valid
    var checkRegex = new RegExp("[a-zA-Z0-9_]{1,25}$");
    if (!checkRegex.test(options.Community_Tag)) {
      throw new Error("Invalid Community Tag");
    }

    // Check if the community name is valid and does not contain special characters
    var checkNameRegex = new RegExp("[a-zA-Z0-9 ]{1,25}$");
    if (!checkNameRegex.test(options.Community_Name)) {
      throw new Error("Invalid Community name");
    }

    // If the community is public, add an empty password
    if (!options.isPrivate) {
      options.Password = "";
    }

    // If the community is private, check if the password is provided
    if (
      options.isPrivate == true &&
      (options.Password == null || options.Password == "")
    ) {
      // set the password 12345 if the community is private and the password is not provided
      options.Password = "12345";
    }

    // Check if the owner is a valid user
    var ownerRef = await userRef.doc(options.Owner);
    if (!ownerRef) {
      throw new Error("Owner does not exist");
    }

    // Access the community collection in the database and add the new community's information
    const community = await communityRef.add({
      Banner: options.Banner || defaultBanner,
      Blocked_Users: [],
      Description: options.Description,
      Community_Name: options.Community_Name,
      Community_Name_Lower: options.Community_Name.toLowerCase(),
      Community_Picture: options.Community_Picture || defaultCommunityPicture,
      Community_Tag: "#" + options.Community_Tag,
      Members: [],
      Moderators: [],
      Owner: ownerRef,
      Password: options.Password,
      Third_Party_Link: {},
      Thumbnail: options.Thumbnail || defaultThumbnail,
      isPrivate: options.isPrivate,
      isVerified: false,
      Created_At: firebase.firestore.FieldValue.serverTimestamp(),
    });

    var CommunityObject = await get_community({ Community_Id: community.id });
    return CommunityObject;
  } catch (error) {
    console.error("Error creating community:", error.message);
    return { error: error.message };
  }
} // End of create_community function

// Function to get community data
async function get_community(options) {
  try {
    // If the request query contains an ID, retrieve the community information with that ID
    if (options.Community_Id) {
      const communityID = options.Community_Id;
      // Call the function to get community information
      const communityDoc = await communityRef.doc(communityID).get();
      if (!communityDoc.exists) {
        throw new Error("Community not found");
      }
      // Include the community ID in the user object with the name 'Community_Id'
      const communityData = communityDoc.data();
      communityData.Community_Id = communityID;
      delete options.Community_Id; // Remove the original ID property if necessary
      delete options.Community_Name_Lower; // Remove unnecessary property
      // call the replaceReferences function to replace the references with the id
      document = replaceReferences(communityData);
      // Respond with community information
      return document;
    } else {
      // If the request query contains attributes, retrieve the community information with those attributes
      const keys = Object.keys(options);
      let query = communityRef;
      for (const key of keys) {
        query = query.where(key, "==", options[key]);
      }
      const snapshot = await query.get();
      if (snapshot.empty) {
        console.log("No matching documents.");
        return null;
      }
      // call replaceReferences function to replace the references with the id
      const documents = snapshot.docs.map((doc) => {
        const data = doc.data();
        delete data.Community_Name_Lower;
        return replaceReferences(data);
      });
      // add the community id to the object
      documents.forEach((doc, index) => {
        doc.Community_Id = snapshot.docs[index].id;
      });
      return documents;
    }
  } catch (error) {
    console.error("Error getting community:", error.message);
    return { error: error.message };
  }
}

// Return true if the link is valid, false otherwise
function isValidThirdPartyLink(link) {
  // Using Regex to check if the link is valid
  var checkLinkRegex = new RegExp(
    "^(http|https)://[a-zA-Z0-9.-]+.[a-zA-Z]{2,6}(/.*)?$"
  );
  return checkLinkRegex.test(link);
}

// Function to edit community information
async function edit_community(Community_Id, options) {
  try {
    if (!Community_Id) {
      throw new Error("Community ID and options are required");
    }
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    // Check for disallowed fields to be modified by the user
    if (options.Members || options.Moderators || options.Blocked_Users) {
      throw new Error("Cannot modify Members, Moderators, or Blocked Users");
    }
    if (options.Created_At) {
      throw new Error("Cannot modify Created_At");
    }
    // if (options.isVerified) {
    //   throw new Error("Cannot modify isVerified");
    // }

    // Check if the community is private and if the password is provided
    if (
      options.isPrivate == true &&
      (options.Password == null || options.Password == "")
    ) {
      // set the password 12345 if the community is private and the password is not provided
      options.Password = "12345";
    }
    // console.log("Password "+options.Password);
    // console.log("isPrivate "+options.isPrivate);
    // If the community is public, add an empty password
    if (!options.isPrivate) {
      options.Password = "";
    }

    if (options.Third_Party_Link != null) {
      if (
        options.Third_Party_Link.length == 0 ||
        options.Third_Party_Link == ""
      ) {
        options.Third_Party_Link = {};
      } else {
        for (const key in options.Third_Party_Link) {
          const link = options.Third_Party_Link[key];
          if (!isValidThirdPartyLink(link)) {
            throw new Error("Invalid Third Party Link");
          }
        }
      }
    }

    // Check if the owner is a valid user
    if (options.Owner != null) {
      var ownerRef = await userRef.doc(options.Owner).get();
      if (!ownerRef.exists) {
        throw new Error("Owner does not exist");
      }
      ownerRef = userRef.doc(options.Owner);
      // Add the owner as a reference to the options
      options.Owner = ownerRef;
    }
    // If the options contain a banner, community picture, or thumbnail, check if they are empty.
    // If they are empty replace them with the default values
    if (options.Banner != null) {
      if (options.Banner == "") {
        options.Banner = defaultBanner;
      }
    }
    if (options.Community_Picture != null) {
      if (options.Community_Picture == "") {
        options.Community_Picture = defaultCommunityPicture;
      }
    }
    if (options.Thumbnail != null) {
      if (options.Thumbnail == "") {
        options.Thumbnail = defaultThumbnail;
      }
    }

    // Check if the community tag is valid and does not contain special characters
    if (options.Community_Tag) {
      // Using Regex to check if the community tag is valid
      // The tag should be between 1 and 25 characters long and should only contain letters, numbers, and underscores
      var checkTagRegex = new RegExp("[a-zA-Z0-9_]{1,25}$");
      if (!checkTagRegex.test(options.Community_Tag)) {
        throw new Error("Invalid Community Tag");
      }
      // Add a hashtag to the community tag'
      if (options.Community_Tag.charAt(0) != "#") {
        options.Community_Tag = "#" + options.Community_Tag;
      }
    }
    if (options.Description != null) {
      if (options.Description == "") {
        options.Description = "No Description";
      }

      if (options.Description.length > 500) {
        throw new Error("Description is too long");
      }
    }

    if (options.Community_Name) {
      // Check if the community name is valid and does not contain special characters (it can contain spaces and numbers)
      var checkNameRegex = new RegExp("[a-zA-Z0-9 ]{1,25}$");
      if (!checkNameRegex.test(options.Community_Name)) {
        throw new Error("Invalid Community name");
      }
    }

    if (options.Community_Name_Lower != null) {
      throw new Error("Cannot modify Community_Name_Lower");
    }
    await communityRef.doc(Community_Id).update(options);
    let communityData = await get_community({ Community_Id: Community_Id });

    // Return the modified copy
    return communityData;
  } catch (err) {
    console.error("Error editing community:", err.message);
    return err;
  }
} // End of edit_community function

// Function to delete community
async function delete_community(Community_Id) {
  try {
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }

    // Access the community collection in the database and delete the community
    await communityRef.doc(Community_Id).delete();

    // Check if the community still exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (communityDoc.exists) {
      throw new Error("Community not deleted");
    }

    return "Community deleted successfully";
  } catch (error) {
    console.error("Error deleting community:", error.message);
    return { error: error.message };
  }
} // End of delete_community function

// Function to add a member to the community
async function add_member(Community_Id, User_Id) {
  // Check if the community ID and user ID are provided
  try {
    if (!Community_Id || !User_Id) {
      throw new Error("Community ID and User ID are required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    if (
      community &&
      Array.isArray(community.Members) &&
      community.Members.some((member) => member.id === User_Id)
    ) {
      throw new Error("User is already part of the Community");
    }

    if (
      community &&
      Array.isArray(community.Blocked_Users) &&
      community.Blocked_Users.some(
        (blocked_user) => blocked_user.id === User_Id
      )
    ) {
      throw new Error("User is Blocked from this community");
    }
    var newMember = userRef.doc(User_Id);
    if (newMember == null) {
      throw new Error("User does not exist");
    }
    // Access the user collection in the database and get the user information to check if it exists, if not add an empty list as []
    const currentMembers = community.Members || [];
    currentMembers.push(newMember);
    // Add the user to the community's members list
    await communityRef.doc(Community_Id).update({
      Members: currentMembers,
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of add_member function

// Function to remove a member from the community
async function remove_member(Community_Id, User_Id) {
  try {
    // Check if the community ID and user ID are provided
    if (!Community_Id || !User_Id) {
      throw new Error("Community ID and User ID are required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Check if the user is NOT part of the community
    if (
      community &&
      Array.isArray(community.Members) &&
      !community.Members.some((member) => member.id === User_Id)
    ) {
      throw new Error("User is not part of the Community");
    }
    // Access the user collection in the database and get the user information to check if it exists
    const currentMembers = community.Members || [];
    // Remove the user from the community's members list
    await communityRef.doc(Community_Id).update({
      Members: currentMembers.filter((member) => member.id !== User_Id),
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of remove_member function

// Function to retrieve all members of a community
async function get_members(Community_Id) {
  try {
    // Check if the community ID is provided
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Get the list of members in the community
    var members = community.Members || [];
    for (var i = 0; i < members.length; i++) {
      // Get the user information for each member
      var user = (await userRef.doc(members[i].id).get()).data();
      if (user == null) {
        throw new Error("User does not exist");
      }
      let userID = members[i].id;
      // Only include the user's ID,username,profile picture,bio,and display name in the members list
      members[i] = {
        User_Id: userID,
        User_Name: user.User_Name,
        Profile_Picture: user.Profile_Picture,
        Bio: user.Bio,
        Display_Name: user.Display_Name,
      };
    }
    return members;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_members function

// Function to block a member from the community
async function block_member(Community_Id, User_Id) {
  try {
    // Check if the community ID and user ID are provided
    if (!Community_Id || !User_Id) {
      throw new Error("Community ID and User ID are required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Check if the user is already blocked from the community
    if (
      community &&
      Array.isArray(community.Blocked_Users) &&
      community.Blocked_Users.some(
        (blocked_user) => blocked_user.id === User_Id
      )
    ) {
      throw new Error("User is already blocked from the Community");
    }
    // Check if the user is NOT part of the community
    if (
      community &&
      Array.isArray(community.Members) &&
      !community.Members.some((member) => member.id === User_Id)
    ) {
      throw new Error("User is NOT part of the Community");
    }
    // Access the user collection in the database and get the user information to check if it exists
    const currentMembers = community.Members || [];
    // Remove the user from the community's members list
    await communityRef.doc(Community_Id).update({
      Members: currentMembers.filter((member) => member.id !== User_Id),
    });

    // Add the user to the community's blocked users list
    const currentBlockedUsers = community.Blocked_Users || [];
    var blockedUser = userRef.doc(User_Id);
    if (blockedUser == null) {
      throw new Error("User does not exist");
    }
    currentBlockedUsers.push(blockedUser);
    await communityRef.doc(Community_Id).update({
      Blocked_Users: currentBlockedUsers,
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of block_member function

// Function to unblock a member from the community
async function unblock_member(Community_Id, User_Id) {
  try {
    // Check if the community ID and user ID are provided
    if (!Community_Id || !User_Id) {
      throw new Error("Community ID and User ID are required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Check if the user is NOT blocked from the community
    if (
      community &&
      Array.isArray(community.Blocked_Users) &&
      !community.Blocked_Users.some(
        (blocked_user) => blocked_user.id === User_Id
      )
    ) {
      throw new Error("User is NOT blocked from the Community");
    }
    // Check if the user is part of the community
    if (
      community &&
      Array.isArray(community.Members) &&
      community.Members.some((member) => member.id === User_Id)
    ) {
      throw new Error("User is part of the Community");
    }
    // Access the user collection in the database and get the user information to check if it exists
    const currentBlockedUsers = community.Blocked_Users || [];
    // Remove the user from the community's blocked users list
    await communityRef.doc(Community_Id).update({
      Blocked_Users: currentBlockedUsers.filter(
        (blocked_user) => blocked_user.id !== User_Id
      ),
    });
    // Add the user to the community's members list
    const currentMembers = community.Members || [];
    var newMember = userRef.doc(User_Id);
    if (newMember == null) {
      throw new Error("User does not exist");
    }
    currentMembers.push(newMember);
    await communityRef.doc(Community_Id).update({
      Members: currentMembers,
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of unblock_member function

// Function to get all blocked members of a community
async function get_blocked_members(Community_Id) {
  try {
    // Check if the community ID is provided
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Get the list of blocked members in the community
    var blockedMembers = community.Blocked_Users || [];
    for (var i = 0; i < blockedMembers.length; i++) {
      // Get the user information for each blocked member
      var user = await (await userRef.doc(blockedMembers[i].id).get()).data();
      if (user == null) {
        throw new Error("User does not exist");
      }
      let userID = blockedMembers[i].id;
      blockedMembers[i] = {
        User_Id: userID,
        User_Name: user.User_Name,
        Profile_Picture: user.Profile_Picture,
        Bio: user.Bio,
        Display_Name: user.Display_Name,
      };
    }
    return blockedMembers;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_blocked_members function

// Function to add a moderator to the community
async function add_moderator(Community_Id, User_Id) {
  try {
    // Check if the community ID and user ID are provided
    if (!Community_Id || !User_Id) {
      throw new Error("Community ID and User ID are required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Check if the user is already a moderator of the community
    if (
      community &&
      Array.isArray(community.Moderators) &&
      community.Moderators.some((moderator) => moderator.id === User_Id)
    ) {
      throw new Error("User is already a moderator of the Community");
    }
    // Check if the user is blocked from the community
    if (
      community &&
      Array.isArray(community.Blocked_Users) &&
      community.Blocked_Users.some(
        (blocked_user) => blocked_user.id === User_Id
      )
    ) {
      throw new Error("User is Blocked from this community");
    }
    // Check if the user is NOT part of the community
    if (
      community &&
      Array.isArray(community.Members) &&
      !community.Members.some((member) => member.id === User_Id)
    ) {
      throw new Error("User is NOT part of the Community");
    }
    // Access the user collection in the database and get the user information to check if it exists
    var newModerator = userRef.doc(User_Id);
    if (newModerator == null) {
      throw new Error("User does not exist");
    }
    // Access the user collection in the database and get the user information to check if it exists, if not add an empty list as []
    const currentModerators = community.Moderators || [];
    currentModerators.push(newModerator);
    // Add the user to the community's moderators list
    await communityRef.doc(Community_Id).update({
      Moderators: currentModerators,
    });
    // Remove the user from the community's members list
    const currentMembers = community.Members || [];
    await communityRef.doc(Community_Id).update({
      Members: currentMembers.filter((member) => member.id !== User_Id),
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of add_moderator function

// Function to remove a moderator from the community
async function remove_moderator(Community_Id, User_Id) {
  try {
    // Check if the community ID and user ID are provided
    if (!Community_Id || !User_Id) {
      throw new Error("Community ID and User ID are required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Check if the user is NOT a moderator of the community
    if (
      community &&
      Array.isArray(community.Moderators) &&
      !community.Moderators.some((moderator) => moderator.id === User_Id)
    ) {
      throw new Error("User is NOT a moderator of the Community");
    }
    // Check if the user is blocked from the community
    if (
      community &&
      Array.isArray(community.Blocked_Users) &&
      community.Blocked_Users.some(
        (blocked_user) => blocked_user.id === User_Id
      )
    ) {
      throw new Error("User is Blocked from this community");
    }
    // Access the user collection in the database and get the user information to check if it exists
    const currentModerators = community.Moderators || [];
    // Remove the user from the community's moderators list
    await communityRef.doc(Community_Id).update({
      Moderators: currentModerators.filter(
        (moderator) => moderator.id !== User_Id
      ),
    });
    // Add the user to the community's members list
    const currentMembers = community.Members || [];
    var newMember = userRef.doc(User_Id);
    if (newMember == null) {
      throw new Error("User does not exist");
    }
    currentMembers.push(newMember);
    await communityRef.doc(Community_Id).update({
      Members: currentMembers,
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    throw error;
  }
} // End of remove_moderator function

// Function to get all moderators of a community
async function get_moderators(Community_Id) {
  try {
    // Check if the community ID is provided
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Get the list of moderators in the community
    var moderators = community.Moderators || [];
    for (var i = 0; i < moderators.length; i++) {
      // Get the user information for each moderator
      var user = (await userRef.doc(moderators[i].id).get()).data();
      if (user == null) {
        throw new Error("User does not exist");
      }
      let userID = moderators[i].id;
      // Only include the user's ID,username,profile picture,bio,and display name in the moderators list
      moderators[i] = {
        User_Id: userID,
        User_Name: user.User_Name,
        Profile_Picture: user.Profile_Picture,
        Bio: user.Bio,
        Display_Name: user.Display_Name,
      };
    }
    return moderators;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_moderators

// Function to get the owner of a community
async function get_owner(Community_Id) {
  try {
    // Check if the community ID is provided
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    var community = communityDoc.data();
    // Get the owner of the community
    var owner = community.Owner || {};
    // Get the user information for the owner
    var user = (await userRef.doc(owner.id).get()).data();
    if (user == null) {
      throw new Error("User does not exist");
    }
    let userID = owner.id;
    // Only include the user's ID,username,profile picture,bio,and display name in the owner object
    owner = {
      User_Id: userID,
      User_Name: user.User_Name,
      Profile_Picture: user.Profile_Picture,
      Bio: user.Bio,
      Display_Name: user.Display_Name,
    };
    return owner;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_owner function

// Function to make a community private
async function make_private(Community_Id, password) {
  try {
    // Check if the community ID is provided
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }
    // Check if the password is provided
    if (!password) {
      throw new Error("Password is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    if (communityDoc.data().isPrivate) {
      throw new Error("Community is already private");
    }
    if (communityDoc.data().Password.length > 0) {
      throw new Error("Community already has a password");
    }
    // Update the community's privacy status to private
    await communityRef.doc(Community_Id).update({
      isPrivate: true,
      Password: password,
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of make_private function

// Function to make a community public
async function make_public(Community_Id) {
  try {
    // Check if the community ID is provided
    if (!Community_Id) {
      throw new Error("Community ID is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    if (!communityDoc.data().isPrivate) {
      throw new Error("Community is already public");
    }
    // Update the community's privacy status to public
    await communityRef.doc(Community_Id).update({
      isPrivate: false,
      Password: "",
    });
    var CommunityObject = await get_community({ Community_Id: Community_Id });

    // call the replaceReferences function to replace the references with the id
    CommunityObject = replaceReferences(CommunityObject);

    return CommunityObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of make_public function

// Function to add a new post to the community
// The function takes the community ID and the post information as parameters
// The post information should include the user ID of the user who created the post
async function add_post(Community_Id, Post) {
  try {
    // Check if the community ID and post are provided
    if (!Community_Id || !Post) {
      throw new Error("Community ID and Post are required");
    }
    // Check if the user ID is provided
    if (Post.User_Id == null) {
      throw new Error("User ID is required");
    }
    // Access the community collection in the database and get the community information to check if it exists
    const communityDoc = await communityRef.doc(Community_Id).get();
    if (!communityDoc.exists) {
      throw new Error("Community does not exist");
    }
    // Check if the user is part of the community
    var community = communityDoc.data();
    if (
      community &&
      !(
        (Array.isArray(community.Members) &&
          community.Members.some((member) => member.id === Post.User_Id)) ||
        community.Moderators.includes(Post.User_Id) ||
        community.Owner.id === Post.User_Id
      )
    ) {
      throw new Error("User is NOT part of the Community");
    }

    if (Post.Post_Content == null) {
      throw new Error("Post Content is required");
    }
    if (Post.Post_Content.length > 500) {
      throw new Error("Post Content is too long");
    }

    // Access the posts collection in the database and add the new post's information
    // First adding the information to the post object
    var post = await postsRef.add({
      // Add the community Id in a reference format
      Associated_With: communityRef.doc(Community_Id),
      // Add the user Id in a reference format
      Poster: userRef.doc(Post.User_Id),
      Post_Content: Post.Post_Content || "",
      Post_Likes: [],
      Post_Likes_Count: 0,
      Post_Media: Post.Post_Media || [],
      Created_At: firebase.firestore.FieldValue.serverTimestamp(),
      // After everything is added, add a sub collection containing the replies to the post
    });
    var option = "post";
    var postObject = get_post(post.id, null, option);

    // call the replaceReferences function to replace the references with the id
    postObject = replaceReferences(postObject);

    return postObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of add_post function

// Function to get post data
// The function takes the post ID or community ID as a parameter
// If the post ID is provided, the function retrieves the post information with that ID
// If the community ID is provided, the function retrieves all posts associated with that community
// By Default, the function retrieves the most recent posts
async function get_post(Post_Id, Community_Id, option) {
  try {
    if (option === "community") {
      if (Community_Id) {
        const communityDoc = await communityRef.doc(Community_Id).get();
        if (!communityDoc.exists) {
          throw new Error("Community does not exist");
        }

        const posts = await postsRef
          .where("Associated_With", "==", communityDoc.ref)
          .orderBy("Created_At", "desc")
          .get();

        if (posts.empty) {
          return [];
        }

        var documents = await Promise.all(
          posts.docs.map(async (doc) => {
            const data = doc.data();
            const posterSnapshot = await userRef.doc(data.Poster.id).get();
            const poster = posterSnapshot.data();

            let reply_count = await get_reply_count(doc.id);

            if (!posterSnapshot.exists || !poster) {
              throw new Error("Poster does not exist");
            }

            return {
              Post_Id: doc.id,
              Poster: {
                User_Id: data.Poster.id,
                User_Name: poster.User_Name,
                Profile_Picture: poster.Profile_Picture,
                Display_Name: poster.Display_Name,
              },
              Post_Content: data.Post_Content,
              Post_Likes_Count: data.Post_Likes_Count,
              Post_Media: data.Post_Media,
              Created_At: data.Created_At,
              Post_Likes: data.Post_Likes,
              Post_Replies_Count : reply_count.Post_Replies_Count
            };
          })
        );

        // call the replaceReferences function to replace the references with the id
        documents = replaceReferences(documents);

        return documents;
      }
    } else if (option === "post" && Post_Id && Post_Id !== "undefined") {
      let postDoc = await postsRef.doc(Post_Id).get();
      if (!postDoc.exists) {
        throw new Error("Post does not exist");
      }
      const postData = postDoc.data();
      var poster = await userRef.doc(postData.Poster.id).get();
      if (!poster.exists) {
        throw new Error("Poster does not exist");
      }

      let reply_count = await get_reply_count(Post_Id);
      
      poster = poster.data();
      var returnPost = {
        Post_Id: postDoc.id,
        Poster: {
          User_Id: postData.Poster.id,
          User_Name: poster.User_Name,
          Profile_Picture: poster.Profile_Picture,
          Display_Name: poster.Display_Name,
        },
        Post_Content: postData.Post_Content,
        Post_Likes_Count: postData.Post_Likes_Count,
        Post_Media: postData.Post_Media,
        Created_At: postData.Created_At,
        Post_Likes: postData.Post_Likes,
        Post_Replies_Count : reply_count.Post_Replies_Count
      };

      // call the replaceReferences function to replace the references with the id
      returnPost = replaceReferences(returnPost);

      return returnPost;
    }
  } catch (error) {
    console.error("Error fetching post:", error.message);
    return { error: error.message };
  }
} // End of get_post function

// GET TOP POSTS FUNCTION
async function get_top_posts(Community_Id) {
  try {
    if (Community_Id) {
      const communityDoc = await communityRef.doc(Community_Id).get();
      if (!communityDoc.exists) {
        throw new Error("Community does not exist");
      }

      const posts = await postsRef
        .where("Associated_With", "==", communityDoc.ref)
        .orderBy("Post_Likes_Count", "desc")
        .get();

      if (posts.empty) {
        return [];
      }

      var documents = await Promise.all(
        posts.docs.map(async (doc) => {
          const data = doc.data();
          const posterSnapshot = await userRef.doc(data.Poster.id).get();
          const poster = posterSnapshot.data();

          if (!posterSnapshot.exists || !poster) {
            throw new Error("Poster does not exist");
          }

          return {
            Post_Id: doc.id,
            Poster: {
              User_Id: data.Poster.id,
              User_Name: poster.User_Name,
              Profile_Picture: poster.Profile_Picture,
              Display_Name: poster.Display_Name,
            },
            Post_Content: data.Post_Content,
            Post_Likes_Count: data.Post_Likes_Count,
            Post_Media: data.Post_Media,
            Created_At: data.Created_At,
            Post_Likes: data.Post_Likes,
          };
        })
      );

      // call the replaceReferences function to replace the references with the id
      documents = replaceReferences(documents);

      return documents;
    }
  } catch (error) {
    console.error("Error getting top posts:", error.message);
    return { error: error.message };
  }
} // End of get_top_posts function

// Function to remove post
async function remove_post(Post_Id) {
  try {
    if (!Post_Id) {
      throw new Error("Post ID is required");
    }
    // Access the post collection in the database and remove the post
    await postsRef.doc(Post_Id).delete();
    if ((await postsRef.doc(Post_Id).get()).exists) {
      throw new Error("Post not removed");
    }
    return "Post removed successfully";
  } catch (error) {
    console.error("Error removing post:", error.message);
    return { error: error.message };
  }
} // End of remove_post function

// Function to add a reply to a post
// The function takes the post ID and the reply information as parameters
// The reply information should include the user ID of the user who created the reply
async function add_reply(Post_Id, Reply) {
  try {
    // Check if the post ID and reply are provided
    if (!Post_Id || !Reply) {
      throw new Error("Post ID and Reply are required");
    }
    // Check if the user ID is provided
    if (Reply.User_Id == null) {
      throw new Error("User ID is required");
    }

    if (Reply.Reply_Content.length > 500) {
      throw new Error("Reply Content is too long");
    }
    // Access the post collection in the database and get the post information to check if it exists
    const postDoc = await postsRef.doc(Post_Id).get();
    if (!postDoc.exists) {
      throw new Error("Post does not exist");
    }
    // Access the replies collection in the database and add the new reply's information
    var replier = await userRef.doc(Reply.User_Id);
    if (replier == null) {
      throw new Error("User does not exist");
    }

    var reply = await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .add({
        Reply_Likes: [],
        Reply_Likes_Count: 0,
        Reply_Content: Reply.Reply_Content || "",
        // Add the user Id in a reference format
        Replier: replier,
        Reply_Media: Reply.Reply_Media || [],
        Created_At: firebase.firestore.FieldValue.serverTimestamp(),
      });
    var replyObject = await get_reply(reply.id, Post_Id);

    // call the replaceReferences function to replace the references with the id
    replyObject = replaceReferences(replyObject);

    return replyObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of add_reply function

// Function to get reply data
// The function takes the post ID as a parameter or the post ID and reply ID
async function get_reply(Reply_Id, Post_Id) {
  try {
    // If the request query contains an ID, retrieve the reply information with that ID
    if (Reply_Id) {
      if (Post_Id) {
        const replyID = Reply_Id;
        // Call the function to get reply information
        var reply = (
          await postsRef
            .doc(Post_Id)
            .collection(repliesCollection)
            .doc(Reply_Id)
            .get()
        ).data();

        if (reply == null) {
          throw new Error("Reply does not exist");
        }
        // Add the reply count to the reply object
        let reply_count = await get_reply_count(Post_Id);

        // Include the reply ID in the user object with the name 'Reply_Id'
        reply.Reply_Id = replyID;
        delete replyID; // Remove the original ID property if necessary

        var replier = await userRef.doc(reply.Replier.id).get();
        if (replier == null) {
          throw new Error("Replier does not exist");
        }
        replier = replier.data();
        reply.Replier = {
          User_Id: reply.Replier.id,
          User_Name: replier.User_Name,
          Profile_Picture: replier.Profile_Picture,
          Display_Name: replier.Display_Name,
        };
        reply.Post_Replies_Count = reply_count.Post_Replies_Count;
        reply.Post_Id = reply_count.Post_Id;
        // reply.Reply_Likes = reply.Reply_Likes;

        // call the replaceReferences function to replace the references with the id
        reply = replaceReferences(reply);

        // Respond with user information
        return reply;
      }
    }
    if (Post_Id) {
      // If the request query contains a post ID, retrieve all the replies with that post ID
      const postID = Post_Id;
      // Access the replies collection in the database and get replies associated with the post
      const replies = await postsRef
        .doc(postID)
        .collection(repliesCollection)
        .get();
      if (replies.empty) {
        return [];
      }

      let reply_count = await get_reply_count(Post_Id);
      // Map documents to include the ID with the name 'Reply_Id'
      var documents = await Promise.all(
        replies.docs.map(async (doc) => {
          const data = doc.data();
          var replierId = data.Replier.id;
          const replierSnapshot = await userRef.doc(data.Replier.id).get();
          const replier = replierSnapshot.data();

          if (!replierSnapshot.exists || !replier) {
            throw new Error("Poster does not exist");
          }
          return {
            Reply_Id: doc.id,
            Replier: {
              User_Id: data.Replier.id,
              User_Name: replier.User_Name,
              Profile_Picture: replier.Profile_Picture,
              Display_Name: replier.Display_Name,
            },
            Reply_Content: data.Reply_Content,
            Reply_Likes_Count: data.Reply_Likes_Count,
            Reply_Media: data.Reply_Media,
            Created_At: data.Created_At,
            Reply_Likes: data.Reply_Likes,
            Post_Replies_Count : reply_count.Post_Replies_Count,
            Post_Id : reply_count.Post_Id
          };
        })
      );

      // call the replaceReferences function to replace the references with the id
      documents = replaceReferences(documents);

      return documents;
    }
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_reply function

// Function to get the count of replies for a post
async function get_reply_count(Post_Id) {
  try {
    // Check if the post ID is provided
    if (!Post_Id) {
      throw new Error("Post ID is required");
    }
    // Access the replies collection in the database and get the count of replies associated with the post
    var replies = await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .count()
      .get();
    if (replies.empty || replies.length == 0 || replies == null) {
      return 0;
    }
    var count = replies.data().count;
    return {
      Post_Id: Post_Id,
      Post_Replies_Count: count,
    };
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_reply_count function

// Function to remove reply
async function remove_reply(Post_Id, Reply_Id) {
  try {
    if (!Reply_Id || !Post_Id) {
      throw new Error("Reply ID or Post ID is required");
    }
    // Access the reply collection in the database and remove the reply
    await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .delete();
    if (
      (
        await postsRef
          .doc(Post_Id)
          .collection(repliesCollection)
          .doc(Reply_Id)
          .get()
      ).exists
    ) {
      throw new Error("Reply not removed");
    }
    return "Reply removed successfully";
  } catch (error) {
    console.error("Error removing reply:", error.message);
    return { error: error.message };
  }
} // End of remove_reply function

// Function to like a post and add the user to the post's likes list
// The function takes the post ID as a parameter
// The user can not like the same post more than once
async function like_post(Post_Id, User_Id) {
  try {
    // Check if the post ID is provided
    if (!Post_Id) {
      throw new Error("Post ID is required");
    }
    // Check if the user ID is provided
    if (User_Id == null) {
      throw new Error("User ID is required");
    }
    // Access the post collection in the database and get the post information to check if it exists
    const postDoc = await postsRef.doc(Post_Id).get();
    if (!postDoc.exists) {
      throw new Error("Post does not exist");
    }
    // Access the user collection in the database and get the user information to check if it exists
    const userDoc = await userRef.doc(User_Id).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }
    // Check if the user has already liked the post
    var post = postDoc.data();
    if (
      post &&
      Array.isArray(post.Post_Likes) &&
      post.Post_Likes.some((like) => like.id === User_Id)
    ) {
      throw new Error("User has already liked the Post");
    }

    // Add the user to the post's likes list
    const currentLikes = post.Post_Likes || [];
    var newUser = userRef.doc(User_Id);
    if (newUser == null) {
      throw new Error("User does not exist");
    }
    currentLikes.push(newUser);
    // Update the post's likes count and list
    await postsRef.doc(Post_Id).update({
      Post_Likes: currentLikes,
      Post_Likes_Count: firebase.firestore.FieldValue.increment(1),
    });
    let option = "post";
    var postObject = await get_post(Post_Id, null, option);

    // call the replaceReferences function to replace the references with the id
    //postObject = replaceReferences(postObject);

    return postObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of like_post function

// Function to unlike a post and remove the user from the post's likes list
// The function takes the post ID as a parameter
// The user can not unlike the same post more than once
async function unlike_post(Post_Id, User_Id) {
  try {
    console.log(Post_Id, User_Id);
    // Check if the post ID is provided
    if (!Post_Id) {
      throw new Error("Post ID is required");
    }
    // Check if the user ID is provided
    if (User_Id == null) {
      throw new Error("User ID is required");
    }
    // Access the post collection in the database and get the post information to check if it exists
    const postDoc = await postsRef.doc(Post_Id).get();
    if (!postDoc.exists) {
      throw new Error("Post does not exist");
    }
    // Access the user collection in the database and get the user information to check if it exists
    const userDoc = await userRef.doc(User_Id).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }
    // Check if the user has NOT liked the post
    var post = postDoc.data();
    if (
      post &&
      Array.isArray(post.Post_Likes) &&
      !post.Post_Likes.some((like) => like.id === User_Id)
    ) {
      throw new Error("User has NOT liked the Post");
    }
    // Remove the user from the post's likes list
    const currentLikes = post.Post_Likes || [];
    // Update the post's likes count and list
    var post = await postsRef.doc(Post_Id);
    if (post.Post_Likes_Count == 0) {
      throw new Error("Post has no likes");
    }
    post.update({
      Post_Likes: currentLikes.filter((like) => like.id !== User_Id),
      Post_Likes_Count: firebase.firestore.FieldValue.increment(-1),
    });
    let option = "post";
    var postObject = await get_post(Post_Id, null, option);

    // call the replaceReferences function to replace the references with the id
    // postObject = replaceReferences(postObject);

    return postObject;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of unlike_post function

// Function to like a reply and add the user to the reply's likes list
// The function takes the reply ID as a parameter
// The user can not like the same reply more than once
async function like_reply(Reply_Id, User_Id, Post_Id) {
  try {
    // Check if the reply ID, user ID and post ID are provided
    if (!Reply_Id || !User_Id || !Post_Id) {
      throw new Error("Reply ID, User ID and Post ID are required");
    }

    // Access the reply from the post document
    const replyDoc = await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .get();

    if (!replyDoc.exists) {
      throw new Error("Reply does not exist");
    }

    // Access the user collection in the database and get the user information to check if it exists
    const userDoc = await userRef.doc(User_Id).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }

    var reply = replyDoc.data();

    // Check if the user has already liked the reply
    if (
      reply &&
      Array.isArray(reply.Reply_Likes) &&
      reply.Reply_Likes.some((like) => like.id === User_Id)
    ) {
      throw new Error("User has already liked the Reply");
    }

    // Add the user to the reply's likes list
    const currentLikes = reply.Reply_Likes || [];
    var newUser = userRef.doc(User_Id);
    if (newUser == null) {
      throw new Error("User does not exist");
    }
    currentLikes.push(newUser);

    // Update the reply's likes count and list
    reply.Reply_Likes = currentLikes;
    reply.Reply_Likes_Count = (reply.Reply_Likes_Count || 0) + 1;

    // Update the reply document with the updated likes
    await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .update(reply);

    // call the replaceReferences function to replace the references with the id
    reply = replaceReferences(reply);

    return reply;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of like_reply function

// Function to unlike a reply and remove the user from the reply's likes list
// The function takes the reply ID as a parameter
// The user can not unlike the same reply more than once
async function unlike_reply(Reply_Id, User_Id, Post_Id) {
  try {
    const repliesCollection = "Replies";

    // Check if the reply ID and user ID are provided
    if (!Reply_Id || !User_Id || !Post_Id) {
      throw new Error("Reply ID, User ID and Post ID are required");
    }

    // Access the reply from the post document
    const replyDoc = await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .get();

    if (!replyDoc.exists) {
      throw new Error("Reply does not exist");
    }

    // Access the user collection in the database and get the user information to check if it exists
    const userDoc = await userRef.doc(User_Id).get();
    if (!userDoc.exists) {
      throw new Error("User does not exist");
    }

    var reply = replyDoc.data();

    // Check if the user has NOT liked the reply
    if (
      reply &&
      Array.isArray(reply.Reply_Likes) &&
      !reply.Reply_Likes.some((like) => like.id === User_Id)
    ) {
      throw new Error("User has NOT liked the Reply");
    }

    // Remove the user from the reply's likes list
    const currentLikes = reply.Reply_Likes || [];
    reply.Reply_Likes = currentLikes.filter((like) => like.id !== User_Id);
    reply.Reply_Likes_Count = (reply.Reply_Likes_Count || 1) - 1;

    // Update the reply document with the updated likes
    await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .update(reply);

    // call the replaceReferences function to replace the references with the id
    reply = replaceReferences(reply);

    return reply;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of unlike_reply function

// Function to get followed communities of a user
// The function takes a list of ids to the communities the user is following
// The function returns a list of communities (as objects) that the user is following
async function get_followed_communities(Communities) {
  try {
    // Check if the user is following any communities
    if (!Communities || Communities.length === 0) {
      throw new Error("User is not following any communities");
    }
    // Get the information of the communities the user is following
    var followedCommunities = [];
    // Loop through the list of references to the communities the user is following
    for (var commuinty = 0; commuinty < Communities.length; commuinty++) {
      // This is the current community the user is following
      let currentCommunity = Communities[commuinty];
      // Check if the current community is not null
      if (currentCommunity !== null) {
        // Access the community collection in the database and get the community information to check if it exists
        let community = await communityRef.doc(currentCommunity).get();
        if (community.exists) {
          // Only include the community ID, name, description, and thumbnail in the list
          let communityData = community.data();
          communityData = {
            Community_Id: currentCommunity,
            Community_Name: communityData.Community_Name,
            Description: communityData.Description,
            Thumbnail: communityData.Thumbnail,
          };
          // Add the community to the list of followed communities
          followedCommunities.push(communityData);
        }
      }
    }

    // call the replaceReferences function to replace the references with the id
    followedCommunities = replaceReferences(followedCommunities);

    // Return the list of followed communities as objects
    return followedCommunities;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of get_followed_communities function

// Function to edit Post Content
async function edit_post(Post_Id, option) {
  try {
    const postDoc = await postsRef.doc(Post_Id).get();
    if (!postDoc.exists) {
      throw new Error("Post does not exist");
    }

    // Check if option is an object and has a map_key property
    if (typeof option === "object" && option.hasOwnProperty("map_key")) {
      // Use the map_key as the key in the Post_Media map and the option value as the value
      await postsRef.doc(Post_Id).set(
        {
          Post_Media: {
            [option.map_key]: option.value,
          },
        },
        { merge: true }
      );
    } else {
      // Update the post as before
      await postsRef.doc(Post_Id).update(option);
    }

    const updatedPost = await postsRef.doc(Post_Id).get();
    var copyPost = updatedPost.data();
    copyPost.Associated_With = copyPost.Associated_With.id;
    copyPost.Poster = copyPost.Poster.id;
    // replace the Post_Likes reference with the Post_Likes ID using map
    copyPost.Post_Likes = copyPost.Post_Likes.map((like) => like.id);
    // include the Post_Id in the object
    copyPost.Post_Id = Post_Id;
    // include the Poster's information in the object
    var poster = await userRef.doc(copyPost.Poster).get();
    if (!poster.exists) {
      throw new Error("Poster does not exist");
    }
    poster = poster.data();

    copyPost.Poster = {
      User_Id: copyPost.Poster,
      User_Name: poster.User_Name,
      Profile_Picture: poster.Profile_Picture,
      Display_Name: poster.Display_Name,
    };

    // call the replaceReferences function to replace the references with the id
    copyPost = replaceReferences(copyPost);

    return copyPost;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of edit_post function

// Function to edit Reply Content
async function edit_reply(Post_Id, Reply_Id, option) {
  try {
    const repliesCollection = "Replies";

    const replyDoc = await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .get();
    if (!replyDoc.exists) {
      throw new Error("Reply does not exist");
    }
    // Use the map_key as the key in the Reply_Media map and the option value as the value
    if (option.hasOwnProperty("map_key")) {
      await postsRef
        .doc(Post_Id)
        .collection(repliesCollection)
        .doc(Reply_Id)
        .set(
          {
            Reply_Media: {
              [option.map_key]: option.value,
            },
          },
          { merge: true }
        );
    } else {
      await postsRef
        .doc(Post_Id)
        .collection(repliesCollection)
        .doc(Reply_Id)
        .update(option);
    }
    // await postsRef.doc(Post_Id).collection(repliesCollection).doc(Reply_Id).update(option);
    const updatedReply = await postsRef
      .doc(Post_Id)
      .collection(repliesCollection)
      .doc(Reply_Id)
      .get();
    var copyReply = updatedReply.data();
    copyReply.Replier = copyReply.Replier.id;
    // replace the Reply_Likes reference with the Reply_Likes ID using map
    copyReply.Reply_Likes = copyReply.Reply_Likes.map((like) => like.id);
    // include the Reply_Id in the object
    copyReply.Reply_Id = Reply_Id;
    // include the Replier's information in the object
    var replier = await userRef.doc(copyReply.Replier).get();
    if (!replier.exists) {
      throw new Error("Replier does not exist");
    }
    replier = replier.data();

    copyReply.Replier = {
      User_Id: copyReply.Replier,
      User_Name: replier.User_Name,
      Profile_Picture: replier.Profile_Picture,
      Display_Name: replier.Display_Name,
    };

    // call the replaceReferences function to replace the references with the id
    copyReply = replaceReferences(copyReply);

    return copyReply;
  } catch (error) {
    console.log(error);
    return { error: error.message };
  }
} // End of edit_reply function

// Export the functions to be used in the server
module.exports = {
  get_community,
  create_community,
  edit_community,
  delete_community,
  add_member,
  remove_member,
  get_members,
  block_member,
  unblock_member,
  get_blocked_members,
  add_moderator,
  remove_moderator,
  get_moderators,
  get_owner,
  make_private,
  make_public,
  add_post,
  get_post,
  remove_post,
  add_reply,
  get_reply,
  remove_reply,
  like_post,
  unlike_post,
  like_reply,
  unlike_reply,
  get_followed_communities,
  get_top_posts,
  get_reply_count,
  edit_post,
  edit_reply,
};
