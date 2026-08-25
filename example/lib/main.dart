import 'package:flutter/material.dart';
import 'package:review_etiquette/review_etiquette.dart';

void main() => runApp(const ReviewEtiquetteExampleApp());

class ReviewEtiquetteExampleApp extends StatelessWidget {
  const ReviewEtiquetteExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'review_etiquette',
    theme: ThemeData(useMaterial3: true),
    home: const ExamplePage(),
  );
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // Editable so the "one prompt per version" condition can be walked through by
  // hand: type a new version and the next success event asks again.
  final TextEditingController _appVersion = TextEditingController(
    text: '1.0.0',
  );
  final TextEditingController _appStoreId = TextEditingController();
  final TextEditingController _otherAppStoreId = TextEditingController();
  final TextEditingController _otherPackageName = TextEditingController();

  bool _shortCooldown = true;
  ReviewRequestOutcome? _outcome;
  String? _storeError;

  @override
  void dispose() {
    _appVersion.dispose();
    _appStoreId.dispose();
    _otherAppStoreId.dispose();
    _otherPackageName.dispose();
    super.dispose();
  }

  // A real app builds this once, in whatever it uses for dependency injection.
  // Here it is rebuilt per call so the version field stays editable.
  ReviewEtiquette get _etiquette => ReviewEtiquette(
    appVersion: _appVersion.text.trim(),
    cooldown: _shortCooldown ? Duration.zero : const Duration(days: 120),
  );

  Future<void> _onSuccessEvent() async {
    final outcome = await _etiquette.requestReview();

    if (!mounted) {
      return;
    }
    setState(() => _outcome = outcome);
  }

  Future<void> _onRateTapped() async {
    final id = _appStoreId.text.trim();

    try {
      await _etiquette.openStoreListing(appStoreId: id.isEmpty ? null : id);
      if (!mounted) {
        return;
      }
      setState(() => _storeError = null);
    } on ReviewEtiquetteException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _storeError = error.message);
    }
  }

  Future<void> _onShowOtherAppTapped() async {
    final appStoreId = _otherAppStoreId.text.trim();
    final packageName = _otherPackageName.text.trim();

    try {
      await ReviewEtiquette.showStoreListing(
        appStoreId: appStoreId.isEmpty ? null : appStoreId,
        androidPackageName: packageName.isEmpty ? null : packageName,
      );
      if (!mounted) {
        return;
      }
      setState(() => _storeError = null);
    } on ReviewEtiquetteException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _storeError = error.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('review_etiquette')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          controller: _appVersion,
          decoration: const InputDecoration(
            labelText: 'App version',
            helperText: 'The user visible version, not a build number.',
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _shortCooldown,
          onChanged: (bool value) => setState(() => _shortCooldown = value),
          title: const Text('Zero cooldown'),
          subtitle: const Text(
            'On, so the version condition can be tried without waiting 120 days.',
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _onSuccessEvent,
          child: const Text('Pretend the app just delivered value'),
        ),
        if (_outcome case final ReviewRequestOutcome outcome) ...<Widget>[
          const SizedBox(height: 12),
          Text('Outcome: ${outcome.name}'),
          if (outcome == ReviewRequestOutcome.requested)
            const Text(
              'This means we asked. Neither store reports whether a prompt '
              'was actually shown.',
            ),
        ],
        const Divider(height: 48),
        TextField(
          controller: _appStoreId,
          decoration: const InputDecoration(
            labelText: 'App Store id',
            helperText: 'Required on iOS, ignored on Android.',
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _onRateTapped,
          child: const Text('Rate this app'),
        ),
        const Divider(height: 48),
        TextField(
          controller: _otherAppStoreId,
          decoration: const InputDecoration(
            labelText: "Another app's App Store id",
            helperText: 'Required on iOS.',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otherPackageName,
          decoration: const InputDecoration(
            labelText: "Another app's package name",
            helperText: 'Required on Android.',
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _onShowOtherAppTapped,
          child: const Text("Show another app's listing"),
        ),
        if (_storeError case final String message) ...<Widget>[
          const SizedBox(height: 12),
          Text(message),
        ],
      ],
    ),
  );
}
