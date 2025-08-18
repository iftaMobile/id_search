class UserData {
  final String adrId;
  final String name;
  final String email;
  final String phone;
  final String address;

  UserData({
    required this.adrId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      adrId: json['adr_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }
}