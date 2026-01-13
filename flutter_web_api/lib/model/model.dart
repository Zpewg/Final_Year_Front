

class User{
  

  final String email;

  final String name;

  final String password;

  final String phoneNumber;

  final bool active;

 

  const User({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.active,
  
  });


factory User.fromJson(Map<String, dynamic> json) {
  return User(
    email: json['email'] as String,
    name: json['name'] as String,
    password: json['password'] as String,
    phoneNumber: json['phoneNumber'] as String,
    active: json['active'] as bool,
  
  );
}


Map<String, dynamic> toJson() => {
  "UserDTOEmail": email,       
  "UserDTOName": name,
  "UserDTOPassword": password,
  "UserDTOPhoneNumber": phoneNumber,
};

}