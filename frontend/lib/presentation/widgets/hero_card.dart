import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';

class HeroCard extends StatelessWidget {
  final String label;
  final double amount;
  final String? secondaryLabel;
  final String? secondaryValue;
  final Widget? trailing;

  const HeroCard({
    super.key,
    required this.label,
    required this.amount,
    this.secondaryLabel,
    this.secondaryValue,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(amount),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              if (secondaryLabel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      secondaryLabel!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      secondaryValue ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}
