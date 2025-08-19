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

  /// Returns stored sesid or null
  Future<String?> get storedSesId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySesId);
  }

  /// Returns stored adrId or null
  Future<String?> get storedAdrId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdrId);
  }

  /// Clears both sesid and adrId (logout)
  Future<void> clearSesId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesId);
    await prefs.remove(_keyAdrId);
  }

  ///  ——————————————————————————————
  /// Returns a valid sesid, logging in if needed.
  Future<String> getSesId({
    required String username,
    required String password,
  }) async {
    // 1) if we already have one, return it
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keySesId);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    // 2) otherwise perform the login call
    final loginResult = await ApiService.login(
      username: username,
      password: password,
    );

    // 3) figure out the adrId
    String adrId;
    if (loginResult.adrId != null && loginResult.adrId!.isNotEmpty) {
      adrId = loginResult.adrId!;
    } else {
      // fallback: call your profile endpoint to discover the adr_id
      adrId = await ApiService.fetchAdrId(sesid: loginResult.sesid);
    }

    // 4) persist both
    await saveSession(
      sesid: loginResult.sesid,
      adrId: adrId,
    );

    // 5) return the new sesid
    return loginResult.sesid;
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