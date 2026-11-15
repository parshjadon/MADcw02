"use strict";

function assertLocalOnly(env = process.env) {
  const localHost = /^(127\.0\.0\.1|localhost|0\.0\.0\.0):\d+$/;
  const project = require("../config/firebase-spark.json").projectId;
  // The CLI's source-discovery child does not forward arbitrary shell variables.
  // Its registered project identity is also an explicit Spark-mode selector.
  if (env.QUEST_FIREBASE_MODE === "spark" || env.GCLOUD_PROJECT === project) {
    if (env.FUNCTIONS_EMULATOR !== "true" || env.GCLOUD_PROJECT !== project
        || env.FIRESTORE_EMULATOR_HOST || env.FIREBASE_AUTH_EMULATOR_HOST) {
      throw Error("Cloud Quest Spark mode requires a local Functions emulator and registered live Auth/Firestore.");
    }
    return "spark";
  }
  if (env.FUNCTIONS_EMULATOR !== "true" || env.GCLOUD_PROJECT !== "demo-cloud-quest"
      || !localHost.test(env.FIRESTORE_EMULATOR_HOST || "")
      || !localHost.test(env.FIREBASE_AUTH_EMULATOR_HOST || "")) {
    throw Error("Cloud Quest is free/local-only. Start the demo-cloud-quest Auth, Firestore and Functions emulators.");
  }
  return "emulator";
}

module.exports = { assertLocalOnly };
