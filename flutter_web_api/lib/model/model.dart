class User {
  final int id;
  final String email;
  final String name;
  final String password;
  final String phoneNumber;
  final bool active;
  final Map<String, dynamic>? location;
  final int? km; // ✅ Adăugat pentru coordonate (GeoJSON)

  const User({
    this.id = 0,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.active,
    this.location,
    this.km, // ✅ Adăugat aici
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? json['userId']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      active: json['active'] == true || json['active'] == 'true',
      location: json['location'] ?? json['Location'], // ✅ Mapăm locația din JSON
    );
  }

  Map<String, dynamic> toJson() => {
        "UserId": id,
        "Email": email,
        "Name": name,
        "Password": password,
        "PhoneNumber": phoneNumber,
        "Active": active,
        "Location": location,
        "Km": km, // ✅ Trimitem locația înapoi dacă e nevoie
      };
}