const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config({ path: '../../.env' });

const app = express();
app.use(cors());
app.use(express.json());

const port = process.env.CHAT_PORT;


// Endpoint to start a new chat
app.post('/chatsM/startChat', (req, res) => {
  axios.post(`${process.env.CHAT_HOST}/chatM`, req.body)
    .then((response) => {
      res.send(response.data);
    })
    .catch((error) => {
      res.send(error);
    });
});

app.listen(port, () => {
  console.log(`Chat Service is running on port ${port}`);
});