import 'package:flutter/material.dart';

class DeskCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Color? color;
  final EdgeInsets padding;

  const DeskCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(title!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.primary)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          ],
          if (title != null) const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class DeskBars extends StatelessWidget {
  final List<num> values;
  final List<String> labels;
  final List<String>? valueLabels;
  final int? highlight;
  final bool highlightMax;
  final double height;
  final ValueChanged<int>? onTap;

  const DeskBars({
    super.key,
    required this.values,
    required this.labels,
    this.valueLabels,
    this.highlight,
    this.highlightMax = false,
    this.height = 180,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final hi = highlight ?? (highlightMax ? values.indexOf(values.reduce((a, b) => a > b ? a : b)) : -1);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(values.length, (i) {
          final active = i == hi;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap == null ? null : () => onTap!(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (valueLabels != null)
                      Text(valueLabels![i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? cs.onSurface : cs.onSurfaceVariant,
                        )),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: (values[i] / maxVal).clamp(0.02, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: active ? cs.primary : cs.secondaryContainer,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? cs.onSurface : cs.onSurfaceVariant,
                      )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DeskStatRow extends StatelessWidget {
  final String label;
  final String value;

  const DeskStatRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
