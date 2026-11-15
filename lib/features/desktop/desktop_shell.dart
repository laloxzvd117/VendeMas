import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/account.dart';
import '../../core/format.dart';
import '../../data/lan_sync.dart';
import '../../providers.dart';
import '../reports/export_sheet.dart';
import '../reports/report_registry.dart';
import '../settings/settings_screen.dart' show confirmLogout;

/// F-23: consulta de reportes en computadora, solo lectura. Usa los mismos
/// reportes y cálculos que el celular.
class DesktopShell extends ConsumerStatefulWidget {
  const DesktopShell({super.key});
  @override
  ConsumerState<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<DesktopShell> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = ref.watch(businessNameProvider).value ?? 'Mi negocio';
    final def = reportDefs[_selected];

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 280,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.storefront,
                            size: 22, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: tt.titleMedium,
                                overflow: TextOverflow.ellipsis),
                            Text('Solo consulta',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: cs.outlineVariant),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Reportes',
                        style: tt.labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: reportDefs.length,
                    itemBuilder: (context, i) {
                      final r = reportDefs[i];
                      final active = i == _selected;
                      final fg =
                          active ? cs.onSecondaryContainer : cs.onSurfaceVariant;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Material(
                          color: active
                              ? cs.secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: Colors.transparent,
                            hoverColor: cs.onSurface.withAlpha(15),
                            onTap: () {
                              if (_selected != i) setState(() => _selected = i);
                            },
                            child: SizedBox(
                              height: 44,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    Icon(r.icon, size: 20, color: fg),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(r.title,
                                          style: tt.bodyMedium
                                              ?.copyWith(color: fg),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const _SidebarFooter(),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(def.title, style: tt.headlineSmall)),
                      if (def.key == 'week')
                        FilledButton.tonalIcon(
                          onPressed: () => showExportSheet(context, ref),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Exportar'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: KeyedSubtree(
                        key: ValueKey(def.key),
                        child: def.body(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Conexión con el celular, cuenta y cerrar sesión.
class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sync = ref.watch(desktopSyncProvider);
    final session = ref.watch(sessionProvider);

    final (icon, color, text) = switch (sync.phase) {
      SyncPhase.connected => (
          Icons.sync,
          cs.primary,
          'Conectado con tu celular · revisado ${sync.lastCheck == null ? '' : hm(sync.lastCheck!)}'
        ),
      SyncPhase.searching => (
          Icons.wifi_find,
          cs.onSurfaceVariant,
          'Buscando tu celular en la red…'
        ),
      SyncPhase.notFound => (
          Icons.wifi_off,
          cs.tertiary,
          'No se encontró tu celular. Abre VendeMas en él, con la misma red Wi-Fi.'
        ),
      SyncPhase.lost => (
          Icons.sync_problem,
          cs.error,
          sync.message ?? 'Se perdió la conexión con tu celular.'
        ),
      SyncPhase.idle => (Icons.sync_disabled, cs.outline, 'Sin conexión'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: tt.bodySmall)),
            ],
          ),
          if (sync.lastChange != null)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: Text('Datos actualizados a las ${hm(sync.lastChange!)}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ),
          if (sync.phase != SyncPhase.connected &&
              sync.phase != SyncPhase.searching)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 4),
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: () => ref.read(desktopSyncProvider.notifier).search(),
                    child: const Text('Buscar de nuevo'),
                  ),
                  TextButton(
                    onPressed: () => _askHost(context, ref),
                    child: const Text('Escribir dirección'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(maskedPhone(session?.last4 ?? ''),
                    style: tt.bodyMedium),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () => confirmLogout(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _askHost(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final host = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dirección del celular'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('En el celular ve a Ajustes → Computadora y copia la '
                'dirección que aparece, por ejemplo 192.168.1.23.'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Dirección', border: OutlineInputBorder()),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Conectar')),
        ],
      ),
    );
    if (host == null || host.isEmpty) return;
    await ref.read(desktopSyncProvider.notifier).connect(host);
  }
}
