import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../../core/utils/formatters.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final _receivedController = TextEditingController();

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    _receivedController.text = amount.toStringAsFixed(0);
    context.read<CartProvider>().setReceived(amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = context.watch<CartProvider>();

    final total = cart.total;
    final quickAmounts = _quickAmounts(total);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/sell'),
        ),
        title: const Text('Cobrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text('Total a cobrar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 4),
                  Text(Formatters.currency(total),
                    style: TextStyle(fontSize: 40, color: colorScheme.onPrimaryContainer)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text('${cart.totalItems} producto${cart.totalItems != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(cart.describe(), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            TextField(
              controller: _receivedController,
              decoration: const InputDecoration(
                labelText: 'Recibido',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null) cart.setReceived(amount);
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: quickAmounts.map((amount) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => _setQuickAmount(amount),
                    child: Text(Formatters.currency(amount)),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            _ChangeDisplay(
              received: cart.received,
              total: total,
              change: cart.change,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: cart.canPay ? () => context.go('/confirmation') : null,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Confirmar venta', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _quickAmounts(double total) {
    final rounded = (total / 10).ceil() * 10.0;
    return [total, rounded, rounded + 50];
  }
}

class _ChangeDisplay extends StatelessWidget {
  final double? received;
  final double total;
  final double change;

  const _ChangeDisplay({required this.received, required this.total, required this.change});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;
    String label;
    String value;

    if (received == null) {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
      label = 'Cambio';
      value = '—';
    } else if (change < 0) {
      bgColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      label = 'Falta';
      value = Formatters.currency(change.abs());
    } else {
      bgColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      label = 'Cambio';
      value = Formatters.currency(change);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
          Text(value, style: TextStyle(fontSize: 28, color: textColor)),
        ],
      ),
    );
  }
}
