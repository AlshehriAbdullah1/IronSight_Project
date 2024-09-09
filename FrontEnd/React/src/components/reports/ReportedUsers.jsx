import React from 'react'
import '../../css/components/reportedUsers.css'
import UserListReports from "./UserListReports";

const ReportedUsers = () => {
  return (
    <div className='content'>
      <div className='title'>
        User Reports
      </div>
      <div className="report-container">
        <h2 className="report-title">Current Reports</h2>
        <p className="report-number">5</p>
      </div>
      <div className="userlist-table-label">
        <h2>Current User Reports</h2>
      </div>
      <UserListReports />
    </div>
  )
}

export default ReportedUsers