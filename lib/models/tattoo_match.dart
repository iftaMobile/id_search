// lib/models/tattoo_match.dart

class TattooMatch {
  final String? id;
  final String? name;
  final String? tierart;
  final String? rasse;
  final String? farbe;
  final String? geburt;
  final String? plz;
  final String? ort;
  final String? strasse;
  final String? owner;
  final String? telefonPriv;

  TattooMatch({
    this.id,
    this.name,
    this.tierart,
    this.rasse,
    this.farbe,
    this.geburt,
    this.plz,
    this.ort,
    this.strasse,
    this.owner,
    this.telefonPriv,
  });

  factory TattooMatch.fromJson(Map<String, dynamic> json) {
    // strip HTML tags if necessary
    String _strip(String? html) =>
        html?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '';

    return TattooMatch(
      id:      json['id']       as String?,
      name:    _strip(json['tatol'] as String?),   // or another field
      tierart: json['tierart']  as String?,
      rasse:   json['rasse']    as String?,
      farbe:   json['farbe']    as String?,
      geburt:  json['geburt']   as String?,
      plz:     json['plz']      as String?,
      ort:     json['ort']      as String?,
      strasse: json['strasse']  as String?,
      owner:   json['owner']    as String?,
      telefonPriv:  json['telefon_priv']  as String?,
    );
  }
}