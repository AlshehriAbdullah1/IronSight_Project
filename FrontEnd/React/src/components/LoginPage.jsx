import { useState, useContext, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { UserContext } from '../UserContext';
import webBackground from '../assets/WebBackground.png';
import '../css/pages/loginPage.css';
import textLogo from '../assets/TextLogo.png';
import { auth, signOut } from '../DB/firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import axios from 'axios';

function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { user } = useContext(UserContext);

  useEffect(() => {
    const signOutIfNotAdmin = async () => {
      if (user && user.Role === "Admin") {
        navigate("/dashboard");
      } else if (user) {
        setError("You are not authorized to access the dashboard");
        await signOut(auth);
      }
    };
    signOutIfNotAdmin();
  }, [user, navigate]);

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      setError("");
      setLoading(true);
      await signInWithEmailAndPassword(auth, email, password);
      setLoading(false);
    } catch (error) {
      setLoading(false);
      setError("Failed to log in");
    }
  }



  return (
    <div className="login-page">
      <div className="login-page-wrapper">
        <div className="black-rectangle">
          <img src={textLogo} alt="Logo" className="rectangle-image" />
        </div>
        <div className="login-container">
          <h1 className="login-title">Log In</h1>
          <p className="login-subtitle">Log In to manage your items</p>
          {loading && <p className="loading-message">Loading...</p>}
          {error && <p className="error-message">{error}</p>}
          <form className="login-form" onSubmit={handleSubmit}>
            <input type="hidden" name="remember" value="true" />
            <div className="input-container">
              <div className="email-input">
                <label htmlFor="email-address" className="sr-only">
                  Email address
                </label>
                <p className="input-label">Enter Your Email</p>
                <input
                  id="email-address"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  className="input-field"
                  placeholder="Email address"
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>
              <div className="password-input">
                <label htmlFor="password" className="sr-only">
                  Password
                </label>
                <p className="input-label">Enter Your Password</p>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  className="input-field"
                  placeholder="Password"
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
            </div>

            <div className="button-container">
              <button type="submit" className="login-button">
                Login
              </button>
              <button type="button" onClick={() => navigate('/landing')} className="back-button">
                Back
              </button>
              <p className="social-login-text">Or log in through</p>
              <button type="button" className="social-login-button">
              </button>
            </div>
            <div className="app-store-buttons">
              <p className="app-store-text">Don't have an account? Create one using our app!</p>
              <button type="button" className="google-play-button">
                Google Play Store
              </button>
              <button type="button" className="apple-app-store-button">
                Apple App Store
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;