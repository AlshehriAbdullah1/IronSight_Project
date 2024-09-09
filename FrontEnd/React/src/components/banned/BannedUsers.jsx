import React from 'react'
import UserListBanned from "./UserListBanned";

const BannedUsers = () => {
  return (
    <div className='content'>
    <div className='title'>
      Banned Users
    </div>
    <div className="banned-container">
      <h2 className="banned-title">Currently Banned</h2>
      <p className="banned-number">5</p>

      <hr className='counter-container'/>

      <div className="counter-container">
        <div className="counter-text-container">
          <p className="counter-text">Temporary</p>
          <p className="counter-text">Permanent</p>
          <p className="counter-text">Pending Reports</p>
        </div>

        <div className="counter-number-container">
          <p className="counter-text">12</p>
          <p className="counter-text">15</p>
          <p className="counter-text">3</p>
        </div>
      </div>
    </div>
    <div className="userlist-table-label">
      <h2>Current Users Banned</h2>
      
      </div>
      <UserListBanned />
  </div>
  )
}

export default BannedUsers