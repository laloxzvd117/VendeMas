import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/account.dart';
import '../../core/platform.dart';
import '../../data/session.dart';

/// F-24: acceso con número de teléfono. La verificación por código SMS
/// llega con el servidor en la nube (fase 4).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _State();
}

class _State extends ConsumerState<LoginScreen> {
  final _ctrl = TextEditingController();
  bool _remember = true;
  bool _busy = false;
  String? _error;
  Session? _known;

  @override
  void initState() {
    super.initState();
    _known = rememberedUser(ref.read(prefsProvider));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    final phone = normalizePhone(_ctrl.text);
    if (phone == null) {
      setState(() => _error = 'Escribe tu número de 10 dígitos.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final id = await compute(accountIdFor, phone);
    await ref
        .read(sessionProvider.notifier)
        .login(Session(id, lastFour(phone)), remember: _remember);
  }

  Future<void> _continue() async {
    final s = _known;
    if (s == null) return;
    setState(() => _busy = true);
    await ref.read(sessionProvider.notifier).login(s, remember: true);
  }

  Future<void> _useOther() async {
    await forgetUser(ref.read(prefsProvider));
    setState(() => _known = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final known = _known;

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
                  Text('Entra a VendeMas', style: tt.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    isDesktop
                        ? 'Usa el mismo número que en tu celular para ver tus reportes.'
                        : 'Tu número es tu usuario. Con él verás tus datos también en la computadora.',
                    style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  if (known != null) ...[
                    Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(maskedPhone(known.last4)),
                        subtitle: const Text('Usuario recordado'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _busy ? null : _continue,
                        child: const Text('Continuar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _busy ? null : _useOther,
                        child: const Text('Usar otro número'),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _ctrl,
                      enabled: !_busy,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (_) => setState(() => _error = null),
                      onSubmitted: (_) => _enter(),
                      decoration: InputDecoration(
                        labelText: 'Número de celular',
                        helperText: '10 dígitos, sin lada internacional.',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _remember,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _remember = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Recordar usuario'),
                      subtitle: const Text('No tendrás que escribirlo cada vez.'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _busy ? null : _enter,
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
