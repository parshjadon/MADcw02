# Submission handoff

Repository: https://github.com/parshjadon/MADcw02

Updated: November 14, 2026. This is a verified **free, local-only emulator implementation** of Cloud Quest: Signal Check.

The client key reported by GitHub secret scanning has been rotated and revoked. Both alerts are resolved; current source and source ZIP exclude live key values. Spark builds use ignored local configuration.

## Included

- Native Android Flutter source and pinned FlutterFire dependency lockfile.
- Email/password sign-up, sign-in and sign-out with a private challenge screen.
- Firestore challenge and learner-progress model, protected by deny-write rules.
- A supervised Genkit Quest Coach with the single read-only `readMyQuestState` tool.
- An authenticated transactional completion callable: exactly 10 points and the First Quest badge, once.
- Automated backend boundary/retry tests, widget tests, and an Android integration journey.
- Eight genuine Android screenshots for each mode, plus recorded live Firebase and emulator progress evidence.
- Setup/run instructions and a 134-word reflection.
- Explicit disclosure of Codex assistance and the emulator model limitation.

See [README.md](README.md), [test evidence](evidence/README.md), and [REFLECTION.md](REFLECTION.md).

The local handoff folder `submission/` contains a source ZIP and an Android debug APK. It is excluded from Git because source and evidence are versioned directly in this repository. CloudQuest-Spark-debug.apk connects to live Firebase Auth/Firestore and the local Functions backend; CloudQuest-debug.apk uses only demo emulators. Neither build calls deployed Cloud Functions.

## Required course information is still missing

The supplied assignment explicitly asks for its provided Flutter starter and course Firebase/AI gateway. This GitHub repository was empty and neither resource was available. The default app uses synthetic emulator Firebase options and an explicitly labeled deterministic model fixture. The registered Spark project test13-a8b02 is connected and tested: live Authentication/Firestore, published access rules and seeded challenge, with Functions and the deterministic coach running locally. Billing remains disabled.

Ask the instructor for the starter repository and course Firebase/AI gateway configuration, and confirm whether this independently created starter is acceptable. This course-compliance question does not require purchasing a Firebase plan or a model subscription. The selected implementation deliberately supports only free local testing. The current records do **not** claim those unperformed checks or a production deployment.

Because those course requirements are unresolved, this package cannot honestly be certified as fully compliant with every item in the brief. The local implementation and recorded emulator results are ready for review.
