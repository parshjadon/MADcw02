"use strict";
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const project = require("../config/firebase-spark.json");
const source = JSON.parse(fs.readFileSync(path.join(root, "android/app/google-services.json"), "utf8"));
if (source.project_info.project_id !== project.projectId) throw Error("Firebase project mismatch.");
const client = source.client.find((item) => item.client_info.android_client_info.package_name === "edu.gsu.parsh.cloud_quest");
if (!client?.api_key?.[0]?.current_key) throw Error("Registered Android client configuration is missing.");
fs.writeFileSync(path.join(root, "config/firebase-spark.local.json"), JSON.stringify({
  FIREBASE_API_KEY: client.api_key[0].current_key,
}, null, 2) + "\n");
console.log("Imported Firebase client key into ignored local configuration; no key value printed.");
