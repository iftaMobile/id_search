// lib/services/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:id_search/services/api_service.dart';

class SessionManager {
  SessionManager._();
  static final instance = SessionManager._();

  static const _keySesId = 'sesid';

  /// Liefert die lokal gespeicherte Session-ID oder holt sie per Login nach
  Future<String> getSesId({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keySesId);
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    // Wenn noch keine sesid gespeichert ist, Login durchführen
    final newSesid = await ApiService.login(
      username: username,
      password: password,
    );

    // sesid speichern und zurückgeben
    await prefs.setString(_keySesId, newSesid);
    return newSesid;
  }

  /// Optional: Session-ID löschen (z. B. beim Logout)
  Future<void> clearSesId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesId);
  }
}