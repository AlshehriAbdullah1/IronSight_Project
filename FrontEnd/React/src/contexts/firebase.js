import firebase from 'firebase/app';
import 'firebase/auth';

const firebaseConfig = {
    apiKey: "AIzaSyDlcHfdCpAqYZlU01rztYIIXbTt1RdM_mc",
    authDomain: "ironsight-426001.firebaseapp.com",
    projectId: "ironsight-426001",
    storageBucket: "ironsight-426001.appspot.com",
    messagingSenderId: "698940550647",
    appId: "1:698940550647:web:8a4d4c6913a1de1aed12f2",
    measurementId: "G-5E7MW5HNH8"
  };

if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
}

export default firebase;