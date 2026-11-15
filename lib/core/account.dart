import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Sal fija de la app. Es la misma en todos los dispositivos para que el
/// mismo número siempre dé la misma cuenta (bcrypt usa sal aleatoria y no
/// serviría para reconocer al usuario en el celular y en la computadora).
const _appSalt = 'VendeMas.cuenta.v1';
const _iterations = 20000;

/// Deja solo los 10 dígitos del número (quita espacios, guiones y +52).
String? normalizePhone(String input) {
  var d = input.replaceAll(RegExp(r'\D'), '');
  if (d.length == 13 && d.startsWith('521')) d = d.substring(3);
  if (d.length == 12 && d.startsWith('52')) d = d.substring(2);
  return d.length == 10 ? d : null;
}

/// PBKDF2-HMAC-SHA256 con una sola salida de 32 bytes, en hexadecimal.
String pbkdf2Hex(String password, String salt, int iterations) {
  final mac = Hmac(sha256, utf8.encode(password));
  var u = mac.convert([...utf8.encode(salt), 0, 0, 0, 1]).bytes;
  final out = Uint8List.fromList(u);
  for (var i = 1; i < iterations; i++) {
    u = mac.convert(u).bytes;
    for (var j = 0; j < out.length; j++) {
      out[j] ^= u[j];
    }
  }
  return out.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Identificador de la cuenta. El número nunca se guarda en texto plano:
/// solo este hash y los últimos 4 dígitos para mostrarlo.
String accountIdFor(String phone) => pbkdf2Hex(phone, _appSalt, _iterations);

String lastFour(String phone) => phone.substring(phone.length - 4);

String maskedPhone(String last4) => '•• •••• $last4';
