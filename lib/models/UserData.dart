// lib/models/user_model.dart

class User {
  final String adrId;
  final String name;
  final String street;
  final String zip;
  final String city;
  final String email;

  User({
    required this.adrId,
    required this.name,
    required this.street,
    required this.zip,
    required this.city,
    required this.email,
  });

  /// existing JSON if you ever get ADRESSE_INFO
  factory User.fromJson(Map<String, dynamic> json) {
    final info = json['ADRESSE_INFO'] as Map<String, dynamic>? ?? {};
    return User(
      adrId: info['adr_id']?.toString() ?? '',
      name: '${info['vorname'] ?? ''} ${info['nachname'] ?? ''}',
      street: info['strasse']    as String? ?? '',
      zip:    info['plz']        as String? ?? '',
      city:   info['ort']        as String? ?? '',
      email:  info['email']      as String? ?? '',
    );
  }

  /// new: map the flat IFTA_MATCH entry
  factory User.fromMatchJson(Map<String, dynamic> match) {
    return User(
      adrId:  match['adr_id']?.toString() ?? '',
      name:   match['haltername']    as String? ?? '',
      street: match['strasse']       as String? ?? '',
      zip:    match['plz']           as String? ?? '',
      city:   match['ort']           as String? ?? '',
      email:  match['email']         as String? ?? '',
    );
  }
}