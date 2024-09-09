import React, { useState } from "react";
import "../../css/components/UserListReports.css";

function UserListBanned() {
  const usersData = [
    { username: "@JoJo", id: "000001", numberOfReports: "3", isBanned: "True"},
    { username: "@JoJoFan", id: "000002" , numberOfReports: "3", isBanned: "True"},
    { username: "@JoJoSiwa", id: "000003" , numberOfReports: "3", isBanned: "True"},
    { username: "@7ussx", id: "444" , numberOfReports: "3", isBanned: "True"},
    { username: "@test", id: "000001" , numberOfReports: "3", isBanned: "True"}
  ];

  const [users, setUsers] = useState(usersData);

  const handleActionClick = (username) => {
    const confirmBan = window.confirm(`Are you sure you want to unban ${username}?`);
    if (confirmBan) {
      // Handle the ban action here
    }
  };

  return (
    <div className="UserListReports-container">
      <div className="UserListReports">
        <div className="UserListReports-item-labels">
          <div className="UserListReport-info">
            <span className="UserNameReports-label">User Name</span>
          </div>
  
          <div className="user-id-Reports-label">
            <span>User ID</span>
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
        {users.map((user) => (
          <div key={user.username + user.id + user.numberOfReports + user.isBanned} className="UserListReports-item">
            <div className="UserListReport-info">
              <span className="UserNameReports">{user.username}</span>
            </div>
  
            <div className="user-id-Reports">
              <span>{user.id}</span>
            </div>
            
            <div className="user-numOfReports-Reports">
              <span>{user.numberOfReports}</span>
            </div>
  
            <div className="user-isBanned-Reports">
              <span>{user.isBanned}</span>
            </div>
  
            <button className="action-button" onClick={() => handleActionClick(user.username)}>Unban</button>
          </div>
        ))}
        {users.length === 0 && <div>No results found.</div>}
      </div>
    </div>
  );
}

export default UserListBanned;