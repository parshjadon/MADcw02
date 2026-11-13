# Recorded verification evidence

All results below are from executed checks on November 13, 2026, against `demo-cloud-quest`. The evidence uses disposable synthetic learner identities. No authentication tokens, passwords, service-account files, or live model credentials are included.

## Environment

- Windows 11, Flutter 3.47.2, Dart 3.13.2, Node.js 24.22.1, Firebase CLI 15.34.2.
- Android API 35 x86_64, 720 × 1280 physical pixels, density 320 (360 × 640 logical).
- Auth emulator port 9099, Firestore 8080, Functions 5001.
- FlutterFire Core 5.1.0, Auth 7.0.1, Firestore 7.1.0, Functions 7.0.1.
- Genkit 1.44.0; the emulator model is a deterministic fixture, not a live LLM.
- Android automation supplies text through Flutter's test input channel so native IME events cannot overwrite simulated edits. Firebase Auth, Firestore, Functions, and rendering still execute on the actual Android emulator.

## Commands and results

The reproducible combined command is:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify.ps1 -UseRunningEmulators -DeviceId emulator-5554
```

| Check | Observed result | Saved output |
| --- | --- | --- |
| `flutter analyze` | No issues found | [analyzer](flutter-analyze.txt) |
| `flutter test --reporter expanded` | 3 widget tests passed | [widget tests](widget-tests.txt) |
| `node functions/scripts/run-tests.js` with emulator hosts | 11 backend tests passed, 0 failures | [TAP output](backend-tests.txt) |
| `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/quest_flow_test.dart -d emulator-5554` | Full native Android journey passed | [mobile log](mobile-run.txt) |

The additional free-only guard test rejects cloud execution, real project IDs, missing emulator hosts and remote hosts. The hosted model adapter is absent; the app cannot select production Firebase options.

## Assignment matrix

| Required scenario | Observation | Evidence |
| --- | --- | --- |
| Android app launch | Native app builds, installs and launches on API 35 | [mobile log](mobile-run.txt), [signed-out screen](screenshots/01-signed-out.png) |
| Signed out | Only sign-in/registration is available; completion and coach controls are absent | [initial screen](screenshots/01-signed-out.png), widget test |
| Registration and sign-in | A new synthetic account is created; later sign-in restores its existing 10 points | [mobile observations](mobile-observations.json), mobile log |
| Read challenge | Authenticated learner sees Signal Check, its Firestore prompt, and initial 0 points | [challenge screen](screenshots/02-challenge.png) |
| Grounded hint | Hint names Signal Check and the caller's 0 points; progress is not created | [normal hint](screenshots/03-grounded-hint.png), mobile/backend observations |
| Coach UID scope | Submitting learner B's UID while authenticated as A still reads A's 0 points; B's private badge and 777-point fixture are not returned | [backend observations](backend-observations.json), TAP test 5 |
| Adversarial Signal Check | Coach refuses other-user disclosure and extra points; caller progress is null before and after; other-user record is unchanged | [adversarial screen](screenshots/04-signal-check.png), mobile/backend observations |
| Tool/model failure | Both simulated backend failures return UNAVAILABLE without a hint or write; the app displays a safe retry message for a model failure | [fallback screen](screenshots/05-service-fallback.png), TAP test 7 |
| Complete once | Server writes `completed: true`, 10 points, `first-quest`, and a server timestamp | [reward screen](screenshots/06-first-reward.png), mobile observations |
| Repeat completion | Same points, badge and timestamp are preserved; UI says already completed | [retry screen](screenshots/07-idempotent-retry.png), mobile observations |
| Concurrent completion | Eight simultaneous requests yield one first award and seven already-completed results, with 10 stored points | TAP test 9, backend observations |
| Direct reward write / private read | Client reward and challenge PATCH requests return 403; A's request for B's progress returns 403 | TAP test 3, backend observations |
| Authentication boundary | Missing and malformed ID tokens are denied by both callables | TAP test 2 |
| Sign out / reauthentication | Private progress and coach UI disappear; prior hint is absent after reauthentication; stored reward remains | [signed out again](screenshots/08-signed-out-again.png), mobile observations |
| Small-screen layout | All controls remain reachable at 320 × 640 with enlarged text; no overflow exception | widget test 3; native screenshots at 360 × 640 |

## Progress and tool records

[mobile-observations.json](mobile-observations.json) identifies the actual synthetic UID, progress document path, grounded/adversarial replies, and identical first/retry reward timestamps. [backend-observations.json](backend-observations.json) records two learner roles, service ports, client-UID spoofing, denied operations, concurrency and failure results.

The tool reads `challenges/today` and `users/{verifiedAuthUid}/progress/today`; the implementation has no client-supplied tool UID/path or write capability. The first tool result is enforced before final answer generation. A failed read cannot yield a grounded answer.

## Log review and limits

The successful AOSP emulator run logs Google Play services/provider warnings because the image has no Google Play Store. The Firebase requests still succeed against local emulators. The simulated model failure intentionally logs `unavailable`. Firestore listeners may log PERMISSION_DENIED as sign-out revokes their authorization; the private screen is then disposed. There are no uncaught Flutter exceptions in the successful journey. Gradle also emits dependency migration/native-access warnings; the build succeeds.

The eight screenshot files were visually inspected. They are native Flutter screenshots of the actual test run, with the list scrolled to each relevant section.

No course Firebase deployment, supplied-starter integration, iOS run, or live-model adversarial check was possible without the missing course resources. The fixture's refusal is not a claim of general LLM prompt-injection resistance. See [submission handoff](../SUBMISSION.md) for the remaining instructor-provided prerequisite.
