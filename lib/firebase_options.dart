import 'package:firebase_core/firebase_core.dart';

// Emulator options are deliberately synthetic. They are not a registered course
// Firebase app. This project intentionally supports free local emulators only.
abstract final class QuestConfiguration {
  static const useEmulators = true;
  static const emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );
  static FirebaseOptions get options {
    return const FirebaseOptions(
      apiKey: 'AIzaSy000000000000000000000000000000000',
      appId: '1:1234567890:android:1234567890abcdef',
      messagingSenderId: '1234567890',
      projectId: 'demo-cloud-quest',
    );
  }
}
