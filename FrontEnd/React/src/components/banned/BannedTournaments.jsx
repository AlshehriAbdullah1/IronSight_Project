import React from 'react'
import '../../css/components/banned.css'
import TournamentListBanned from "./TournamentListBanned";

const BannedTournaments = () => {
  return (
    <div className='content'>
      <div className='title'>
        Banned Tournaments
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
      <h2>Current Tournaments Banned</h2>
      
      </div>
      <TournamentListBanned />
    </div>
  )
}

export default BannedTournaments