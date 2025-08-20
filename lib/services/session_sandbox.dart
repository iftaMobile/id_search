// lib/services/session_sandbox.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionSandbox {
  static final SessionSandbox _instance = SessionSandbox._internal();
  factory SessionSandbox() => _instance;
  SessionSandbox._internal();

  final _storage = const FlutterSecureStorage();
  static const _keySesId = 'sesId';

  Future<void> saveSession(String sesId) async {
    await _storage.write(key: _keySesId, value: sesId);
  }

  Future<String?> loadSession() async {
    return await _storage.read(key: _keySesId);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keySesId);
  }
}