import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/platform.dart';
import '../providers.dart';
import 'database.dart';
import 'sync_data.dart';

/// Sincronización en la red local: el celular comparte sus datos y la
/// computadora los copia para consultarlos. Es temporal hasta tener el
/// servidor en la nube (fase 4).
const lanHttpPort = 8787;
const lanUdpPort = 8788;
const _accountHeader = 'x-vendemas-cuenta';
const _askPrefix = 'VENDEMAS_BUSCA ';
const _herePrefix = 'VENDEMAS_AQUI ';

/// Direcciones IPv4 de este equipo en la red, primero las de Wi-Fi/casa.
Future<List<String>> localIPv4() async {
  try {
    final list = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLoopback: false);
    final all = [
      for (final i in list)
        for (final a in i.addresses)
          if (!a.isLinkLocal) a.address
    ];
    bool private(String ip) =>
        ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(ip);
    return [...all.where(private), ...all.where((ip) => !private(ip))];
  } catch (_) {
    return const [];
  }
}

// ───────────────────────── Celular ─────────────────────────

class LanServerStatus {
  const LanServerStatus({
    this.running = false,
    this.addresses = const [],
    this.lastClient,
    this.error,
  });
  final bool running;
  final List<String> addresses;
  final DateTime? lastClient;
  final String? error;

  LanServerStatus copyWith({DateTime? lastClient}) => LanServerStatus(
        running: running,
        addresses: addresses,
        lastClient: lastClient ?? this.lastClient,
        error: error,
      );
}

class LanServer {
  LanServer({required this.db, required this.accountId, this.port = lanHttpPort});
  final AppDatabase db;
  final String accountId;
  final int port;

  final status = ValueNotifier(const LanServerStatus());
  HttpServer? _http;

  /// Puerto real (útil en pruebas con puerto 0).
  int? get boundPort => _http?.port;
  RawDatagramSocket? _udp;
  bool _stopped = false;

  Future<void> start({bool discovery = true}) async {
    try {
      final http = await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
      if (_stopped) {
        await http.close(force: true);
        return;
      }
      _http = http;
      http.listen(_handle);
      if (discovery) await _startDiscovery();
      final ips = await localIPv4();
      if (!_stopped) status.value = LanServerStatus(running: true, addresses: ips);
    } catch (e) {
      if (!_stopped) status.value = LanServerStatus(error: '$e');
    }
  }

  /// Responde a la computadora que busca esta cuenta en la red.
  Future<void> _startDiscovery() async {
    try {
      final udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, lanUdpPort,
          reuseAddress: true);
      if (_stopped) {
        udp.close();
        return;
      }
      _udp = udp;
      udp.listen((e) {
        if (e != RawSocketEvent.read) return;
        final d = udp.receive();
        if (d == null) return;
        final msg = utf8.decode(d.data, allowMalformed: true);
        if (msg == '$_askPrefix$accountId') {
          udp.send(utf8.encode('$_herePrefix$port'), d.address, d.port);
        }
      });
    } catch (_) {
      // Sin búsqueda automática: la computadora puede escribir la dirección.
    }
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    try {
      if (req.headers.value(_accountHeader) != accountId) {
        res.statusCode = HttpStatus.forbidden;
        return;
      }
      final Map<String, dynamic> body;
      switch (req.uri.path) {
        case '/vendemas/version':
          body = {'version': await db.syncVersion()};
        case '/vendemas/data':
          body = await db.exportAll();
        default:
          res.statusCode = HttpStatus.notFound;
          return;
      }
      res.headers.contentType = ContentType.json;
      res.write(jsonEncode(body));
      status.value = status.value.copyWith(lastClient: DateTime.now());
    } catch (_) {
      try {
        res.statusCode = HttpStatus.internalServerError;
      } catch (_) {
        // La respuesta ya había empezado a enviarse.
      }
    } finally {
      await res.close();
    }
  }

  Future<void> stop() async {
    _stopped = true;
    _udp?.close();
    await _http?.close(force: true);
  }
}

/// Activo mientras la app del celular esté abierta con una sesión.
final lanServerProvider = Provider.autoDispose<LanServer?>((ref) {
  final s = ref.watch(sessionProvider);
  if (s == null || !canServeLan) return null;
  final server = LanServer(db: ref.watch(databaseProvider), accountId: s.accountId);
  server.start();
  ref.onDispose(server.stop);
  return server;
});

// ───────────────────────── Computadora ─────────────────────────

class SyncError implements Exception {
  const SyncError(this.message);
  final String message;
  @override
  String toString() => message;
}

class LanClient {
  LanClient({required this.accountId, required this.db});
  final String accountId;
  final AppDatabase db;

  Future<Map<String, dynamic>> _get(String host, int port, String path) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final req = await client.get(host, port, path);
      req.headers.set(_accountHeader, accountId);
      final res = await req.close().timeout(const Duration(seconds: 20));
      final text = await res.transform(utf8.decoder).join();
      if (res.statusCode == HttpStatus.forbidden) {
        throw const SyncError('Ese celular tiene abierta otra cuenta.');
      }
      if (res.statusCode != HttpStatus.ok) {
        throw SyncError('El celular respondió con error ${res.statusCode}.');
      }
      return (jsonDecode(text) as Map).cast<String, dynamic>();
    } on SyncError {
      rethrow;
    } catch (_) {
      throw const SyncError('No se pudo conectar con el celular.');
    } finally {
      client.close(force: true);
    }
  }

  /// Copia los datos del celular si cambiaron desde [lastVersion].
  /// Devuelve la versión actual del celular.
  Future<String> pull(String host,
      {String? lastVersion, int port = lanHttpPort}) async {
    final v = (await _get(host, port, '/vendemas/version'))['version'] as String;
    if (v == lastVersion) return v;
    await db.importAll(await _get(host, port, '/vendemas/data'));
    return v;
  }

  /// Busca en la red un celular con esta cuenta abierta.
  static Future<String?> discover(String accountId,
      {Duration wait = const Duration(seconds: 2)}) async {
    RawDatagramSocket? socket;
    try {
      final s = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket = s;
      s.broadcastEnabled = true;
      final found = Completer<String?>();
      s.listen((e) {
        if (e != RawSocketEvent.read) return;
        final d = s.receive();
        if (d == null || found.isCompleted) return;
        if (utf8.decode(d.data, allowMalformed: true).startsWith(_herePrefix)) {
          found.complete(d.address.address);
        }
      });
      final targets = <String>{'255.255.255.255'};
      for (final ip in await localIPv4()) {
        final p = ip.split('.');
        targets.add('${p[0]}.${p[1]}.${p[2]}.255');
      }
      final msg = utf8.encode('$_askPrefix$accountId');
      for (var round = 0; round < 2; round++) {
        for (final t in targets) {
          try {
            s.send(msg, InternetAddress(t), lanUdpPort);
          } catch (_) {
            // Esa red no acepta difusión; se intenta con las demás.
          }
        }
      }
      return await found.future.timeout(wait, onTimeout: () => null);
    } catch (_) {
      return null;
    } finally {
      socket?.close();
    }
  }
}

enum SyncPhase { idle, searching, connected, notFound, lost }

class SyncState {
  const SyncState({
    this.phase = SyncPhase.idle,
    this.host,
    this.lastCheck,
    this.lastChange,
    this.message,
  });
  final SyncPhase phase;
  final String? host;
  final DateTime? lastCheck;
  final DateTime? lastChange;
  final String? message;
}

String _messageFor(Object e) =>
    e is SyncError ? e.message : 'No se pudieron copiar los datos del celular.';

String _hostKey(String accountId) => 'lan.host.${accountId.substring(0, 16)}';

/// La computadora revisa cada 5 segundos si el celular tiene datos nuevos.
class DesktopSync extends Notifier<SyncState> {
  Timer? _timer;
  LanClient? _client;
  String? _version;
  bool _busy = false;
  int _gen = 0;

  @override
  SyncState build() {
    final s = ref.watch(sessionProvider);
    final gen = ++_gen;
    _timer?.cancel();
    _client = null;
    _version = null;
    ref.onDispose(() {
      _timer?.cancel();
      _gen++;
    });
    if (s == null) return const SyncState();

    _client = LanClient(accountId: s.accountId, db: ref.watch(databaseProvider));
    final saved = ref.read(prefsProvider).getString(_hostKey(s.accountId));
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _tick(gen));
    Future.microtask(() => saved == null ? search() : connect(saved));
    return SyncState(phase: SyncPhase.searching, host: saved);
  }

  void _set(int gen, SyncState s) {
    if (gen == _gen) state = s;
  }

  Future<void> search() async {
    final c = _client;
    if (c == null || _busy) return;
    final gen = _gen;
    _busy = true;
    _set(gen, SyncState(phase: SyncPhase.searching, lastChange: state.lastChange));
    final host = await LanClient.discover(c.accountId);
    _busy = false;
    if (gen != _gen) return;
    if (host == null) {
      _set(gen, SyncState(phase: SyncPhase.notFound, lastChange: state.lastChange));
      return;
    }
    await connect(host);
  }

  Future<void> connect(String host) async {
    for (var i = 0; _busy && i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    final c = _client;
    if (c == null || _busy) return;
    final gen = _gen;
    _busy = true;
    try {
      _version = await c.pull(host, lastVersion: _version);
      if (gen != _gen) return;
      await ref.read(prefsProvider).setString(_hostKey(c.accountId), host);
      final now = DateTime.now();
      _set(gen, SyncState(
          phase: SyncPhase.connected, host: host, lastCheck: now, lastChange: now));
    } catch (e) {
      _set(gen, SyncState(
          phase: SyncPhase.lost,
          host: host,
          lastChange: state.lastChange,
          message: _messageFor(e)));
    } finally {
      _busy = false;
    }
  }

  Future<void> _tick(int gen) async {
    final c = _client;
    final host = state.host;
    if (c == null || _busy || gen != _gen) return;
    if (state.phase == SyncPhase.notFound || state.phase == SyncPhase.lost) {
      // Vuelve a buscar en silencio: el celular pudo abrir la app o cambiar de IP.
      _busy = true;
      final found = await LanClient.discover(c.accountId);
      _busy = false;
      if (gen != _gen) return;
      final target = found ?? host;
      if (target != null) await connect(target);
      return;
    }
    if (host == null || state.phase == SyncPhase.searching) return;
    _busy = true;
    try {
      final before = _version;
      _version = await c.pull(host, lastVersion: before);
      final now = DateTime.now();
      _set(gen, SyncState(
        phase: SyncPhase.connected,
        host: host,
        lastCheck: now,
        lastChange: _version != before ? now : state.lastChange,
      ));
    } catch (e) {
      _set(gen, SyncState(
          phase: SyncPhase.lost,
          host: host,
          lastChange: state.lastChange,
          message: _messageFor(e)));
    } finally {
      _busy = false;
    }
  }
}

final desktopSyncProvider =
    NotifierProvider.autoDispose<DesktopSync, SyncState>(DesktopSync.new);
