// lib/models/tattoo_match.dart

class TattooMatch {
  final String? tiername;
  final String? telefonPriv;
  final String? haltername;
  final String? tattoo;
  final String? rasse;
  final String? farbe;
  final String? geburt;

  TattooMatch({
    this.tiername,
    this.telefonPriv,
    this.haltername,
    this.tattoo,
    this.rasse,
    this.farbe,
    this.geburt,
  });

  factory TattooMatch.fromJson(Map<String, dynamic> json) {
    return TattooMatch(
      tiername:    json['tiername']     as String?,
      telefonPriv: json['telefon_priv'] as String?,
      haltername:  json['haltername']   as String?,
      tattoo:      json['tattoo']       as String?,
      rasse:       json['rasse']        as String?,
      farbe:       json['farbe']        as String?,
      geburt:      json['geburt']       as String?,
    );
  }
}