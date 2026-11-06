import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child});
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: tt.titleSmall?.copyWith(color: cs.primary)),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.label, required this.big, this.bottom});
  final String label;
  final String big;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.primaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: cs.onPrimaryContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(big,
                  style: tt.displaySmall?.copyWith(color: cs.onPrimaryContainer)),
              if (bottom != null) ...[const SizedBox(height: 4), bottom!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila con barra: nombre, valor y qué tan lleno está.
class BarRow extends StatelessWidget {
  const BarRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    this.leading,
    this.highlight = false,
  });
  final String label;
  final String value;
  final double fraction;
  final Widget? leading;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = fraction.isNaN ? 0.0 : fraction.clamp(0.02, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: cs.surfaceContainerHighest,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: f,
                child: Container(color: highlight ? cs.primary : cs.primary.withAlpha(170)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TagKind { ok, warn, err }

class Tag extends StatelessWidget {
  const Tag(this.text, this.kind, {super.key});
  final String text;
  final TagKind kind;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      TagKind.ok => (cs.primaryContainer, cs.onPrimaryContainer),
      TagKind.warn => (cs.tertiaryContainer, cs.onTertiaryContainer),
      TagKind.err => (cs.errorContainer, cs.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
    );
  }
}

class TipsCard extends StatelessWidget {
  const TipsCard({super.key, required this.title, required this.tips});
  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SectionCard(
      title: title,
      child: Column(
        children: [
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(child: Text(t)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyReport extends StatelessWidget {
  const EmptyReport(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
}

class Hint extends StatelessWidget {
  const Hint(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
