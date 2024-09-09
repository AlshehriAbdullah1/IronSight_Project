import React, { useState } from "react";
import "../../css/components/UserList.css";

function UserList() {
  const usersData = [
    { username: "@JoJo", id: "000001" },
    { username: "@JoJoFan", id: "000002" },
    { username: "@JoJoSiwa", id: "000003" },
    { username: "@7ussx", id: "444" },
    { username: "@test", id: "000001" }
  ];

  const [searchTerm, setSearchTerm] = useState("");
  const [users, setUsers] = useState(usersData);
  const [showModal, setShowModal] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);

  const handleSearchChange = (event) => {
    const { value } = event.target;
    setSearchTerm(value);
    filterUsers(value);
  };

  const filterUsers = (term) => {
    if (!term) {
      setUsers(usersData);
    } else {
      const filtered = usersData.filter(user =>
        user.username.toLowerCase().includes(term.toLowerCase())
      );
      setUsers(filtered);
    }
  };

  const handleVerifyClick = (user) => {
    setShowModal(true);
    setCurrentUser(user);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  return (
    <div className="user-list-container">
      <input
        type="text"
        placeholder="Search Users"
        value={searchTerm}
        onChange={handleSearchChange}
        className="search-bar"
      />
      <div className="user-list">
        {users.map((user) => (
          <div key={user.username + user.id} className="user-item">
            <div className="user-info">
              <span className="username">{user.username}</span>
            </div>
            <div className="user-id">
              <span>{user.id}</span>
            </div>
            <button className="verify-button" onClick={() => handleVerifyClick(user)}>Verify</button>
          </div>
        ))}
        {users.length === 0 && <div>No results found.</div>}
      </div>
      {showModal && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <button onClick={closeModal} className="close-button">X</button>
            <h4>Are you sure you want to verify this user?</h4>
            <div className="buttons-row">
            <button className="rejection" onClick={() => { console.log("Reject user:", currentUser); closeModal(); }}>Reject</button>
            <button className='verification' onClick={() => { console.log("Verify user:", currentUser); closeModal(); }}>Verify</button>

            </div>
            
          </div>
        </div>
      )}
    </div>
  );
}

export default UserList;
