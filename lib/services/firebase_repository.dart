import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models.dart';

class FirebaseQuestRepository implements QuestRepository {
  FirebaseQuestRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  @override
  Stream<Learner?> get authState => _auth.authStateChanges().map(
    (user) => user == null ? null : Learner(user.uid, user.email ?? 'Learner'),
  );

  @override
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    if (register) {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } else {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<Quest?> watchQuest() =>
      _db.doc('challenges/today').snapshots().map((doc) {
        final data = doc.data();
        return data == null
            ? null
            : Quest(data['title'] as String, data['prompt'] as String);
      });

  @override
  Stream<Progress> watchProgress(String uid) =>
      _db.doc('users/$uid/progress/today').snapshots().map((doc) {
        final data = doc.data();
        return Progress(
          completed: data?['completed'] == true,
          points: (data?['points'] as num?)?.toInt() ?? 0,
          badgeId: data?['badgeId'] as String?,
        );
      });

  @override
  Future<String> hint(String question) async {
    try {
      final result = await _functions
          .httpsCallable(
            'askQuestCoach',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
          )
          .call<Map<String, dynamic>>({'question': question.trim()})
          .timeout(const Duration(seconds: 20));
      return result.data['reply'] as String;
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Quest Coach failed: ${error.code}');
      rethrow;
    }
  }

  @override
  Future<bool> complete() async {
    final result = await _functions
        .httpsCallable(
          'completeToday',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
        )
        .call<Map<String, dynamic>>({'challengeId': 'today'})
        .timeout(const Duration(seconds: 20));
    return result.data['alreadyCompleted'] == true;
  }
}
