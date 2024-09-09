import React, { useState } from "react";
import { useEffect } from "react";
import "../../css/components/SuggestionsGameList.css";
import axios from "axios";
import CreateGame from "../CreateGame";
import { Link, Navigate } from "react-router-dom";
import { useNavigate } from "react-router-dom";

function SuggestionsGameList(props) {
  const navigate = useNavigate();
  const [suggestions, setSuggestions] = useState([]);
  useEffect(() => {
    props.setNumOfSuggest(
      suggestions.filter((suggestion) => suggestion.State === "Pending").length
    );
  }, [suggestions, props]);

  const handleAcceptClick = (Suggestion_Id) => {
    axios
      .put(`/games/suggestions/${Suggestion_Id}`, { State: "Accepted" })
      .then((response) => {
        // Update the local state
        setSuggestions(
          suggestions.map((suggestion) =>
            suggestion.Suggestion_Id === Suggestion_Id
              ? { ...suggestion, State: "Accepted" }
              : suggestion
          )
        );
      })
      .catch((error) => {
        console.error(error);
      });
  };

  const handleRejectClick = (Suggestion_Id) => {
    axios
      .put(`/games/suggestions/${Suggestion_Id}`, { State: "Rejected" })
      .then((response) => {
        // Update the local state
        setSuggestions(
          suggestions.map((suggestion) =>
            suggestion.Suggestion_Id === Suggestion_Id
              ? { ...suggestion, State: "Rejected" }
              : suggestion
          )
        );
      })
      .catch((error) => {
        console.error(error);
      });
  };

  useEffect(() => {
    axios
      .get("/games/suggestions")
      .then((response) => {
        setSuggestions(response.data);
      })
      .catch((error) => {
        console.error(error);
      });
  }, []);

  const renderTable = (State) => (
    <div className="SuggestionsGameList">
      <div className="SuggestionsGameList-item-labels">
        <div className="SuggestionsGameList-info">
          <span className="GameName-label">Game Name</span>
        </div>

        <div className="game-description-label">
          <span>Description</span>
        </div>

        <div className="game-genre-label">
          <span>Genre</span>
        </div>

        <div className="game-state-label">
          <span>State</span>
        </div>

        {State === "Pending" && (
          <div className="game-action-label">
            <span>Action</span>
          </div>
        )}
      </div>
      {suggestions
        .filter((suggestion) => suggestion.State === State)
        .map((suggestion) => (
          <div
            key={suggestion.Suggestion_Id}
            className="SuggestionsGameList-item"
          >
            <div className="SuggestionsGameList-info">
              <span className="GameName">{suggestion.Name}</span>
            </div>

            <div className="game-description">
              <span>{suggestion.Description}</span>
            </div>

            <div className="game-genre">
              <span>{suggestion.Genre.join(", ")}</span>
            </div>

            <div className="game-state">
              <span>{suggestion.State}</span>
            </div>

            {State === "Pending" && (
              <div >
                <button
                  className="accept-button mr-2"
                  onClick={() => handleAcceptClick(suggestion.Suggestion_Id)}
                >
                  Accept
                </button>
                <button
                  className="reject-button"
                  onClick={() => handleRejectClick(suggestion.Suggestion_Id)}
                >
                  Reject
                </button>
              </div>
            )}
          </div>
        ))}
    </div>
  );

  return (
    // add a button to navigate to the create game page
    <div>
      <div>
        <Link to="create-game">
          <button className="create-game-button" >
            Add Game
          </button>
        </Link>
      </div>
      <div className="SuggestionsGameList-container my-9">
        <div className="pb-9">{renderTable("Pending")}</div>
        <div className="pb-9">{renderTable("Accepted")}</div>
        <div className="pb-9">{renderTable("Rejected")}</div>
      </div>
    </div>
  );
}

export default SuggestionsGameList;
