// lib/models/tattoo_match.dart

class TattooMatch {
  final String? dbid;
  final String? qid;
  final String? tattoo;
  final String? haltername;
  final String? tiername;
  final String? transponder;
  final String? telefonPriv;
  final String? rasse;
  final String? farbe;
  final String? geburt;
  // falls du noch weitere Felder brauchst: hier ergänzen

  TattooMatch({
    this.dbid,
    this.qid,
    this.tattoo,
    this.haltername,
    this.tiername,
    this.transponder,
    this.telefonPriv,
    this.rasse,
    this.farbe,
    this.geburt,
  });

  factory TattooMatch.fromJson(Map<String, dynamic> json) {
    return TattooMatch(
      dbid:         json['dbid'] as String?,
      qid:          json['qid'] as String?,
      tattoo:       json['tattoo'] as String?,
      haltername:   json['haltername'] as String?,
      tiername:     json['tiername'] as String?,
      transponder:  json['transponder'] as String?,
      telefonPriv:  json['telefon_priv'] as String?,  // check JSON-Key!
      rasse:        json['rasse'] as String?,
      farbe:        json['farbe'] as String?,
      geburt:       json['geburt'] as String?,
    );
  }
}
