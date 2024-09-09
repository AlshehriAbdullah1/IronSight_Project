import React from 'react'
import '../../css/components/reportedUsers.css'
import TournamentListReports from "./TournamentListReports";

const ReportsTournaments = () => {
  return (
    <div className='content'>
    <div className='title'>
      Tournament Reports
    </div>
    <div className="report-container">
      <h2 className="report-title">Current Reports</h2>
      <p className="report-number">5</p>
    </div>
    <div className="userlist-table-label">
      <h2>Current Tournament Reports</h2>
      
      </div>
      <TournamentListReports />
    </div>
  )
}

export default ReportsTournaments