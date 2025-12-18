const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.pushNotification =
functions.firestore
  .document("notifications/{notifId}")
  .onCreate(async (snap) => {

    const notif = snap.data();
    const userId = notif.userId;

    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) return;

    const token = userDoc.data().fcmToken;
    if (!token) return;

    const payload = {
      notification: {
        title: notif.title,
        body: notif.message,
      },
      token: token,
    };

    await admin.messaging().send(payload);
  });