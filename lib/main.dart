import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: QuestConfiguration.options);
    if (QuestConfiguration.useEmulators) {
      final host = QuestConfiguration.emulatorHost;
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    }
    runApp(
      CloudQuestApp(
        repository: FirebaseQuestRepository(),
        emulatorMode: QuestConfiguration.useEmulators,
      ),
    );
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Cloud Quest could not start. Check your Firebase configuration and emulator connection, then restart the app.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
