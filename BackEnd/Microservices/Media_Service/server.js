// Import required modules
const express = require("express");
const cors = require("cors");
const { Storage } = require("@google-cloud/storage");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
require("dotenv").config({ path: '../../.env' });

// Set up Express app and middleware
const app = express();
app.use(cors());
app.use(express.json());

// Define constants
const port = process.env.MEDIA_PORT || 4005;

// Set up Google Cloud Storage
const storage = new Storage();

// Set Google Cloud credentials
process.env.GOOGLE_APPLICATION_CREDENTIALS = path.join(__dirname, "key.json");

// Initialize multer with the destination folder for uploaded files
const upload = multer({ dest: "uploads/" });
//const upload = multer();

// Specify the name of the bucket
const bucketName = "ironsight-media";

// Endpoints
// Endpoint to upload a file to Google Cloud Storage
app.post("/mediaM/upload", upload.single("file"), async (req, res) => {
  try {
    // Get the file and the fromMicroservice and id from the request
    const file = req.file;
    const collection = req.body.collection;
    const id = req.body.id;
    // Upload the file to the specified bucket and folder
    const response = await storage.bucket(bucketName).upload(file.path, {
      destination: `${collection}/${id}/${file.originalname}`,
    });

    // Delete the local file
    fs.unlink(file.path, err => {
      if (err) {
        console.error('Error deleting file:', err);
      }
    });

    // return the public url of the uploaded file
    res.send(response[0].metadata.mediaLink);
  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).send({ error: 'Error uploading file' });
  }
});

// Start the server
app.listen(port, () => {
  console.log("Media Server is running on port " + port);
});
