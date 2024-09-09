const { db, firebase } = require("./firebase.js");
const adminFunctions = require("./adminFunctions.js");

const adminCollection = "Admins";
var adminRef = db.collection(adminCollection);

// function to get admin info by Admin_Id
async function get_admin(Admin_Id) {
  try {
    const admin = await adminRef.doc(Admin_Id).get();
    if (!admin.exists) {
      return "Admin does not exist";
    }
    return { Admin_Id: admin.id, ...admin.data() };
  } catch (err) {
    return err;
  }
}

module.exports = {
  get_admin,
};
