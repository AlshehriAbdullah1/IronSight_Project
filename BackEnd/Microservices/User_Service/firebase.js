const { initializeApp, cert } = require('firebase-admin/app')
const { getFirestore } = require('firebase-admin/firestore')
const serviceAccount = require('./creds.json')

initializeApp({
    credential: cert(serviceAccount)
})

const db = getFirestore()
// To get the firestore object in other files, use the following code:
const firebase = require('firebase-admin')
module.exports = { db,firebase }