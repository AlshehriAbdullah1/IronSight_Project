// FooterSection.jsx
function FooterSection({ title, children }) {
    return (
      <div className="footer-section">
        <h3>{title}</h3>
        {children}
      </div>
    );
  }
  
  export default FooterSection;