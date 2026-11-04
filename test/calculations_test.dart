import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/domain/calculations.dart';

LineItem item(int q, int price, int cost) => LineItem(
    productId: 'x', name: 'x', qty: q, unitPrice: price, unitCost: cost);

void main() {
  test('total, ganancia y piezas', () {
    final items = [item(2, 1500, 650), item(1, 2500, 700)];
    expect(saleTotal(items), 5500);
    expect(saleProfit(items), 2 * 850 + 1800);
    expect(pieceCount(items), 3);
  });

  test('cambio y bloqueo de cobro (RF-06)', () {
    expect(changeFor(total: 5500, received: 10000), 4500);
    expect(changeFor(total: 5500, received: 5000), -500);
    expect(canCharge(total: 5500, received: null), isFalse);
    expect(canCharge(total: 5500, received: 5499), isFalse);
    expect(canCharge(total: 5500, received: 5500), isTrue);
    expect(canCharge(total: 0, received: 100), isFalse);
  });

  test('margen (RF-04)', () {
    expect(marginPercent(price: 1500, cost: 650).round(), 57);
    expect(marginPercent(price: 0, cost: 100), 0);
    expect(marginPercent(price: 1000, cost: 1200), lessThan(0));
  });

  test('montos sugeridos', () {
    expect(suggestedCash(5500), [6000, 10000, 20000]);
    expect(suggestedCash(10000), [20000, 50000]);
  });

  test('parseCents', () {
    expect(parseCents('15'), 1500);
    expect(parseCents('15,50'), 1550);
    expect(parseCents(' 0.1 '), 10);
    expect(parseCents(''), isNull);
    expect(parseCents('abc'), isNull);
    expect(parseCents('-3'), isNull);
  });
}
