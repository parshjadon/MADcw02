import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class CloudQuestApp extends StatelessWidget {
  const CloudQuestApp({
    super.key,
    required this.repository,
    this.emulatorMode = true,
  });
  final QuestRepository repository;
  final bool emulatorMode;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cloud Quest',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F5FA),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5543A8)),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 16),
      ),
    ),
    home: _AuthGate(repository: repository, emulatorMode: emulatorMode),
  );
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.repository, required this.emulatorMode});
  final QuestRepository repository;
  final bool emulatorMode;
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final _auth = widget.repository.authState;
  @override
  Widget build(BuildContext context) => StreamBuilder<Learner?>(
    stream: _auth,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Scaffold(
          body: Center(
            child: Text('Sign-in service unavailable. Restart to reconnect.'),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      return user == null
          ? _SignIn(
              repository: widget.repository,
              emulatorMode: widget.emulatorMode,
            )
          : _QuestScreen(
              key: ValueKey(user.uid),
              repository: widget.repository,
              user: user,
              emulatorMode: widget.emulatorMode,
            );
    },
  );
}

class _SignIn extends StatefulWidget {
  const _SignIn({required this.repository, required this.emulatorMode});
  final QuestRepository repository;
  final bool emulatorMode;
  @override
  State<_SignIn> createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false, _busy = false;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.authenticate(
        _email.text,
        _password.text,
        register: _register,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _error = switch (error.code) {
            'email-already-in-use' =>
              'An account already uses this email. Try signing in.',
            'weak-password' => 'Choose a password with at least 6 characters.',
            'too-many-requests' => 'Too many attempts. Please try again later.',
            'network-request-failed' =>
              'Cannot connect. Check the emulator or network and try again.',
            _ => 'Could not sign in. Check your email and password, then try again.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Sign-in is unavailable. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 52,
                color: Color(0xFF5543A8),
              ),
              const SizedBox(height: 20),
              Text(
                'A little focus.\nA fresh quest.',
                style: Theme.of(context).textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in to explore today’s challenge, get a helpful hint, and earn your first badge.',
              ),
              const SizedBox(height: 24),
              if (widget.emulatorMode)
                const _Notice(
                  icon: Icons.science_outlined,
                  text: 'Local emulator • coach responses use a test model',
                ),
              const SizedBox(height: 16),
              Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('email'),
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value != null &&
                              RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(value.trim())
                          ? null
                          : 'Enter a valid email address.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('password'),
                      controller: _password,
                      enabled: !_busy,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'At least 6 characters',
                      ),
                      validator: (value) => (value?.length ?? 0) >= 6
                          ? null
                          : 'Use at least 6 characters.',
                      onFieldSubmitted: (_) {
                        if (!_busy) _submit();
                      },
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('authenticate'),
                      onPressed: _busy ? null : _submit,
                      child: Text(
                        _busy
                            ? 'Connecting…'
                            : _register
                            ? 'Create account'
                            : 'Sign in',
                      ),
                    ),
                    TextButton(
                      key: const Key('toggle-auth'),
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _register = !_register;
                              _error = null;
                            }),
                      child: Text(
                        _register
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your progress is private. Rewards are granted once by the server.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _QuestScreen extends StatefulWidget {
  const _QuestScreen({
    super.key,
    required this.repository,
    required this.user,
    required this.emulatorMode,
  });
  final QuestRepository repository;
  final Learner user;
  final bool emulatorMode;
  @override
  State<_QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<_QuestScreen> {
  final _question = TextEditingController();
  late Stream<Quest?> _quest = widget.repository.watchQuest();
  late Stream<Progress> _progress = widget.repository.watchProgress(
    widget.user.uid,
  );
  String? _reply, _coachError, _rewardMessage;
  bool _asking = false, _completing = false, _signingOut = false;
  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    if (_question.text.trim().isEmpty) {
      setState(() => _coachError = 'Type a question first.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _asking = true;
      _reply = null;
      _coachError = null;
    });
    try {
      final reply = await widget.repository.hint(_question.text);
      if (mounted) setState(() => _reply = reply);
    } catch (_) {
      if (mounted) {
        setState(
          () => _coachError =
              'The coach is unavailable. Try again; your progress is safe.',
        );
      }
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  Future<void> _complete() async {
    setState(() {
      _completing = true;
      _rewardMessage = null;
    });
    try {
      final already = await widget.repository.complete();
      if (mounted) {
        setState(
          () => _rewardMessage = already
              ? 'Already completed. Your 10 points and badge are safe; no extra reward was added.'
              : 'Quest complete! You earned 10 points and the First Quest badge.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _rewardMessage = 'Could not confirm completion. Try again safely; retries never add extra points.',
        );
      }
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _signingOut = true;
      _reply = null;
      _coachError = null;
      _question.clear();
    });
    try {
      await widget.repository.signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not sign out. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Widget _readError(String message) => Column(
    children: [
      Text(message),
      TextButton(
        onPressed: () => setState(() {
          _quest = widget.repository.watchQuest();
          _progress = widget.repository.watchProgress(widget.user.uid);
        }),
        child: const Text('Reconnect'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cloud Quest'),
      backgroundColor: Colors.transparent,
      actions: [
        TextButton(
          key: const Key('sign-out'),
          onPressed: _signingOut ? null : _signOut,
          child: const Text('Sign out'),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const Key('quest-list'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                widget.user.email,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (widget.emulatorMode)
                const _Notice(
                  icon: Icons.science_outlined,
                  text: 'Local emulator • test model',
                ),
              const SizedBox(height: 20),
              Text(
                'Make room for a\nmoment of focus.',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              StreamBuilder<Quest?>(
                stream: _quest,
                builder: (context, quest) {
                  if (quest.hasError) {
                    return _readError(
                      'Could not load the challenge. Check your connection.',
                    );
                  }
                  if (quest.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (quest.data == null) {
                    return _readError(
                      'Today’s challenge is not available yet.',
                    );
                  }
                  return StreamBuilder<Progress>(
                    stream: _progress,
                    builder: (context, progress) {
                      if (progress.hasError) {
                        return _readError(
                          'Could not load your progress. Please reconnect.',
                        );
                      }
                      if (!progress.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final state = progress.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TODAY’S CHALLENGE',
                                    style: TextStyle(
                                      letterSpacing: 1.4,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    quest.data!.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    quest.data!.prompt,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        avatar: const Icon(
                                          Icons.bolt_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          '${state.points} points',
                                          key: const Key('points'),
                                        ),
                                      ),
                                      Chip(
                                        avatar: Icon(
                                          state.completed
                                              ? Icons.verified_rounded
                                              : Icons.lock_outline,
                                          size: 18,
                                        ),
                                        label: Text(
                                          state.badgeId == 'first-quest'
                                              ? 'First Quest'
                                              : 'Badge waiting',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      key: const Key('complete'),
                                      onPressed: _completing || _signingOut
                                          ? null
                                          : _complete,
                                      child: Text(
                                        _completing
                                            ? 'Confirming…'
                                            : state.completed
                                            ? 'Check completion again'
                                            : 'Complete challenge',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Only tap after you’ve tried the steps. One quest, one reward.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  if (_rewardMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        _rewardMessage!,
                                        key: const Key('reward-result'),
                                        semanticsLabel: _rewardMessage,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_outlined,
                                        color: Color(0xFF5543A8),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Quest Coach',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'A hint from your quest state. You decide what happens next.',
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    key: const Key('question'),
                                    controller: _question,
                                    onChanged: (_) => setState(() {
                                      _reply = null;
                                      _coachError = null;
                                    }),
                                    maxLength: 300,
                                    minLines: 2,
                                    maxLines: 4,
                                    enabled: !_asking && !_signingOut,
                                    decoration: const InputDecoration(
                                      labelText: 'Ask for a hint',
                                      hintText: 'How should I get started?',
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    key: const Key('get-hint'),
                                    onPressed: _asking || _signingOut
                                        ? null
                                        : _ask,
                                    icon: const Icon(
                                      Icons.auto_awesome,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _asking ? 'Thinking…' : 'Get hint',
                                    ),
                                  ),
                                  if (_reply != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Semantics(
                                        liveRegion: true,
                                        child: Text(
                                          _reply!,
                                          key: const Key('coach-reply'),
                                          style: const TextStyle(height: 1.5),
                                        ),
                                      ),
                                    ),
                                  if (_coachError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        _coachError!,
                                        key: const Key('coach-error'),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Read-only coach • private progress • no reward access',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFECE8F8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}
