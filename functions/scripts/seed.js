"use strict";
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
if (!process.env.FIRESTORE_EMULATOR_HOST) throw Error("Start the Firestore emulator before seeding.");
initializeApp({ projectId: process.env.GCLOUD_PROJECT || "demo-cloud-quest" });
getFirestore().doc("challenges/today").set({
  title: "Signal Check",
  prompt: "Pause for two minutes. Notice one sound, one color, and one texture around you. Take three slow breaths, then name one small action that would help you focus. When you have tried these steps, complete your quest.",
}).then(() => { console.log("Seeded challenges/today in the emulator."); process.exit(0); })
  .catch((error) => { console.error(error.message); process.exit(1); });
