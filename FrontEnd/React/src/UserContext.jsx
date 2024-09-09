import { createContext, useState, useEffect } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import axios from 'axios';
import { auth } from './DB/firebase';
import { useNavigate, useLocation } from 'react-router-dom';

export const UserContext = createContext();

export function UserContextProvider({ children }) {
  const [user, setUser] = useState(null);
  const [ready, setReady] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const acceptedPathsForUnauthenticatedUsers = ['/login', '/landing']; // Add other paths as needed

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        const response = await axios.get(`/admins/${user.uid}`);
        setUser(response.data);
        setReady(true);
      } else {
        setUser(null);
        setReady(false);
        if (!acceptedPathsForUnauthenticatedUsers.includes(location.pathname)) {
          navigate('/login'); // navigate to login page when user is not authenticated and the current path is not accepted
        }
      }
    });

    return () => unsubscribe();
  }, [navigate, location]);

  return (
    <UserContext.Provider value={{ user, setUser, ready, setReady }}>
      {children}
    </UserContext.Provider>
  );
}