# Submission handoff

Repository: https://github.com/parshjadon/MADcw02

Prepared: November 13, 2026. This is a verified **local emulator implementation** of Cloud Quest: Signal Check.

## Included

- Native Android Flutter source and pinned FlutterFire dependency lockfile.
- Email/password sign-up, sign-in and sign-out with a private challenge screen.
- Firestore challenge and learner-progress model, protected by deny-write rules.
- A supervised Genkit Quest Coach with the single read-only `readMyQuestState` tool.
- An authenticated transactional completion callable: exactly 10 points and the First Quest badge, once.
- Automated backend boundary/retry tests, widget tests, and an Android integration journey.
- Eight genuine Android screenshots and recorded before/after progress evidence.
- Setup/run instructions and a 129-word reflection.
- Explicit disclosure of Codex assistance and the emulator model limitation.

See [README.md](README.md), [test evidence](evidence/README.md), and [REFLECTION.md](REFLECTION.md).

The local handoff folder `submission/` contains a source ZIP and an Android debug APK. It is excluded from Git because source and evidence are versioned directly in this repository. The APK connects to local emulators; it is not a hosted Firebase deployment.

## Required course information is still missing

The supplied assignment explicitly asks for its provided Flutter starter and course Firebase/AI gateway. This GitHub repository was empty and neither resource was available. The app therefore uses synthetic emulator Firebase options and an explicitly labeled deterministic model fixture.

Ask the instructor for the starter repository and course Firebase/AI gateway configuration, and confirm whether this independently created starter is acceptable. After the instructor supplies them, integrate the course options/gateway and repeat the live-model checks. The current records do **not** claim those unperformed checks or a production deployment.

Because those course requirements are unresolved, this package cannot honestly be certified as fully compliant with every item in the brief. The local implementation and recorded emulator results are ready for review.
