import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _ReportItem {
  final String title;
  final String subtitle;
  final String route;
  final String badge;

  const _ReportItem({required this.title, required this.subtitle, required this.route, required this.badge});
}

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});

  static const _reports = [
    _ReportItem(title: 'Más vendidos', subtitle: 'Ranking por unidades o ganancia', route: '/reports/rank', badge: '#1'),
    _ReportItem(title: 'Clasificación ABC', subtitle: 'Productos por contribución a la ganancia', route: '/reports/abc', badge: 'ABC'),
    _ReportItem(title: 'Margen y rotación', subtitle: 'Cuadrantes: estrellas, joyas, alto volumen, revisar', route: '/reports/matrix', badge: '4Q'),
    _ReportItem(title: 'Productos muertos', subtitle: 'Sin venta en 14+ días con existencia', route: '/reports/dead', badge: '⚠'),
    _ReportItem(title: 'Horas fuertes', subtitle: 'Distribución de ventas por hora', route: '/reports/hours', badge: '🕐'),
    _ReportItem(title: 'Se venden juntos', subtitle: 'Pares de productos frecuentes', route: '/reports/pairs', badge: '🔗'),
    _ReportItem(title: 'Tendencias', subtitle: 'Cambios semana vs semana anterior', route: '/reports/trend', badge: '📈'),
    _ReportItem(title: 'Resumen semanal', subtitle: 'Vista completa de la semana', route: '/reports/weekly', badge: '7d'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final r = _reports[index];
          return InkWell(
            onTap: () => context.push(r.route),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(r.badge,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(r.subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
