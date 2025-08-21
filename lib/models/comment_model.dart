class Comment {
  final String authId;
  final String redirectUrl;
  final String objectId;
  final String transponder;
  final String telefonFinder;
  final String telefonFinder2;
  final String telefonPriv;
  final String telefonMobil;
  final String telefonGes;
  final String kommentar;
  final String status;
  // … ggf. weitere Felder …

  Comment({
    required this.authId,
    required this.redirectUrl,
    required this.objectId,
    required this.transponder,
    required this.telefonFinder,
    required this.telefonFinder2,
    required this.telefonPriv,
    required this.telefonMobil,
    required this.telefonGes,
    required this.kommentar,
    required this.status,
    // …
  });

  /// Mappt alle Felder auf Form-Daten für den POST-Body
  Map<String, String> toFormData() {
    return {
      'transponder': transponder,
      'telefon_finder': telefonFinder,
      'telefon_finder2': telefonFinder2,
      'telefon_priv': telefonPriv,
      'telefon_mobil': telefonMobil,
      'telefon_ges': telefonGes,
      'kommentar': kommentar,
      'status': status,
      // … restliche Felder analog …
    };
  }
}