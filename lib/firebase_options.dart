import 'package:firebase_core/firebase_core.dart';

import 'firebase_options_spark.dart';

// Emulator options are deliberately synthetic. They are not a registered course
// Firebase app. Spark mode uses registered Auth/Firestore with local Functions.
abstract final class QuestConfiguration {
  static const useSpark = bool.fromEnvironment(
    'USE_SPARK',
    defaultValue: false,
  );
  static const useEmulators = !useSpark;
  static const functionsPort = useSpark ? 5002 : 5001;
  static const emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );
  static FirebaseOptions get options {
    if (useSpark) {
      if (sparkFirebaseOptions.apiKey.isEmpty) {
        throw StateError(
          'Use scripts/run-spark.ps1 or supply the ignored Firebase key file.',
        );
      }
      return sparkFirebaseOptions;
    }
    return const FirebaseOptions(
      // Firebase SDK's documented nonfunctional demo-project identifier.
      apiKey: 'ADemoProjectApiKey000000000000000000000',
      appId: '1:1234567890:android:1234567890abcdef',
      messagingSenderId: '1234567890',
      projectId: 'demo-cloud-quest',
    );
  }
}
