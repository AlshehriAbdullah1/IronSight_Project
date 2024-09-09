const express = require("express");
const app = express();
const cors = require('cors');
const axios = require('axios');
const path = require('path');
const multer = require('multer');
const fs = require('fs');
const FormData = require('form-data');
require('dotenv').config({ path: '../../.env' });
const communityFunctions = require("./communityFunctions.js");

app.use(cors());
app.use(express.json());

const port = process.env.COMMUNITY_PORT || 4004;
const MediaMicro = process.env.MEDIA_HOST || 'http://localhost:4005';
const upload = multer({ dest: 'uploads/' });


// Endpoint to retrieve community information from the database using the given request query
// To retrieve all communities, send an empty request query
// To retrieve a community with a specific parameter, send a request query with the parameter
app.get("/communitiesM/", async (req, res) => {
  var options = req.query;
  let response = await communityFunctions.get_community(options);
  // Depending on the response, respond with the community information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});


// Endpoint to delete community
app.delete("/communitiesM/:community_id", async (req, res) => {
  let communityId = req.params.community_id;
  try {
    let response = await communityFunctions.delete_community(communityId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to edit community information 
app.put("/communitiesM/:community_id", async (req, res) => {
  let options = req.body;
  let communityId = req.params.community_id;

  try {
    // console.log('options : ' + JSON.stringify(options));
    let response = await communityFunctions.edit_community(communityId, options);
    res.send(response);
  } catch (error) {
    res.send({ error })
  }
});


// Endpoint to create new community 
app.post('/communitiesM', async (req, res) => {
  let communityInfo = req.body;
  try {
    let response = await communityFunctions.create_community(communityInfo);
    res.send(response);
  } catch (error) {
    console.log('error : ' + error);
    res.send({ error: error.message });
  }
});


// Endpoint for adding new member to community 
app.put('/communitiesM/:Community_Id/addMember', async (req, res) => {
  // extract the community id 
  let communityId = req.params.Community_Id;
  let memberId = req.body.User_Id;
  if (!communityId || !memberId) {
    res.send({ error: "please provide the community to add memeber to or make sure you added memeber info " })
  }
  try {
    let response = await communityFunctions.add_member(communityId, memberId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to remove member from community
app.delete('/communitiesM/:Community_Id/removeMember', async (req, res) => {
  let communityId = req.params.Community_Id;
  let memberId = req.query.User_Id;
  if (!communityId || !memberId) {
    res.send({ error: "please provide the community to remove memeber from or make sure you added memeber info " })
  }
  try {
    let response = await communityFunctions.remove_member(communityId, memberId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to retrieve all members of a community
app.get('/communitiesM/:Community_Id/members', async (req, res) => {
  let communityId = req.params.Community_Id;
  if (!communityId) {
    res.send({ error: "please provide the community to retrieve its members " })
  }
  try {
    let response = await communityFunctions.get_members(communityId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to block member from community
app.put('/communitiesM/:Community_Id/blockMember', async (req, res) => {
  let communityId = req.params.Community_Id;
  let memberId = req.body.User_Id;
  if (!communityId || !memberId) {
    res.send({ error: "please provide the community to block memeber from or make sure you added memeber info " })
  }
  try {
    let response = await communityFunctions.block_member(communityId, memberId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to unblock member from community
app.put('/communitiesM/:Community_Id/unblockMember', async (req, res) => {
  let communityId = req.params.Community_Id;
  let memberId = req.body.User_Id;
  if (!communityId || !memberId) {
    res.send({ error: "please provide the community to unblock memeber from or make sure you added memeber info " })
  }
  try {
    let response = await communityFunctions.unblock_member(communityId, memberId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to retrieve all blocked members of a community
app.get('/communitiesM/:Community_Id/blockedMembers', async (req, res) => {
  let communityId = req.params.Community_Id;
  if (!communityId) {
    res.send({ error: "please provide the community to retrieve its blocked members " })
  }
  try {
    let response = await communityFunctions.get_blocked_members(communityId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to add a moderator to the community
app.put('/communitiesM/:Community_Id/addModerator', async (req, res) => {
  let communityId = req.params.Community_Id;
  let memberId = req.body.User_Id;
  if (!communityId || !memberId) {
    res.send({ error: "please provide the community to add moderator to or make sure you added moderator info " })
  }
  try {
    let response = await communityFunctions.add_moderator(communityId, memberId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to remove a moderator from the community
app.put('/communitiesM/:Community_Id/removeModerator', async (req, res) => {
  let communityId = req.params.Community_Id;
  let memberId = req.body.User_Id;
  if (!communityId || !memberId) {
    return res.status(400).send({ error: "please provide the community to remove moderator from or make sure you added moderator info " });
  }
  try {
    let response = await communityFunctions.remove_moderator(communityId, memberId);
    if(response.error){
      throw new Error(response.error);
    }
    res.status(200).send(response);
  } catch (error) {
    console.log('error');
    res.status(500).send({ error: error.message });
  }
});

// Endpoint to retrieve all moderators of a community
app.get('/communitiesM/:Community_Id/moderators', async (req, res) => {
  let communityId = req.params.Community_Id;
  if (!communityId) {
    res.send({ error: "please provide the community to retrieve its moderators " })
  }
  try {
    let response = await communityFunctions.get_moderators(communityId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to get the owner of the community
app.get('/communitiesM/:Community_Id/owner', async (req, res) => {
  let communityId = req.params.Community_Id;
  if (!communityId) {
    res.send({ error: "please provide the community to retrieve its owner " })
  }
  try {
    let response = await communityFunctions.get_owner(communityId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
    console.log("ddddddddddddddd");
  }
});

// Endpoint to make a community private
app.put('/communitiesM/:Community_Id/makePrivate', async (req, res) => {
  let communityId = req.params.Community_Id;
  let password = req.body.Password;
  if (!communityId || !password) {
    res.send({ error: "please provide the community and password to make it private " })
  }
  try {
    let response = await communityFunctions.make_private(communityId, password);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to make a community public
app.put('/communitiesM/:Community_Id/makePublic', async (req, res) => {
  let communityId = req.params.Community_Id;
  if (!communityId) {
    res.send({ error: "please provide the community to make it public " })
  }
  try {
    let response = await communityFunctions.make_public(communityId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


//Endpoint to add a post to the community
app.post('/communitiesM/:Community_Id/posts/addPost', async (req, res) => {
  let communityId = req.params.Community_Id;
  let post = req.body.post;
  try {
    let response = await communityFunctions.add_post(communityId, post);
    res.send(response);
  }
  catch (error) {
    console.log('error : ' + error);
    res.send({ error: error.message });
  }
});


// Endpoint to get post data 
// To retrieve all posts in a community, send the commuinty id in the request query
// To retrieve a specific post of a particular community, send the post id in the request
app.get('/communitiesM/:Community_Id/posts', async (req, res) => {
  let communityId = req.params.Community_Id;
  var Post_Id = req.query.Post_Id;
  // By default, the option is to get the community posts
  var option = "community";
  // If the Post_Id is provided, the option is to get the post itself
  if (Post_Id != "undefined" && Post_Id) {
    option = "post";
  }
  let response = await communityFunctions.get_post(Post_Id, communityId, option);

  // Depending on the response, respond with the community information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});


// Endpoint to get top posts in a community (most liked posts)
app.get('/communitiesM/:Community_Id/posts/topPosts', async (req, res) => {
  let communityId = req.params.Community_Id;
  let response = await communityFunctions.get_top_posts(communityId);
  // Depending on the response, respond with the community information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});


// Endpoint to delete post
app.delete("/communitiesM/:Community_Id/posts/removePost/:Post_Id", async (req, res) => {
  let postId = req.params.Post_Id;
  let communityId = req.params.Community_Id;
  try {
    let response = await communityFunctions.remove_post(postId);
    if (response) {
      var option = "community";
      response = await communityFunctions.get_post(null, communityId, option);
    }
    else {
      response = { error: "Post not found" };
    }
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to add a reply to the post
// Post_Id is the id of the post to add the reply to
// The reply is the content of the reply
app.post('/communitiesM/posts/:Post_Id/replies/addReply', async (req, res) => {
  let postId = req.params.Post_Id;
  let reply = req.body.reply;
  try {
    let response = await communityFunctions.add_reply(postId, reply);
    res.send(response);
  }
  catch (error) {
    console.log('error : ' + error);
    res.send({ error: error.message });
  }
});


// Endpoint to get reply data
// To retrieve all replies in a post, send the post id in the request query
// To retrieve a specific reply of a particular post, send the reply id in the request
app.get('/communitiesM/posts/:Post_Id/replies', async (req, res) => {
  let postId = req.params.Post_Id;
  var replyId = req.query.Reply_Id;
  let response = await communityFunctions.get_reply(replyId, postId);
  // Depending on the response, respond with the community information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});


// Endpoint to get the number of replies in a post
app.get('/communitiesM/posts/:Post_Id/replies/repliesCount', async (req, res) => {
  let postId = req.params.Post_Id;
  let response = await communityFunctions.get_reply_count(postId);
  // Depending on the response, respond with the community information or an error message
  if (response) {
    res.send(response);
  } else {
    res.send("No matching documents");
  }
});


// Endpoint to delete reply
app.delete("/communitiesM/posts/:Post_Id/replies/removeReply/:Reply_Id", async (req, res) => {
  let postId = req.params.Post_Id;
  let replyId = req.params.Reply_Id;
  try {
    let response = await communityFunctions.remove_reply(postId,replyId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to like a post
// Post_Id is the id of the post to like
// User_Id is the id of the user who liked the post
// The user can not like the same post more than once


app.put('/communitiesM/posts/:Post_Id/likePost', async (req, res) => {
  let postId = req.params.Post_Id;
  let userId = req.body.User_Id;
  if (!postId || !userId) {
    res.send({ error: "please provide the post to like or make sure you added user info " })
  }
  try {
    let response = await communityFunctions.like_post(postId, userId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});

// Endpoint to unlike a post
// Post_Id is the id of the post to unlike
// User_Id is the id of the user who unliked the post
app.put('/communitiesM/posts/:Post_Id/unlikePost', async (req, res) => {
  let postId = req.params.Post_Id;
  let userId = req.body.User_Id;
  if (!postId || !userId) {
    res.send({ error: "please provide the post to unlike or make sure you added user info " })
  }
  try {
    let response = await communityFunctions.unlike_post(postId, userId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to like a reply
// Reply_Id is the id of the reply to like
// User_Id is the id of the user who liked the reply
// The user can not like the same reply more than once
app.put('/communitiesM/posts/:Post_Id/replies/:Reply_Id/likeReply', async (req, res) => {
  let replyId = req.params.Reply_Id;
  let userId = req.body.User_Id;
  let postId = req.params.Post_Id;
  if (!replyId || !userId) {
    res.send({ error: "please provide the reply to like or make sure you added user info " })
  }
  try {
    let response = await communityFunctions.like_reply(replyId, userId, postId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to unlike a reply
// Reply_Id is the id of the reply to unlike
// User_Id is the id of the user who unliked the reply
app.put('/communitiesM/posts/:Post_Id/replies/:Reply_Id/unlikeReply', async (req, res) => {
  let replyId = req.params.Reply_Id;
  let userId = req.body.User_Id;
  let postId = req.params.Post_Id;
  if (!replyId || !userId) {
    res.send({ error: "please provide the reply to unlike or make sure you added user info " })
  }
  try {
    let response = await communityFunctions.unlike_reply(replyId, userId, postId);
    res.send(response);
  } catch (error) {
    res.send({ error: error.message });
  }
});


// Endpoint to get followed communities of a user
app.get('/communitiesM/followedCommunities', async (req, res) => {
  let CommunitiesReferences = req.query.CommunitiesReferences;
  try {
    let response = await communityFunctions.get_followed_communities(CommunitiesReferences);
    res.send(response);
  }
  catch (error) {
    res.send({ error: error.message });
  }
});


// store the community or Post image in the media service and store the image url in the database
app.post("/communitiesM/upload", upload.single("file"), (req, res) => {
  get_image_URL(req).then((url) => {
    // edit and Add the image url to the community in the database
    const updateObject = { [req.body.image_name]: url };
    if (req.body.collection == "Community") {
      communityFunctions.edit_community(req.body.id, updateObject).then((result) => {
        res.send(result);
      });
    } else if (req.body.collection == "Posts") {
      communityFunctions.edit_post(req.body.id, updateObject).then((result) => {
        res.send(result);
      });
    }
  });
});



app.post("/communitiesM/uploads", upload.single("file"), (req, res) => {
  get_image_URL(req).then((url) => {
    const updateObject = { map_key: req.body.image_name, value: url };
    if (req.body.sub_collection) {
      communityFunctions.edit_reply(req.body.id, req.body.sub_id, updateObject).then((result) => {
        res.send(result);
      });
    } else {
      communityFunctions.edit_post(req.body.id, updateObject).then((result) => {
        res.send(result);
      });
    }
  });
});



///////////////////////////////////
// Small APIs functions for communication between microservices
///////////////////////////////////

// Get the community image url from the media service
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
  // check if the req.body has the sub_collection field, if it has append it as collection as well as the id as sub_id
  if (req.body.sub_collection) {
    formData.append("collection", req.body.sub_collection);
    formData.append("id", req.body.sub_id);
  } else {
    formData.append("collection", req.body.collection);
    formData.append("id", req.body.id);
  }

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


app.listen(port, () => {
  console.log("Community Server is running on port " + port);
});
