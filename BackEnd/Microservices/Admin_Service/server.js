const express = require("express");
const cors = require("cors");
const axios = require("axios");
require("dotenv").config({ path: "../../.env" });

const adminFunctions = require("./adminFunctions.js");

const app = express();
app.use(cors());
app.use(express.json());

const port = process.env.ADMIN_PORT || 3008;

// Endpoint for getting specific admin by calling the get_admin function from adminFunctions.js
app.get("/adminsM/:Admin_Id", (req, res) => {
  var Admin_Id = req.params.Admin_Id;
  adminFunctions.get_admin(Admin_Id).then((result) => {
    res.send(result);
  });
});


app.listen(port, () => {
  console.log(`Admin Service is running on port ${port}`);
});
