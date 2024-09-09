import React from "react";
import "../../css/components/verificationsUsers.css";
import UserList from "./UserList";

const VerificationsUsers = () => {
  return (
    <div className="main">
      
      <div className="title">
        Users Verifications
        </div>

      <div className="userList"> 
        <UserList />
      </div>
    </div>
  );
};

export default VerificationsUsers;
