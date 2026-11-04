import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

/// F-01: crea el negocio en el primer inicio.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _State();
}

class _State extends ConsumerState<OnboardingScreen> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final v = _ctrl.text.trim();
    if (v.isEmpty) {
      setState(() => _error = 'Escribe el nombre de tu negocio.');
      return;
    }
    await ref.read(databaseProvider).setBusinessName(v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(24)),
                    child: Icon(Icons.storefront,
                        size: 40, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: 24),
                  Text('Bienvenido a VendeMas', style: tt.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tus ventas, entérate de lo que se te acaba y '
                    'descubre qué productos te dejan más ganancia.',
                    style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _ctrl,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _error = null),
                    onSubmitted: (_) => _start(),
                    decoration: InputDecoration(
                      labelText: 'Nombre de tu negocio',
                      helperText:
                          'Así aparecerá en tus reportes. Lo puedes cambiar en Ajustes.',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                        onPressed: _start, child: const Text('Empezar')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
