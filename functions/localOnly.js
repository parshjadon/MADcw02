"use strict";

function assertLocalOnly(env = process.env) {
  const localHost = /^(127\.0\.0\.1|localhost|0\.0\.0\.0):\d+$/;
  if (env.FUNCTIONS_EMULATOR !== "true" || env.GCLOUD_PROJECT !== "demo-cloud-quest"
      || !localHost.test(env.FIRESTORE_EMULATOR_HOST || "")
      || !localHost.test(env.FIREBASE_AUTH_EMULATOR_HOST || "")) {
    throw Error("Cloud Quest is free/local-only. Start the demo-cloud-quest Auth, Firestore and Functions emulators.");
  }
}

module.exports = { assertLocalOnly };
