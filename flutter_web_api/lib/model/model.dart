

class User{
  
  final int id;

  final String email;

  final String name;

  final String password;

  final String phoneNumber;

  final bool active;

 

  const User({
    this.id =0,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.active,
  
  });


factory User.fromJson(Map<String, dynamic> json) {
  // 1. Print the raw JSON to your console so you can see exactly what the API sends
  print("DEBUG RAW API JSON: $json"); 

  return User(
    // 2. Safely check all variations and handle both Ints and Strings
    id: int.tryParse(json['id']?.toString() ?? 
                     json['Id']?.toString() ?? 
                     json['userId']?.toString() ?? 
                     json['UserId']?.toString() ?? 
                     '0') ?? 0,
                     
    email: json['email']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    password: json['password']?.toString() ?? '',
    phoneNumber: json['phoneNumber']?.toString() ?? '',
    active: json['active'] == true || json['active'] == 'true',
  );
}


Map<String, dynamic> toJson() => {
  "UserDTOEmail": email,       
  "UserDTOName": name,
  "UserDTOPassword": password,
  "UserDTOPhoneNumber": phoneNumber,
};

}