"use strict";
const { spawnSync } = require("node:child_process");
const staged = process.argv.includes("--staged");
const patterns = [
  ["Google API key", "AIza[0-9A-Za-z_-]{35}"],
  ["private key", "-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----"],
  ["OAuth refresh token", '"refresh_token"[[:space:]]*:[[:space:]]*"[^"]+"'],
  ["encoded Firebase key setting", Buffer.from("FIREBASE_API_KEY=").toString("base64").slice(0, -3)],
];
let detected = false;
for (const [kind, pattern] of patterns) {
  const result = spawnSync("git", ["grep", ...(staged ? ["--cached"] : []),
    "--name-only", "-I", "-E", "-e", pattern, "--", "."], { encoding: "utf8", windowsHide: true });
  if (result.status === 0) {
    detected = true;
    console.error(`${kind} detected in ${staged ? "staged" : "tracked"} files:\n${result.stdout.trim()}`);
  } else if (result.status !== 1) {
    console.error("Could not run the tracked-file credential scan.");
    process.exit(2);
  }
}
if (detected) {
  console.error("Commit blocked. Put key-bearing configuration in the ignored local files.");
  process.exit(1);
}
console.log(`No credential patterns in ${staged ? "staged" : "tracked"} text files.`);
