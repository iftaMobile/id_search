// lib/models/UserData.dart

/// Helper to convert any JSON value into a String
String _str(dynamic v) => v == null ? '' : v.toString();

class Animal {
  final String name;
  final String transponder;
  final String species;
  final String breed;
  final String gender;
  final String color;
  final String lastChanged;

  Animal({
    required this.name,
    required this.transponder,
    required this.species,
    required this.breed,
    required this.gender,
    required this.color,
    required this.lastChanged,
  });

  factory Animal.fromJson(Map<String, dynamic> m) {
    return Animal(
      name:        _str(m['tiername']),
      transponder:      _str(m['transponder']),
      species:     _str(m['tierart']),
      breed:       _str(m['rasse']),
      gender:      _str(m['geschlecht']),
      color:       _str(m['farbe']),
      lastChanged: _str(m['tier_aenderung']),
    );
  }
}
class User {
  final String adrId;
  final String name;
  final String street;
  final String zip;
  final String city;
  final String country;
  final String email;
  final String telefonPriv;
  final String telefonGes;
  final String telefonMobil;
  final String fax;
  final String lastChanged;
  final String icn;


  /// Animal data
  final Animal animal;

  User({
    required this.adrId,
    required this.name,
    required this.street,
    required this.zip,
    required this.city,
    required this.country,
    required this.email,
    required this.telefonPriv,
    required this.telefonGes,
    required this.telefonMobil,
    required this.fax,
    required this.lastChanged,
    required this.icn,
    required this.animal,
  });

  factory User.fromMatchJson(Map<String, dynamic> m) {
    return User(
      adrId:        _str(m['adr_id']),
      name:         _str(m['haltername']),
      street:       _str(m['strasse']),
      zip:          _str(m['plz']),
      city:         _str(m['ort']),
      country:      _str(m['land']),
      email:        _str(m['email']),
      telefonPriv:  _str(m['telefon_priv']),
      telefonGes:   _str(m['telefon_ges']),
      telefonMobil: _str(m['telefon_mobil']),
      fax:          _str(m['fax']),
      lastChanged:  _str(m['halter_aenderung']),
      icn:          _str(m['reg_id']),
      animal:       Animal.fromJson(m),
    );
  }
}