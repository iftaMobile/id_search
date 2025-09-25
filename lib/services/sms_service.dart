import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsService {
  /// Sendet den Verifizierungscode per SMS über dein Backend
  static Future<void> sendCode({
    required String phone,
    required String code,
  }) async {
    final uri = Uri.parse('https://dein-backend-url/send-sms');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );

    if (response.statusCode != 200) {
      // Du kannst hier das Response-JSON auswerten und eine eigene Exception werfen
      throw Exception('SMS konnte nicht gesendet werden (${response.statusCode})');
    }
  }
}