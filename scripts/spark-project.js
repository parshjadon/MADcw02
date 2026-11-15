"use strict";
const fs = require("node:fs");
const path = require("node:path");
const functionRequire = require("node:module").createRequire(path.resolve(__dirname, "../functions/package.json"));
const { GoogleAuth } = functionRequire("google-auth-library");
const { initializeApp, applicationDefault, getApps } = functionRequire("firebase-admin/app");
const { getFirestore } = functionRequire("firebase-admin/firestore");
const root = path.resolve(__dirname, "..");
const localPath = path.join(root, 'config/firebase-spark.local.json');
const local = fs.existsSync(localPath) ? JSON.parse(fs.readFileSync(localPath, 'utf8')) : {};
const config = { ...require("../config/firebase-spark.json"),
  apiKey: process.env.FIREBASE_API_KEY || local.FIREBASE_API_KEY };

async function connectSpark() {
  if (!config.apiKey) throw Error('Import your Firebase client key with node scripts/import-firebase-config.js.');
  if (process.env.FIRESTORE_EMULATOR_HOST || process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    throw Error("Clear emulator host variables before using Spark mode.");
  }
  let credentialPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credentialPath) {
    const cliRoot = process.env.FIREBASE_CLI_ROOT || path.join(process.env.APPDATA, "npm/node_modules/firebase-tools");
    const account = require(path.join(cliRoot, "lib/auth")).getProjectDefaultAccount(root);
    if (!account) throw Error("Run firebase.cmd login first.");
    credentialPath = await require(path.join(cliRoot, "lib/defaultCredentials")).getCredentialPathAsync(account);
  }
  if (!credentialPath) throw Error("No local Firebase login credential is available.");
  process.env.GOOGLE_APPLICATION_CREDENTIALS = credentialPath;
  const client = await new GoogleAuth({ keyFilename: credentialPath,
    scopes: ["https://www.googleapis.com/auth/cloud-platform"] }).getClient();
  const billing = (await client.request({
    url: `https://cloudbilling.googleapis.com/v1/projects/${config.projectId}/billingInfo`, timeout: 15000,
  })).data;
  if (billing.billingEnabled !== false || billing.billingAccountName) {
    throw Error("Spark testing requires billing disabled and no linked billing account.");
  }
  const [authentication, database] = await Promise.all([
    client.request({ url: `https://identitytoolkit.googleapis.com/admin/v2/projects/${config.projectId}/config`, timeout: 15000 }),
    client.request({ url: `https://firestore.googleapis.com/v1/projects/${config.projectId}/databases/(default)`, timeout: 15000 }),
  ]);
  if (!authentication.data.signIn?.email?.enabled) throw Error("Enable Email/Password Authentication in Firebase Console.");
  const status = { recordedAt: new Date().toISOString(), projectId: config.projectId,
    billingEnabled: false, billingAccountLinked: false, emailPasswordEnabled: true,
    firestoreLocation: database.data.locationId, backend: "local Functions emulator on port 5002",
    coach: "deterministic local Genkit fixture" };
  fs.mkdirSync(path.join(root, "evidence"), { recursive: true });
  fs.writeFileSync(path.join(root, "evidence/spark-project-status.json"), JSON.stringify(status, null, 2));
  const app = getApps().length ? getApps()[0] : initializeApp({ projectId: config.projectId, credential: applicationDefault() });
  return { config, client, db: getFirestore(app), status };
}
module.exports = { connectSpark };
