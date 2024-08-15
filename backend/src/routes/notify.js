const { Firestore } = require("firebase-admin/firestore");

/**
 *
 * @param {import("express").Request} request
 * @param {import("express").Response} response
 * @param {Firestore} db
 */
async function notify(request, response, db) {
  const user_id = request.body.user_id;
  const usersCollection = db.collection("users");

  const userIdQuery = usersCollection.where("user_id", "==", user_id);
  const snapshot = await userIdQuery.get();

  if (snapshot.docs.length === 0) {
    usersCollection
      .add({ user_id: user_id })
      .then(() => {
        response.sendStatus(200);
      })
      .catch(() => {
        response.sendStatus(500);
      });
  } else {
    response.sendStatus(200);
  }
}

module.exports = notify;
