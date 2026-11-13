class Learner {
  const Learner(this.uid, this.email);
  final String uid;
  final String email;
}

class Quest {
  const Quest(this.title, this.prompt);
  final String title;
  final String prompt;
}

class Progress {
  const Progress({this.completed = false, this.points = 0, this.badgeId});
  final bool completed;
  final int points;
  final String? badgeId;
}

abstract class QuestRepository {
  Stream<Learner?> get authState;
  Future<void> authenticate(
    String email,
    String password, {
    required bool register,
  });
  Future<void> signOut();
  Stream<Quest?> watchQuest();
  Stream<Progress> watchProgress(String uid);
  Future<String> hint(String question);
  Future<bool> complete();
}
