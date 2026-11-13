import 'package:firebase_core/firebase_core.dart';

// Emulator options are deliberately synthetic. They are not a registered course
// Firebase app. Real course options must be supplied before a production run.
abstract final class QuestConfiguration {
  static const useEmulators = bool.fromEnvironment(
    'USE_EMULATORS',
    defaultValue: true,
  );
  static const emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );
  static FirebaseOptions get options {
    if (useEmulators) {
      return const FirebaseOptions(
        apiKey: 'AIzaSy000000000000000000000000000000000',
        appId: '1:1234567890:android:1234567890abcdef',
        messagingSenderId: '1234567890',
        projectId: 'demo-cloud-quest',
      );
    }
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
    if ([apiKey, appId, projectId, senderId].any((value) => value.isEmpty)) {
      throw StateError(
        'Course Firebase configuration is missing. Use the emulator run steps.',
      );
    }
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      projectId: projectId,
      messagingSenderId: senderId,
    );
  }
}
