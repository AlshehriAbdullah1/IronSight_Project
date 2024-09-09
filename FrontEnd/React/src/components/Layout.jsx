import React from "react";
import { useContext } from "react";
import { Outlet, useOutlet } from "react-router-dom";
import NavPanel from "./NavPanel";
import "../css/components/layout.css"; // Import the new CSS file
import Test from "./Test";
import { UserContext } from "../UserContext";
import DashWelcome from "./DashWelcome";

function Layout() {
  const outlet = useOutlet();
  const { user, ready } = useContext(UserContext);

  if (!ready) {
    return <p>Loading...</p>;
  }

  return (
    <div className="layout">
      <NavPanel />
      <div className="content">
        {outlet || <DashWelcome />}
      </div>
    </div>
  );
}

export default Layout;