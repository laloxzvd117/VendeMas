
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/stock_ops.dart';
import '../../providers.dart';

/// F-09: registrar una entrada o un conteo, o activar y desactivar el control.
Future<void> showStockSheet(BuildContext context, ProductView p) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _StockSheet(p),
    );

class _StockSheet extends ConsumerStatefulWidget {
  const _StockSheet(this.p);
  final ProductView p;
  @override
  ConsumerState<_StockSheet> createState() => _State();
}

class _State extends ConsumerState<_StockSheet> {
  final _qty = TextEditingController();
  bool _isEntry = true;
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = int.tryParse(_qty.text.trim());
    final p = widget.p;
    final db = ref.read(databaseProvider);
    final id = p.product.id;
    final name = p.product.name;
    String msg;

    if (!p.tracked) {
      if (n == null || n < 0) {
        setState(() => _error = 'Escribe cuántos tienes ahora.');
        return;
      }
      await db.enableStock(id, n);
      msg = 'Ahora llevas existencias de $name: $n.';
    } else if (_isEntry) {
      if (n == null || n <= 0) {
        setState(() => _error = 'Escribe cuántas piezas llegaron.');
        return;
      }
      await db.receiveStock(id, n);
      msg = '$name: ahora hay ${p.stock + n}.';
    } else {
      if (n == null || n < 0) {
        setState(() => _error = 'Escribe cuántas piezas hay en total.');
        return;
      }
      await db.countStock(id, n);
      msg = 'Conteo guardado: $name tiene $n.';
    }
    _done(msg);
  }

  Future<void> _untrack() async {
    await ref.read(databaseProvider).disableStock(widget.p.product.id);
    _done('Ya no llevas existencias de ${widget.p.product.name}.');
  }

  void _done(String msg) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = widget.p;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.product.name, style: tt.headlineSmall),
            const SizedBox(height: 12),
            if (!p.tracked)
              Text(
                'Aún no llevas existencias de este producto. Escribe cuántos '
                'tienes ahora para empezar.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              )
            else ...[
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Entrada')),
                  ButtonSegment(value: false, label: Text('Conteo')),
                ],
                selected: {_isEntry},
                onSelectionChanged: (s) => setState(() {
                  _isEntry = s.first;
                  _error = null;
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Ahora hay ${p.stock}. '
                '${_isEntry ? 'Suma lo que llegó.' : 'Escribe cuántos hay en total.'}',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              if (_isEntry) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final q in const [6, 12, 24])
                      ActionChip(
                        label: Text('+$q'),
                        onPressed: () => setState(() => _qty.text = '$q'),
                      ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                labelText: !p.tracked
                    ? '¿Cuántos tienes ahora?'
                    : (_isEntry ? 'Piezas que llegaron' : 'Piezas que hay en total'),
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (p.tracked)
                  TextButton(
                    onPressed: _untrack,
                    style: TextButton.styleFrom(foregroundColor: cs.error),
                    child: const Text('Dejar de llevar'),
                  ),
                const Spacer(),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar')),
                const SizedBox(width: 8),
                FilledButton(
                    onPressed: _save,
                    child: Text(p.tracked ? 'Guardar' : 'Activar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
