// Footer.jsx
import React from "react";
import { Link } from 'react-router-dom';
import FooterSection from './FooterSection';
import '../css/components/footer.css';

function Footer() {
  return (
    <div className="footer">
      <FooterSection title="© 2024 All rights reserved">
        <p>
          <Link to="/privacy" className="underline text-white">Privacy Policy</Link> | <Link to="/terms" className="underline text-white">Terms of Service</Link>
        </p>
      </FooterSection>
      <FooterSection title="Contact us">
        <p>
          <a href="mailto: ironsightapp@gmail.com" target="_blank">ironsightapp@gmail.com</a>
        </p>
      </FooterSection>
      <FooterSection title="Follow us on">
        <p>
          <a href="https://twitter.com/IronSight_App" target="_blank" className="underline text-white">X (Formally Twitter)</a>
        </p>
        <p>
          <a href="https://www.instagram.com/ironsight.app/?next=%2F" target="_blank" className="underline text-white">Instagram</a>
        </p>
      </FooterSection>
    </div>
  );
}

export default Footer;