import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';

class DeskReport {
  final String path;
  final String label;
  const DeskReport(this.path, this.label);
}

const deskReports = [
  DeskReport('weekly', 'Resumen semanal'),
  DeskReport('rank', 'Más vendidos y rentables'),
  DeskReport('abc', 'Clasificación ABC'),
  DeskReport('matrix', 'Margen y rotación'),
  DeskReport('dead', 'Productos muertos'),
  DeskReport('hours', 'Horas y días fuertes'),
  DeskReport('pairs', 'Se venden juntos'),
  DeskReport('trend', 'Tendencias'),
];

class DesktopShell extends StatelessWidget {
  final Widget child;
  const DesktopShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final current = deskReports.firstWhere(
      (r) => location.endsWith('/${r.path}'),
      orElse: () => deskReports.first,
    );
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(selected: current.path),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: current.label, showExport: current.path == 'weekly'),
                Divider(height: 1, color: cs.outlineVariant),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: child,
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

class _Sidebar extends StatelessWidget {
  final String selected;
  const _Sidebar({required this.selected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = context.watch<BusinessProvider>().business?.name ?? 'Sin negocio';

    return Container(
      width: 270,
      color: cs.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.storefront, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text('Solo consulta',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Reportes',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: deskReports.map((r) {
                final on = r.path == selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: on ? cs.secondaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => context.go('/desk/${r.path}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Text(r.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: on ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                          )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Sincronizado hace 2 min',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool showExport;
  const _TopBar({required this.title, required this.showExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
          ),
          if (showExport)
            FilledButton.tonalIcon(
              onPressed: () => _showExportDialog(context),
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Exportar'),
            ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Exportar reporte'),
        children: [
          for (final opt in const [
            (Icons.picture_as_pdf_outlined, 'PDF'),
            (Icons.table_chart_outlined, 'CSV'),
            (Icons.image_outlined, 'Imagen'),
          ])
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reporte listo para exportar en ${opt.$2}')),
                );
              },
              child: Row(
                children: [
                  Icon(opt.$1),
                  const SizedBox(width: 16),
                  Text(opt.$2),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
