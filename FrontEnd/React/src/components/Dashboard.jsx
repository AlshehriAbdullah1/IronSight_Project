// import React, { useContext } from "react";
// import { Routes, Route, Navigate } from "react-router-dom";
// import { UserContext } from "../UserContext";
// import NavPanel from "./NavPanel";
// import '../css/components/dashboard.css';
// import ReportedUsers from "./reports/ReportedUsers";
// import ReportsCommunities from "./reports/ReportsCommunities";
// import ReportsTournaments from "./reports/ReportsTournaments";
// import ReportsPosts from "./reports/ReportsPosts";
// import VerificationsUsers from "./verifications/VerificationsUsers";
// import VerificationsCommunities from "./verifications/VerificationsCommunities";
// import VerificationsTournaments from "./verifications/VerificationsTournaments";
// import BannedUsers from "./banned/BannedUsers";
// import BannedCommunities from "./banned/BannedCommunities";
// import BannedTournaments from "./banned/BannedTournaments";
// import SuggestionsGame from "./suggestions/SuggestionsGame";
// import SuggestionsGeneral from "./suggestions/SuggestionsGeneral";

// function Dashboard() {
//   const { user, ready } = useContext(UserContext);

//   if (!ready) {
//     return <div>Loading...</div>;
//   }

//   if (!user) {
//     return <Navigate to="/login" />;
//   }

//   return (
//     <div className="main">
//       <div className="navPanel">
//         <NavPanel />
//       </div>
//       <div className="dashboard">
//       <h1>Dashboard</h1>
//       </div>
//     </div>
//   );
// }

// export default Dashboard;
