import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/account.dart';
import '../../core/format.dart';
import '../../data/lan_sync.dart';
import '../../data/seed.dart';
import '../../providers.dart';

/// F-20: datos del negocio y la cuenta, computadora, datos de ejemplo y
/// cerrar sesión.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = ref.watch(businessNameProvider).value ?? '';
    final session = ref.watch(sessionProvider);
    final server = ref.watch(lanServerProvider);
    final hasSales = (ref.watch(recentSalesProvider).value ?? const []).isNotEmpty;

    Widget title(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(t, style: tt.titleSmall?.copyWith(color: cs.primary)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          title('Negocio'),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: Text(name),
            subtitle: const Text('Nombre del negocio'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => showEditNameSheet(context, ref, name),
          ),
          title('Cuenta'),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(maskedPhone(session?.last4 ?? '')),
            subtitle: const Text(
                'Tu número es tu usuario. Se guarda cifrado, nunca en texto plano.'),
          ),
          title('Computadora'),
          if (server == null)
            const ListTile(
              leading: Icon(Icons.desktop_access_disabled_outlined),
              title: Text('No disponible en esta plataforma.'),
            )
          else
            ValueListenableBuilder<LanServerStatus>(
              valueListenable: server.status,
              builder: (context, st, _) => _LanCard(st),
            ),
          if (!hasSales) ...[
            title('Datos de ejemplo'),
            ListTile(
              leading: const Icon(Icons.inventory_outlined),
              title: const Text('Cargar una tienda de abarrotes de ejemplo'),
              subtitle: const Text(
                  '9 semanas de ventas para ver cómo funcionan los reportes. '
                  'Solo se puede en una cuenta sin ventas.'),
              onTap: () => _seed(context, ref),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => confirmLogout(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seed(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cargar datos de ejemplo?'),
        content: const Text(
            'Se agregan 20 productos de abarrotes y 9 semanas de ventas a esta '
            'cuenta. Úsalo solo para probar: no se pueden borrar después.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cargar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final r = await ref.read(databaseProvider).seedDemoData();
      ref.invalidate(businessNameProvider);
      messenger.showSnackBar(SnackBar(
          content: Text('Listo: ${r.products} productos y ${r.sales} ventas.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo: $e')));
    }
  }
}

class _LanCard extends StatelessWidget {
  const _LanCard(this.st);
  final LanServerStatus st;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (st.error != null) {
      return ListTile(
        leading: Icon(Icons.error_outline, color: cs.error),
        title: const Text('No se pudo compartir en la red'),
        subtitle: Text(st.error!),
      );
    }
    final ip = st.addresses.isEmpty ? null : st.addresses.first;
    final last = st.lastClient;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.wifi, color: st.running ? cs.primary : cs.outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  last == null
                      ? 'Esperando a tu computadora'
                      : 'Tu computadora revisó tus datos a las ${hm(last)}',
                  style: tt.titleSmall,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            const Text(
                'Abre VendeMas en tu computadora con este mismo número y '
                'conéctate a la misma red Wi-Fi. Mientras esta app esté abierta, '
                'la computadora copia tus datos sola.'),
            if (ip != null) ...[
              const SizedBox(height: 8),
              Text('Si no la encuentra, escribe en la computadora: $ip',
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

/// F-21: cambiar el nombre del negocio.
Future<void> showEditNameSheet(
    BuildContext context, WidgetRef ref, String current) async {
  final ctrl = TextEditingController(text: current);
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre del negocio', style: Theme.of(ctx).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              const SizedBox(width: 8),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Guardar')),
            ],
          ),
        ],
      ),
    ),
  );
  final v = ctrl.text.trim();
  if (saved != true || v.isEmpty || v == current) return;
  await ref.read(databaseProvider).setBusinessName(v);
  ref.invalidate(businessNameProvider);
}

/// F-22: confirmar el cierre de sesión. Se usa en celular y computadora.
Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Cerrar sesión?'),
      content: const Text(
          'Tus datos se quedan guardados en este equipo. Cuando vuelvas a '
          'entrar con el mismo número los verás otra vez.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión')),
      ],
    ),
  );
  if (ok == true) await ref.read(sessionProvider.notifier).logout();
}
