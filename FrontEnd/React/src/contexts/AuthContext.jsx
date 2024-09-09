import { createContext, useState, useEffect } from 'react';
import firebase from './firebase';

export const AuthContext = createContext();

export function useAuth() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    return firebase.auth().onAuthStateChanged(user => {
      setUser(user);
    });
  }, []);

  // Create a login function
  async function login(email, password) {
    const userCredential = await firebase.auth().signInWithEmailAndPassword(email, password);
    console.log(userCredential.user);
    setUser(userCredential.user);
  }

  // Return the user and login function
  return { user, login };
}