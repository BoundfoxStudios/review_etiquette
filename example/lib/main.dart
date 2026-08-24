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

  bool _shortCooldown = true;
  ReviewRequestOutcome? _outcome;
  String? _storeError;

  @override
  void dispose() {
    _appVersion.dispose();
    _appStoreId.dispose();
    super.dispose();
  }

  Future<void> _onSuccessEvent() async {
    final etiquette = ReviewEtiquette(
      appVersion: _appVersion.text.trim(),
      cooldown: _shortCooldown ? Duration.zero : const Duration(days: 120),
    );

    final outcome = await etiquette.requestReview();

    if (!mounted) {
      return;
    }
    setState(() => _outcome = outcome);
  }

  Future<void> _onRateTapped() async {
    final id = _appStoreId.text.trim();

    try {
      await ReviewEtiquette.openStoreListing(
        appStoreId: id.isEmpty ? null : id,
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
        if (_storeError case final String message) ...<Widget>[
          const SizedBox(height: 12),
          Text(message),
        ],
      ],
    ),
  );
}
