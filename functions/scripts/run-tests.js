"use strict";
const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");
const evidence = path.resolve(__dirname, "../../evidence");
fs.mkdirSync(evidence, { recursive: true });
const result = spawnSync(process.execPath, ["--test", "--test-reporter=tap", "test/boundaries.test.js"], {
  cwd: path.resolve(__dirname, ".."), encoding: "utf8", env: process.env,
});
const output = (result.stdout || "") + (result.stderr || "");
fs.writeFileSync(path.join(evidence, "backend-tests.txt"), output);
process.stdout.write(output);
process.exit(result.status ?? 1);
