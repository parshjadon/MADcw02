"use strict";
require("./spark-project").connectSpark().then(async ({ db }) => {
  const ref = db.doc("challenges/today");
  const existing = await ref.get();
  if (existing.exists) {
    const data = existing.data();
    if (typeof data.title !== "string" || typeof data.prompt !== "string") throw Error("Existing challenge needs title and prompt string fields.");
    console.log("Kept existing challenges/today.");
  } else {
    await ref.create({ title: "Signal Check",
      prompt: "Pause for two minutes. Notice one sound, one color, and one texture around you. Take three slow breaths, then name one small action that would help you focus. When you have tried these steps, complete your quest." });
    console.log("Seeded challenges/today in the registered Spark project.");
  }
  await db.terminate();
}).catch((error) => { console.error(error.message); process.exitCode = 1; });
