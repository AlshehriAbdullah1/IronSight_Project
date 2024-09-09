import React, { useState } from "react";
import { useEffect } from "react";
import axios from "axios";
import "../../css/components/UserList.css";

function CommunityList() {

  const [searchTerm, setSearchTerm] = useState("");
  const [communities, setCommunities] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [currentCommunity, setCurrentCommunity] = useState(null);
  const [filteredCommunities, setFilteredCommunities] = useState([]);

  useEffect(() => {
    axios
      .get("/communities")
      .then((response) => {
        setCommunities(response.data);
      })
      .catch((error) => {
        console.error(error);
      });
  }, []);

  useEffect(() => {
    filterCommunities(searchTerm);
  }, [communities]);

  const handleSearchChange = (event) => {
    const { value } = event.target;
    setSearchTerm(value);
    filterCommunities(value);
  };

  const filterCommunities = (term) => {
    setFilteredCommunities(
      term
        ? communities.filter((community) =>
            community.Community_Name.toLowerCase().includes(term.toLowerCase())
          )
        : communities
    );
  };

  const handleActionClick = (community) => {
    setShowModal(true);
    setCurrentCommunity(community);
  };

  const closeModal = () => {
    setShowModal(false);
  };

  const handleVerify = async (communityId, isVerified) => {
    try {
      await axios.put(`/communities/${communityId}`, { isVerified: !isVerified });
      setCommunities(
        communities.map((community) =>
          community.Community_Id === communityId
            ? { ...community, isVerified: !isVerified }
            : community
        )
      );
      return true;
    } catch (error) {
      console.error(error);
      return false;
    }
  };

  return (
    <div className="user-list-container mb-4">
      <input
        type="text"
        placeholder="Search Communities"
        value={searchTerm}
        onChange={handleSearchChange}
        className="search-bar"
      />
     <div className="user-list">
  {filteredCommunities.map((community) => (
    <div key={community.Community_Id} className="user-item">
      <div className="user-info">
        <span className="username">{community.Community_Name}</span>
      </div>
      <div className="user-id">
        <span>{community.Community_Id}</span>
      </div>
      <button
        className={community.isVerified ? "unverify-button" : "verify-button"}
        onClick={() => handleActionClick(community)}
      >
        {community.isVerified ? "Unverify" : "Verify"}
      </button>
    </div>
  ))}
  {filteredCommunities.length === 0 && <div>No results found.</div>}
</div>
      {showModal && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <button onClick={closeModal} className="close-button">
              X
            </button>
            <h4>Are you sure you want to verify this community?</h4>
            <div className="buttons-row">
            <button
  className={currentCommunity.isVerified ? "unverify-button" : "verify-button"}
  onClick={async () => {
    const res = await handleVerify(currentCommunity.Community_Id, currentCommunity.isVerified);
    if (!res) {
      alert("Failed to verify community.");
    }
    closeModal();
  }}
>
  {currentCommunity.isVerified ? "Unverify" : "Verify"}
</button>
              <button
                className="rejection"
                onClick={() => {
                  console.log("Reject community:", currentCommunity);
                  closeModal();
                }}
              >
                Reject
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}

export default CommunityList;
