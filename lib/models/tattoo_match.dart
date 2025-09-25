class TattooMatch {
  final String id;
  final String tiername;
  final String transponder;
  final String tierart;
  final String rasse;
  final String farbe;
  final String geburt;
  final String geschlecht;
  final String tierAenderung;
  final String email;
  final String telefonPriv;
  final String telefonGes;
  final String telefonMobil;
  final String haltername;
  final String adresse1;
  final String adresse2;
  final String adresse;
  final String strasse;
  final String plz;
  final String land;
  final String ort;
  final String fax;
  final String halterAenderung;

  TattooMatch({
    required this.id,
    required this.tiername,
    required this.transponder,
    required this.tierart,
    required this.rasse,
    required this.farbe,
    required this.geburt,
    required this.geschlecht,
    required this.tierAenderung,
    required this.email,
    required this.telefonPriv,
    required this.telefonGes,
    required this.telefonMobil,
    required this.haltername,
    required this.adresse1,
    required this.adresse2,
    required this.adresse,
    required this.strasse,
    required this.plz,
    required this.land,
    required this.ort,
    required this.fax,
    required this.halterAenderung,
  });

  factory TattooMatch.fromJson(Map<String, dynamic> json) {
    String safe(dynamic x) => x == null ? '' : x.toString();

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
      id:               safe(json['id']),
      tiername:         safe(json['tiername']),
      transponder:      safe(json['transponder']),
      tierart:          safe(json['tierart']),
      rasse:            safe(json['rasse']),
      farbe:            safe(json['farbe']),
      geburt:           safe(json['geburt']),
      geschlecht:       safe(json['geschlecht']),
      tierAenderung:    safe(json['tier_aenderung']),
      email:            safe(json['email']),
      telefonPriv:      safe(json['telefon_priv']),
      telefonGes:       safe(json['telefon_ges']),
      telefonMobil:     safe(json['telefon_mobil']),
      haltername:       safe(json['haltername']),
      adresse1:         safe(json['adresse1']),
      adresse2:         safe(json['adresse2']),
      adresse:          safe(json['adresse']),
      strasse:          safe(json['strasse']),
      plz:              safe(json['plz']),
      land:             safe(json['land']),
      ort:              safe(json['ort']),
      fax:              safe(json['fax']),
      halterAenderung:  safe(json['halter_aenderung']),
    );
  }
}