import React from 'react';
import NavPanel from './NavPanel';
import Dashboard from './Dashboard'; 

const DashboardLayout = () => {
  return (
    <div className="dashboard-layout">
      <NavPanel />
      <Dashboard /> 
    </div>
  );
};

export default DashboardLayout;