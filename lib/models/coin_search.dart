// lib/models/coin_search.dart

class CoinSearch {
  final String tiername;
  final String transponder;
  final String tierart;
  final String rasse;
  final String farbe;
  final String geburt;
  final String geschlecht;
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

  CoinSearch({
    required this.tiername,
    required this.transponder,
    required this.tierart,
    required this.rasse,
    required this.farbe,
    required this.geburt,
    required this.geschlecht,
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

  factory CoinSearch.fromJson(Map<String, dynamic> json) {
    return CoinSearch(
      tiername:        json['tiername']           as String,
      transponder:     json['transponder']        as String,
      tierart:         json['tierart']            as String,
      rasse:           json['rasse']              as String,
      farbe:           json['farbe']              as String,
      geburt:          json['geburt']             as String,
      geschlecht:      json['geschlecht']         as String,
      email:           json['email']              as String,
      telefonPriv:     json['telefon_priv']       as String,
      telefonGes:      json['telefon_ges']        as String,
      telefonMobil:    json['telefon_mobil']      as String,
      haltername:      json['Haltername']         as String,
      adresse1:        json['adresse1']           as String,
      adresse2:        json['adresse2']           as String,
      adresse:         json['adresse']            as String,
      strasse:         json['strasse']            as String,
      plz:             json['plz']                as String,
      land:            json['land']               as String,
      ort:             json['ort']                as String,
      fax:             json['fax']                as String,
      halterAenderung: json['halter_aenderung']   as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tiername':           tiername,
      'transponder':        transponder,
      'tierart':            tierart,
      'rasse':              rasse,
      'farbe':              farbe,
      'geburt':             geburt,
      'geschlecht':         geschlecht,
      'email':              email,
      'telefon_priv':       telefonPriv,
      'telefon_ges':        telefonGes,
      'telefon_mobil':      telefonMobil,
      'Haltername':         haltername,
      'adresse1':           adresse1,
      'adresse2':           adresse2,
      'adresse':            adresse,
      'strasse':            strasse,
      'plz':                plz,
      'land':               land,
      'ort':                ort,
      'fax':                fax,
      'halter_aenderung':   halterAenderung,
    };
  }
}