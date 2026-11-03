import 'package:flutter/material.dart';
import '../../../core/data/report_data.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/desk_widgets.dart';

class DeskRankView extends StatefulWidget {
  const DeskRankView({super.key});

  @override
  State<DeskRankView> createState() => _DeskRankViewState();
}

class _DeskRankViewState extends State<DeskRankView> {
  String _sortBy = 'units';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = List.of(ReportData.rank);
    sorted.sort((a, b) => _sortBy == 'units' ? b.$2.compareTo(a.$2) : b.$3.compareTo(a.$3));
    final maxVal = _sortBy == 'units' ? sorted.first.$2.toDouble() : sorted.first.$3;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'units', label: Text('Unidades')),
              ButtonSegment(value: 'profit', label: Text('Ganancia')),
            ],
            selected: {_sortBy},
            onSelectionChanged: (v) => setState(() => _sortBy = v.first),
          ),
        ),
        const SizedBox(height: 16),
        DeskCard(
          child: Column(
            children: [
              for (var i = 0; i < sorted.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('${i + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 180, child: Text(sorted[i].$1, style: const TextStyle(fontSize: 15))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            minHeight: 12,
                            value: (_sortBy == 'units' ? sorted[i].$2 : sorted[i].$3) / maxVal,
                            backgroundColor: cs.surfaceContainerHighest,
                            color: i < 3 ? cs.primary : cs.secondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          _sortBy == 'units' ? '${sorted[i].$2} uds' : Formatters.currency(sorted[i].$3),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
