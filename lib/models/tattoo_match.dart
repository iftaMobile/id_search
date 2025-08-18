class TattooMatch {
  final String? tiername;
  final String? telefonPriv;
  final String? haltername;
  final String? transponder;
  final String? tierart;
  final String? rasse;
  final String? farbe;
  final String? geburt;
  final String? plz;
  final String? ort;
  final String? strasse;

  TattooMatch({
    this.tiername,
    this.telefonPriv,
    this.haltername,
    this.transponder,
    this.tierart,
    this.rasse,
    this.farbe,
    this.geburt,
    this.plz,
    this.ort,
    this.strasse,
  });

  factory TattooMatch.fromJson(Map<String, dynamic> json) {
    // helper to remove <…> tags
    String _stripHtml(String? html) =>
        html?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '';

    // combine left + right codes
    final left  = _stripHtml(json['tatol']  as String?);
    final right = _stripHtml(json['tator'] as String?);
    final combined = [left, right]
        .where((s) => s.isNotEmpty)
        .join('/');

    return TattooMatch(
      tiername:    json['tiername']      as String?,
      telefonPriv: json['telefon_priv']  as String?,
      haltername:  json['owner']         as String?,
      transponder: combined.isNotEmpty ? combined : null,
      tierart:     json['tierart']       as String?,
      rasse:       json['rasse']         as String?,
      farbe:       json['farbe']         as String?,
      geburt:      json['geburt']        as String?,
      plz:         json['plz']           as String?,
      ort:         json['ort']           as String?,
      strasse:     json['strasse']       as String?,
    );
  }
}