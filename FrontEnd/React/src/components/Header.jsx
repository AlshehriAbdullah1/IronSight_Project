import React from "react";
import { useContext } from "react";
import { Link } from "react-router-dom";
import '../css/components/header.css';
import Logo from '../assets/Logo.png';
import Textlogo from '../assets/TextLogo.png';
// import the user context so that the login button can be conditionally rendered based on the user's login status,
// if the user is logged in, the login button will not be shown and will be replaced with button to the dashboard
// if the user is not logged in, the login button will be shown
import { UserContext } from "../UserContext";





function Header() {
  const { user } = useContext(UserContext);
  return (
      <header className = "header">
        <div className="LeftSection">          
        <a href="" className="Logos"> 
          <img src={Logo} alt="Logo" />
          <img src={Textlogo} alt="Text logo" />
        </a>
          <div className="headerContent">
            <a>Abouts us</a>
            <a>Suggest</a>
            <a>Help</a>
          </div>
          </div>
          <div className="LoginSection">
          {user ? (
            <Link to={"/dashboard"}>
              <button>
                <span>Dashboard</span>
              </button>
            </Link>
          ) : (
            <Link to={"/login"}>
              <button>
                <span>Login</span>
              </button>
            </Link>
          )}
          </div>
      </header>
  );
}

export default Header;
