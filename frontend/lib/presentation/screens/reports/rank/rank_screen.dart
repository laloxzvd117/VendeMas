import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  String _sortBy = 'units';

  final _sampleData = [
    ('Bolillo', 980, 2940.0),
    ('Concha', 410, 3485.0),
    ('Café americano', 300, 5400.0),
    ('Cuernito', 180, 1800.0),
    ('Dona glaseada', 140, 1260.0),
    ('Empanada', 90, 900.0),
    ('Tamal', 70, 630.0),
    ('Pan de muerto', 60, 1260.0),
    ('Rebanada de pastel', 25, 375.0),
    ('Pan integral', 8, 192.0),
    ('Galleta de avena', 4, 28.0),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = List.of(_sampleData);
    if (_sortBy == 'profit') {
      sorted.sort((a, b) => b.$3.compareTo(a.$3));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Más vendidos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'units', label: Text('Unidades')),
                ButtonSegment(value: 'profit', label: Text('Ganancia')),
              ],
              selected: {_sortBy},
              onSelectionChanged: (v) => setState(() => _sortBy = v.first),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final item = sorted[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: index > 0 ? Border(top: BorderSide(color: colorScheme.outlineVariant)) : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text('${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1, style: const TextStyle(fontSize: 16)),
                            Text(_sortBy == 'units' ? '${item.$2} uds' : Formatters.currency(item.$3),
                              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Text(_sortBy == 'units' ? '${item.$2}' : Formatters.currency(item.$3),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
