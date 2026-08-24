import 'package:flutter/material.dart';

void main() => runApp(const ReviewEtiquetteExampleApp());

class ReviewEtiquetteExampleApp extends StatelessWidget {
  const ReviewEtiquetteExampleApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(body: Center(child: Text('review_etiquette'))),
  );
}
