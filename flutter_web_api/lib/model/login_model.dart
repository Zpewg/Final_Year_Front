class Login{
  final String mail;
  final String password;

  const Login({
    required this.mail,
    required this.password,
  });

  factory Login.fromJson(Map<String, dynamic> json){
    return Login(
      mail: json['mail'] as String,
      password: json['password'] as String,
      );
  }

  Map<String, dynamic> toJson() => {
    'mail': mail,
    'password': password,
  };

}