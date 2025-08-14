// lib/models/transponder_match.dart

class TransponderMatch {
  final String? tiername;
  final String? telefonPriv;
  final String? haltername;
  final String? transponder;
  final String? rasse;
  final String? farbe;
  final String? geburt;

  TransponderMatch({
    this.tiername,
    this.telefonPriv,
    this.haltername,
    this.transponder,
    this.rasse,
    this.farbe,
    this.geburt,
  });

  factory TransponderMatch.fromJson(Map<String, dynamic> json) {
    return TransponderMatch(
      tiername:     json['tiername']      as String?,
      telefonPriv:  json['telefon_priv']  as String?,
      haltername:   json['haltername']    as String?,
      transponder:  json['transponder']   as String?,
      rasse:        json['rasse']         as String?,
      farbe:        json['farbe']         as String?,
      geburt:       json['geburt']        as String?,
    );
  }
}