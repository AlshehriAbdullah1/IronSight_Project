import React, { useState } from "react";
import "../../css/components/UserList.css";

function TournamentList() {
  const tournamentData = [
    { name: "Tournament X", id: "X001" },
    { name: "Tournament Y", id: "Y002" },
    { name: "Tournament Z", id: "Z003" }
  ];

  const [searchTerm, setSearchTerm] = useState("");
  const [tournaments, setTournaments] = useState(tournamentData);
  const [showModal, setShowModal] = useState(false);
  const [currentTournament, setCurrentTournament] = useState(null);

  const handleSearchChange = (event) => {
    const { value } = event.target;
    setSearchTerm(value);
    filterTournaments(value);
  };

  const filterTournaments = (term) => {
    setTournaments(term ? tournamentData.filter(tournament =>
      tournament.name.toLowerCase().includes(term.toLowerCase())
    ) : tournamentData);
  };

  const handleActionClick = (tournament) => {
    setShowModal(true);
    setCurrentTournament(tournament);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  return (
    <div className="user-list-container">
      <input
        type="text"
        placeholder="Search Tournaments"
        value={searchTerm}
        onChange={handleSearchChange}
        className="search-bar"
      />
      <div className="user-list">
        {tournaments.map((tournament) => (
          <div key={tournament.id} className="user-item">
            <div className="user-info">
              <span className="username">{tournament.name}</span>
            </div>
            <div className="user-id">
              <span>{tournament.id}</span>
            </div>
            <button className="verify-button" onClick={() => handleActionClick(tournament)}>Verify</button>
          </div>
        ))}
        {tournaments.length === 0 && <div>No results found.</div>}
      </div>
      {showModal && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <button onClick={closeModal} className="close-button">X</button>
            <h4>Are you sure you want to Verify this tournament?</h4>
            <div className="buttons-row">
            <button className='verification' onClick={() => { console.log("Verify tournament:", currentTournament); closeModal(); }} >Verify</button>
            <button className='rejection' onClick={() => { console.log("Reject tournament:", currentTournament); closeModal(); }} >Reject</button>
          </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default TournamentList;
