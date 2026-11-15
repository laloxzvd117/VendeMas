import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Se asigna en main() y en las pruebas.
final prefsProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('prefsProvider sin asignar'));

class Session {
  const Session(this.accountId, this.last4);
  final String accountId;
  final String last4;

  /// Nombre del archivo de la base local de esta cuenta.
  String get databaseName => 'vendemas_${accountId.substring(0, 16)}';
}

const _kActiveId = 'session.account';
const _kActiveLast4 = 'session.last4';
const _kRememberId = 'remember.account';
const _kRememberLast4 = 'remember.last4';

/// Sesión actual. Con "Recordar usuario" la app entra directo al abrirse y,
/// tras cerrar sesión, ofrece continuar con el mismo número. Sin marcarlo,
/// pide el número cada vez que se abre la app.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() {
    final p = ref.watch(prefsProvider);
    final id = p.getString(_kActiveId);
    return id == null ? null : Session(id, p.getString(_kActiveLast4) ?? '');
  }

  Future<void> login(Session s, {required bool remember}) async {
    final p = ref.read(prefsProvider);
    if (remember) {
      await p.setString(_kActiveId, s.accountId);
      await p.setString(_kActiveLast4, s.last4);
      await p.setString(_kRememberId, s.accountId);
      await p.setString(_kRememberLast4, s.last4);
    } else {
      await p.remove(_kActiveId);
      await p.remove(_kActiveLast4);
      await p.remove(_kRememberId);
      await p.remove(_kRememberLast4);
    }
    state = s;
  }

  Future<void> logout() async {
    final p = ref.read(prefsProvider);
    await p.remove(_kActiveId);
    await p.remove(_kActiveLast4);
    state = null;
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

/// Usuario recordado para "Continuar como…" en el acceso.
Session? rememberedUser(SharedPreferences p) {
  final id = p.getString(_kRememberId);
  return id == null ? null : Session(id, p.getString(_kRememberLast4) ?? '');
}

Future<void> forgetUser(SharedPreferences p) async {
  await p.remove(_kRememberId);
  await p.remove(_kRememberLast4);
}
