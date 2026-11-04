import 'package:flutter/material.dart';

/// Los reportes llegan en la fase 3 (F-10 a F-19).
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Reportes')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Los reportes estarán disponibles pronto.',
                textAlign: TextAlign.center),
          ),
        ),
      );
}
