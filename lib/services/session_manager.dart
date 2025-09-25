// lib/services/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:id_search/services/api_service.dart';

class SessionManager {
  SessionManager._();
  static final instance = SessionManager._();

  static const _keySesId = 'sesid';
  static const _keyAdrId = 'adrid';

  /// Persist both the session-id and the user’s adrId
  Future<void> saveSession({
    required String sesid,
    required String adrId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySesId, sesid);
    await prefs.setString(_keyAdrId, adrId);
  }



  ///  ——————————————————————————————
  /// Returns a valid sesid, logging in if needed.
  Future<String> getSesId({
    required String username,
    required String password,
  }) async {
    final session = await _readSession();
    final storedSesId = session[_keySesId];
    final storedAdrId = session[_keyAdrId];

    // Wenn beides da ist, direkt zurückgeben
    if (storedSesId != null && storedAdrId != null) {
      return storedSesId;
    }

    // Ansonsten Login und adrId-Fallback
    final loginResult = await ApiService.login(
      username: username,
      password: password,
    );

    final sesid = loginResult.sesid;
    final adrId = loginResult.adrId?.isNotEmpty == true
        ? loginResult.adrId!
        : await ApiService.fetchAdrId(sesid: sesid);

    await _saveSession(sesid: sesid, adrId: adrId);
    return sesid;
  }

  Future<void> saveAdrId(String adrId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdrId, adrId);
  }

// gespeicherte adrId lesen
  Future<String?> get storedAdrId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdrId);
  }

  Future<bool> get isLoggedIn async {
    final sesid   = await storedSesId;
    final username = await storedUsername;
    return sesid != null &&
        sesid.isNotEmpty &&
        username != null &&
        username.isNotEmpty;
  }


// gespeicherte sesId lesen (bestehend)
  Future<String?> get storedSesId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySesId);
  }

  Future<String?> get storedUsername async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }



  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesId);
    await prefs.remove(_keyAdrId);
    await prefs.remove('username');
  }


// Liest sesid und adrId gemeinsam aus
  Future<Map<String, String?>> _readSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _keySesId: prefs.getString(_keySesId),
      _keyAdrId: prefs.getString(_keyAdrId),
    };
  }

// Speichert sesid und adrId
  Future<void> _saveSession({ required String sesid, required String adrId }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySesId, sesid);
    await prefs.setString(_keyAdrId, adrId);
  }

  Future<void> setSession({
    required String sesId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
      ..setString('sesid', sesId)
      ..setString('username', username);
  }




  /// ——————————————————————————————
  /// Anonymous “login” via device-ID
  Future<String> getAnonymousSesId() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keySesId);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    // 1) get the device ID
    final deviceId = await ApiService.getDeviceId();

    // 2) store it as the session-ID
    //    (you won’t have a real adrId for anon users)
    await prefs.setString(_keySesId, deviceId);

    return deviceId;
  }
}