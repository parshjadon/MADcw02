"use strict";

const firebaseMode = require("./localOnly").assertLocalOnly();
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
initializeApp();
const db = getFirestore();
const { createQuestCoach } = require("./questCoach");
const coach = createQuestCoach(db);

async function verifiedUid(request) {
  const uid = request.auth?.uid;
  if (typeof uid !== "string" || !uid || uid.length > 128 || uid.includes("/")) {
    throw new HttpsError("unauthenticated", "Sign in to continue.");
  }
  if (firebaseMode === "spark") {
    const token = request.rawRequest.get("authorization")?.match(/^Bearer (\S+)$/)?.[1];
    try {
      if (!token) throw Error("No token");
      const verified = await getAuth().verifyIdToken(token);
      if (verified.uid !== uid) throw Error("Identity mismatch");
    } catch (_) {
      throw new HttpsError("unauthenticated", "Sign in to continue.");
    }
  }
  return uid;
}

exports.completeToday = onCall({ region: "us-central1", maxInstances: 5 }, async (request) => {
  const uid = await verifiedUid(request);
  if (request.data?.challengeId !== "today") {
    throw new HttpsError("invalid-argument", "Only today's challenge can be completed.");
  }
  // No UID, points or badge supplied by the caller is ever used.
  const progressRef = db.doc(`users/${uid}/progress/today`);
  return db.runTransaction(async (transaction) => {
    const challenge = await transaction.get(db.doc("challenges/today"));
    if (!challenge.exists) throw new HttpsError("failed-precondition", "Today's challenge is unavailable.");
    const previous = await transaction.get(progressRef);
    if (previous.exists && previous.data().completed === true) {
      return { completed: true, points: previous.data().points,
        badgeId: previous.data().badgeId, alreadyCompleted: true };
    }
    transaction.set(progressRef, {
      completed: true, points: 10, badgeId: "first-quest",
      completedAt: FieldValue.serverTimestamp(),
    });
    return { completed: true, points: 10, badgeId: "first-quest", alreadyCompleted: false };
  });
});

exports.askQuestCoach = onCall({ region: "us-central1", maxInstances: 5, timeoutSeconds: 30 }, async (request) => {
  const uid = await verifiedUid(request);
  const question = request.data?.question;
  if (typeof question !== "string" || !question.trim() || question.trim().length > 300) {
    throw new HttpsError("invalid-argument", "Ask a question between 1 and 300 characters.");
  }
  try {
    return await coach({ question: question.trim() }, { context: { uid } });
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    console.warn("Quest Coach unavailable", { code: error.code || "service-error" });
    throw new HttpsError("unavailable", "The coach is unavailable. Try again; your progress is safe.");
  }
});
