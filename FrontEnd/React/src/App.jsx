import { Routes, Route, Navigate } from "react-router-dom";
import "./App.css";
import LandingPage from "./components/LandingPage";
import LoginPage from "./components/LoginPage";
//import Dashboard from "./components/Dashboard";
import { UserContextProvider } from "./UserContext";
//import DashboardLayout from "./components/DashboardLayout";
import ReportedUsers from "./components/reports/ReportedUsers";
import Layout from "./components/Layout";
// import Test from "./components/Test";
import ReportsCommunities from "./components/reports/ReportsCommunities";
import ReportsTournaments from './components/reports/ReportsTournaments';
import ReportsPosts from './components/reports/ReportsPosts';
import VerificationsUsers from './components/verifications/VerificationsUsers';
import VerificationsCommunities from './components/verifications/VerificationsCommunities';
import VerificationsTournaments from './components/verifications/VerificationsTournaments';
import BannedUsers from './components/banned/BannedUsers';
import BannedCommunities from './components/banned/BannedCommunities';
import BannedTournaments from './components/banned/BannedTournaments';
import SuggestionsGame from './components/suggestions/SuggestionsGame';
import SuggestionsGeneral from './components/suggestions/SuggestionsGeneral';
import CreateGame from "./components/CreateGame";

import axios from "axios";
axios.defaults.baseURL = import.meta.env.VITE_APP_BASE_URL;

function App() {

  return (
    <UserContextProvider>
      <Routes>
        <Route path="/" element={<Navigate to="/landing" />} />
        <Route path="/landing" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard/*" element={<Layout />}>
          <Route path="reports/reports-users" element={<ReportedUsers />} />
          <Route path="reports/reports-communities" element={<ReportsCommunities />} />
          <Route path='reports/reports-tournaments' element={< ReportsTournaments />} />
          <Route path='reports/reports-posts' element={< ReportsPosts />} />
          <Route path='verifications/verifications-users' element={< VerificationsUsers />} />
          <Route path='verifications/verifications-communities' element={< VerificationsCommunities />} />
          <Route path='verifications/verifications-tournaments' element={< VerificationsTournaments />} />
          <Route path='banned/banned-users' element={< BannedUsers />} />
          <Route path='banned/banned-communities' element={< BannedCommunities />} />
          <Route path='banned/banned-tournaments' element={< BannedTournaments />} />
          <Route path='suggestions/suggestions-game' element={< SuggestionsGame />} />
          <Route path='suggestions/suggestions-general' element={< SuggestionsGeneral />} />
          <Route path='suggestions/suggestions-game/create-game' element={< CreateGame />} />
        </Route>
      </Routes>
    </UserContextProvider>
  );
}

export default App;
