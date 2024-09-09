import React from 'react'
import '../../css/components/reportedUsers.css'
import PostsListReports from "./PostsListReports";

const ReportsPosts = () => {
  return (
    <div className='content'>
    <div className='title'>
      Posts Reports
    </div>
    <div className="report-container">
      <h2 className="report-title">Current Reports</h2>
      <p className="report-number">5</p>
    </div>
    <div className="userlist-table-label">
      <h2>Current Post Reports</h2>
      
      </div>
      <PostsListReports />
    </div>
  )
}

export default ReportsPosts