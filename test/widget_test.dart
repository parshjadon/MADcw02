import 'dart:async';

import 'package:cloud_quest/app.dart';
import 'package:cloud_quest/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepository implements QuestRepository {
  final sessions = StreamController<Learner?>.broadcast();
  final pendingHint = Completer<String>();
  int completionCalls = 0;
  @override
  Stream<Learner?> get authState => sessions.stream;
  @override
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  }) async {
    sessions.add(Learner('alice', email));
  }

  @override
  Future<void> signOut() async => sessions.add(null);
  @override
  Stream<Quest?> watchQuest() => Stream.value(
    const Quest(
      'Signal Check',
      'Pause for two minutes. Notice a sound, color, and texture.',
    ),
  );
  @override
  Stream<Progress> watchProgress(String uid) => Stream.value(const Progress());
  @override
  Future<String> hint(String question) => pendingHint.future;
  @override
  Future<bool> complete() async {
    completionCalls++;
    return completionCalls > 1;
  }
}

void main() {
  testWidgets('signed-out view gates coach, private progress and completion', (
    tester,
  ) async {
    final repo = FakeRepository();
    addTearDown(repo.sessions.close);
    await tester.pumpWidget(CloudQuestApp(repository: repo));
    repo.sessions.add(null);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('authenticate')), findsOneWidget);
    expect(find.byKey(const Key('complete')), findsNothing);
    expect(find.byKey(const Key('question')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('authenticate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('authenticate')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(repo.completionCalls, 0);
  });

  testWidgets(
    'sign-out clears private state and discards an in-flight coach reply',
    (tester) async {
      final repo = FakeRepository();
      addTearDown(repo.sessions.close);
      await tester.pumpWidget(CloudQuestApp(repository: repo));
      repo.sessions.add(const Learner('alice', 'alice@example.test'));
      await tester.pumpAndSettle();
      final question = find.byKey(const Key('question'));
      await tester.ensureVisible(question);
      await tester.enterText(question, 'How do I start?');
      final hint = find.byKey(const Key('get-hint'));
      await tester.ensureVisible(hint);
      await tester.tap(hint);
      await tester.pump();
      await tester.tap(find.byKey(const Key('sign-out')));
      await tester.pumpAndSettle();
      repo.pendingHint.complete('Private reply for Alice');
      await tester.pumpAndSettle();
      expect(find.text('Private reply for Alice'), findsNothing);
      expect(find.text('alice@example.test'), findsNothing);
      expect(find.byKey(const Key('authenticate')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'small phone with enlarged text can reach challenge and coach without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeRepository();
      addTearDown(repo.sessions.close);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: CloudQuestApp(repository: repo),
        ),
      );
      repo.sessions.add(const Learner('alice', 'alice@example.test'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('complete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('complete')));
      await tester.pumpAndSettle();
      expect(repo.completionCalls, 1);
      await tester.ensureVisible(find.byKey(const Key('question')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
