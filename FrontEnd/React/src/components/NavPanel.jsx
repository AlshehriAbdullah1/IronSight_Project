import React, { useState, useContext } from "react";
import { Link } from "react-router-dom";
import avatar from "../assets/avatar.jpg";
import "../css/components/navPanel.css";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faChevronRight, faChevronDown } from '@fortawesome/free-solid-svg-icons';
import { UserContext } from "../UserContext";
import { auth } from "../DB/firebase";

function NavPanel() {
  const [activeMenus, setActiveMenus] = useState({});
  const [selectedSubItem, setSelectedSubItem] = useState(null);  // New state for tracking selected sub-item
  const { user } = useContext(UserContext);

  const handleMenuClick = (menu) => {
    setActiveMenus((prev) => ({
      ...prev,
      [menu]: !prev[menu],
    }));
  };

  const handleSubItemClick = (sub) => {
    setSelectedSubItem(sub);  // Update the selected sub-item
  };



  const MenuItem = ({ name, subItems, basePath }) => (
    <div>
      <button
        className={`menu-item ${activeMenus[name] ? "active" : ""}`}
        onClick={() => handleMenuClick(name)}
      >
        {name}
        <FontAwesomeIcon icon={activeMenus[name] ? faChevronDown : faChevronRight} className="menu-icon" />
      </button>
      {activeMenus[name] && (
        <div className="submenu">
          {subItems.map((sub) => (
            <Link
              key={sub}
              to={`${basePath}/${sub.replace(/([A-Z])/g, "-$1").toLowerCase().slice(1)}`}
              className={`sub-item-link ${selectedSubItem === sub ? "selected" : ""}`}
              onClick={() => handleSubItemClick(sub)}
            >
              <button className="sub-item">
                {sub.replace(/([A-Z])/g, " $1").trim()}
              </button>
            </Link>
          ))}
        </div>
      )}
    </div>
  );


  const u = {
    // if user is not logged in, the name will be "Guest"
    name: user.Email,

    avatar: avatar,
  };

  const handleLogout = async () => {
    try {
      await auth.signOut();
    } catch (error) {
      console.error("Error signing out", error);
    }
  };

  return (
    <div className="nav-panel">
      <div className="user-info">
        <img src={u.avatar} alt="User Avatar" className="user-avatar" />
        <span className="user-name">{u.name}</span>
      </div>
      <MenuItem
        name="Reports"
        subItems={["ReportsUsers", "ReportsCommunities", "ReportsTournaments", "ReportsPosts"]}
        basePath="reports"
      />
      <MenuItem
        name="Verifications"
        subItems={["VerificationsUsers", "VerificationsCommunities", "VerificationsTournaments"]}
        basePath="verifications"
      />
      <MenuItem
        name="Banned"
        subItems={["BannedUsers", "BannedCommunities", "BannedTournaments"]}
        basePath="banned"
      />
      <MenuItem
        name="Suggestions"
        subItems={["SuggestionsGame", "SuggestionsGeneral"]}
        basePath="suggestions"
      />
      {user && (
        <button onClick={handleLogout} className="logout-button">
          Logout
        </button>
      )}
    </div>
  );
}

export default NavPanel;
