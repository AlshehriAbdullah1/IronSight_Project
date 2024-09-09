import React from 'react'
import NavPanel from '../NavPanel'
import '../../css/components/reportedUsers.css'
import CommunityListReports from "./CommunityListReports";

const ReportsCommunities = () => {
  return (
    <div className='content'>
    <div className='title'>
    Community Reports
    </div>
    <div className="report-container">
      <h2 className="report-title">Current Reports</h2>
      <p className="report-number">5</p>
    </div>
    <div className="userlist-table-label">
      <h2>Current Community Reports</h2>
      
      </div>
      <CommunityListReports />
    </div>
  )
}

export default ReportsCommunities