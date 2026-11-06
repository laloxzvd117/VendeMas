import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import 'export_sheet.dart';
import 'report_registry.dart';
import 'report_texts.dart';

/// F-10: menú de reportes, cada uno con su hallazgo principal.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final data = ref.watch(reportDataProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Cada reporte termina en una decisión, no solo en una gráfica.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
          for (final r in reportDefs)
            Builder(builder: (context) {
              final h = data == null ? noSalesHeadline : r.headline(data);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go('/reports/${r.key}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(h.big,
                              style: tt.titleLarge?.copyWith(color: cs.primary),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title, style: tt.titleMedium),
                              const SizedBox(height: 2),
                              Text(h.text,
                                  style: tt.bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// F-11 a F-18: un reporte en pantalla completa.
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key, required this.reportKey});
  final String reportKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = reportByKey(reportKey);
    if (def == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reporte')),
        body: const Center(child: Text('Ese reporte no existe.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(def.title),
        actions: [
          if (def.key == 'week')
            IconButton(
              tooltip: 'Exportar',
              icon: const Icon(Icons.ios_share),
              onPressed: () => showExportSheet(context, ref),
            ),
        ],
      ),
      body: def.body(),
    );
  }
}