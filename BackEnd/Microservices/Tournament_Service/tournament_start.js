const { db,firebase } = require('./firebase.js');
// The es6-promise-pool to limit the concurrency of promises.
const PromisePool = require("es6-promise-pool").default;
// Maximum concurrent account deletions.
const MAX_CONCURRENT = 3;
// Run once a day at midnight, to clean up the users
// Manually run the task here https://console.cloud.google.com/cloudscheduler
exports.accountcleanup = onSchedule("every day 00:00", async (event) => {
    // Fetch all user details.
    const inactiveUsers = await getInactiveUsers();
  
    // Use a pool so that we delete maximum `MAX_CONCURRENT` users in parallel.
    const promisePool = new PromisePool(
        () => deleteInactiveUser(inactiveUsers),
        MAX_CONCURRENT,
    );
    await promisePool.start();
  
    logger.log("User cleanup finished");
  });
const matches = {
    'Active': [{      
        "Player1":{
            "ID":"ID1",
            'Name':'Player1',
            "Status":"Loser"}
        ,"Player2":{
            "ID":"ID2",
            'Name':'Player2',
            "Status":"Winner"}
    }
],
    'Ended': []
}
for (let index = 0; index <max_particpants-1; index++) {
    matches['Active'].push({
    "Player1":{"ID":"ID1",
        'Name':'Player1',
        "Status":"Loser"}
    ,"Player2":{
        "ID":"ID2",
        'Name':'Player2',
    "Status":"Winner"}
});
}