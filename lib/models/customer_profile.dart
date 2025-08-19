class CustomerProfile {
  final String name;
  final String street;
  final String city;
  final String phone;
  final String email;

  CustomerProfile({
    required this.name,
    required this.street,
    required this.city,
    required this.phone,
    required this.email,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      name:  json['name']  as String? ?? '',
      street: json['street'] as String? ?? '',
      city:  json['city']  as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}