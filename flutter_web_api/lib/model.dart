class User{
  

  final String email;

  final String name;

  final String password;

  final String phoneNumber;

  const User({
    
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber
  });

factory User.fromJson(Map<String, dynamic> json) {
  return User(
    email: json['mail'] as String,
    name: json['name'] as String,
    password: json['password'] as String,
    phoneNumber: json['phoneNumber'] as String,
  );
}


Map<String, dynamic> toJson() => {
  "Email": email,       
  "name": name,
  "password": password,
  "phoneNumber": phoneNumber,
};

}