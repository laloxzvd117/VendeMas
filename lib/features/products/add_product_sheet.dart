import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/calculations.dart';
import '../../providers.dart';

/// F-07: alta de producto.
Future<void> showAddProductSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddProductSheet(),
    );

class _AddProductSheet extends ConsumerStatefulWidget {
  const _AddProductSheet();
  @override
  ConsumerState<_AddProductSheet> createState() => _State();
}

class _State extends ConsumerState<_AddProductSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _price, _cost, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = parseCents(_price.text);
    final cost = parseCents(_cost.text);
    final stockText = _stock.text.trim();
    final stock = stockText.isEmpty ? null : int.tryParse(stockText);

    if (name.isEmpty || price == null || price <= 0 || cost == null) {
      setState(() => _error = 'Escribe el nombre, el precio y el costo.');
      return;
    }
    if (stockText.isNotEmpty && (stock == null || stock < 0)) {
      setState(() => _error = 'Las existencias deben ser un número entero.');
      return;
    }
    await ref.read(databaseProvider).addProduct(
        name: name, priceCents: price, costCents: cost, initialStock: stock);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Producto agregado.')));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const dec = TextInputType.numberWithOptions(decimal: true);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agregar producto', style: tt.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Nombre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _price,
                  keyboardType: dec,
                  decoration: const InputDecoration(
                      labelText: 'Precio de venta',
                      prefixText: r'$ ',
                      border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cost,
                  keyboardType: dec,
                  decoration: const InputDecoration(
                      labelText: 'Costo',
                      prefixText: r'$ ',
                      border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Existencias (opcional)',
                helperText:
                    'Déjalo vacío si no llevas inventario de este producto.',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style: tt.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar')),
                const SizedBox(width: 8),
                FilledButton(onPressed: _save, child: const Text('Guardar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
