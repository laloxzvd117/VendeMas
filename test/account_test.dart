import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/core/account.dart';

void main() {
  test('normaliza el número a 10 dígitos', () {
    expect(normalizePhone('229 123 4567'), '2291234567');
    expect(normalizePhone('+52 229-123-4567'), '2291234567');
    expect(normalizePhone('+52 1 229 123 4567'), '2291234567');
    expect(normalizePhone('12345'), isNull);
  });

  test('PBKDF2-HMAC-SHA256 coincide con los vectores conocidos', () {
    expect(pbkdf2Hex('password', 'salt', 1),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b');
    expect(pbkdf2Hex('password', 'salt', 2),
        'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43');
    expect(pbkdf2Hex('password', 'salt', 4096),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a');
  });

  test('el mismo número da la misma cuenta en cualquier equipo', () {
    final id = accountIdFor('2291234567');
    expect(id,
        '0f7f1657cc84c7ca354ee567931923024f8548ebb1dd6325079cb732082c7f3c');
    expect(id, isNot(contains('2291234567')));
    expect(accountIdFor('2291234568'), isNot(id));
    expect(maskedPhone(lastFour('2291234567')), '•• •••• 4567');
  });
}
