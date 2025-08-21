import 'package:flutter/foundation.dart';
import 'service_handler.dart';
import '../models/comment_model.dart'; // dein Dart-Model mit toFormData()

class CommentApi {
  final ServiceHandler _service = ServiceHandler();

  Future<void> sendComment(Comment comment) async {
    const endpoint =
        'https://www.tierregistrierung.de/index.php?module=EZComments&func=create';

    // 1:1-Param-Mapping anhand deiner Java-Parameter
    final params = <String, String>{
      'authid': comment.authId, // falls du das im Modell hinterlegst
      'EZComments_redirect': comment.redirectUrl,
      'EZComments_modname': 'if_tiere',
      'EZComments_objectid': comment.objectId,
      ...comment.toFormData(),  // z. B. transponder, telefon_finder, kommentar, status etc.
    };

    try {
      final result =
      await _service.makeServiceCall(endpoint, ServiceHandler.POST, params);
      debugPrint('✅ Kommentar erfolgreich: $result');
    } catch (e) {
      debugPrint('❌ Fehler beim Senden des Kommentars: $e');
      rethrow;
    }
  }
}