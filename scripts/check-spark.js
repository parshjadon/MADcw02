"use strict";
require("./spark-project").connectSpark().then(async ({ status, db }) => {
  console.log(JSON.stringify(status, null, 2));
  await db.terminate();
}).catch((error) => { console.error(error.message); process.exitCode = 1; });
