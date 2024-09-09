import React, { useState } from "react";
import "../../css/components/UserListReports.css";

function TournamentListReports() {
  const tournamentsData = [
    { tournamentName: "@JoJo", id: "000001", numberOfReports: "3", isBanned: "True"},
    { tournamentName: "@JoJoFan", id: "000002" , numberOfReports: "3", isBanned: "True"},
    { tournamentName: "@JoJoSiwa", id: "000003" , numberOfReports: "3", isBanned: "True"},
    { tournamentName: "@7ussx", id: "444" , numberOfReports: "3", isBanned: "True"},
    { tournamentName: "@test", id: "000001" , numberOfReports: "3", isBanned: "True"}
  ];

  const [tournaments, setTournaments] = useState(tournamentsData);

  const handleActionClick = (tournamentName) => {
    const confirmBan = window.confirm(`Are you sure you want to ban ${tournamentName}?`);
    if (confirmBan) {
      // Handle the ban action here
    }
  };

  return (
    <div className="UserListReports-container">
      <div className="UserListReports">
        <div className="UserListReports-item-labels">
          <div className="UserListReport-info">
            <span className="UserNameReports-label">Tournament Name</span>
          </div>
  
          <div className="user-id-Reports-label">
            <span>Tournament ID</span>
          </div>
          
          <div className="user-numOfReports-Reports-label">
            <span>Number of Reports</span>
          </div>
  
          <div className="user-isBanned-Reports-label">
            <span>Banned Before?</span>
          </div>

          <div className="user-action-Reports-label">
            <span>Action</span>
          </div>
        </div>
        {tournaments.map((tournament) => (
          <div key={tournament.tournamentName + tournament.id + tournament.numberOfReports + tournament.isBanned} className="UserListReports-item">
            <div className="UserListReport-info">
              <span className="UserNameReports">{tournament.tournamentName}</span>
            </div>
  
            <div className="user-id-Reports">
              <span>{tournament.id}</span>
            </div>
            
            <div className="user-numOfReports-Reports">
              <span>{tournament.numberOfReports}</span>
            </div>
  
            <div className="user-isBanned-Reports">
              <span>{tournament.isBanned}</span>
            </div>
  
            <button className="action-button" onClick={() => handleActionClick(tournament.tournamentName)}>Ban</button>
          </div>
        ))}
        {tournaments.length === 0 && <div>No results found.</div>}
      </div>
    </div>
  );
}

export default TournamentListReports;