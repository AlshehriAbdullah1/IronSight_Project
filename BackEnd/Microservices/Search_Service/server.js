const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const port = process.env.SEARCH_PORT || 4007;

const searchFunctions = require("./searchFunctions.js");


app.get("/searchM/:collection", async (req, res) => {
    try{
        var searchValue = req.query.SearchQuery;
        var collection = req.params.collection;
        var response = await searchFunctions.search(collection,searchValue);
        if (response) {
            // console.log("The response is: ", response);
            res.send(response);
        }
        else {
            res.send("No results found");
        }
    }
    catch (error) {
        console.log(error);
        res.send("An error occured");
    }
  }
);


app.get("/hi", (req, res) => {
    res.send("Hello World");
  });



app.listen(port, () => {
    console.log("Search Service is running on port " + port);
});

    
  