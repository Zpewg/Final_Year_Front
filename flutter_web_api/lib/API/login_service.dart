import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_model.dart';
import 'model.dart';

class LoginService {
  final String baseUrl = "https://localhost:7152/api/LogIn";

  Future<User?> logInUser(Login login) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(login.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return User.fromJson(json['data']); 
    } else {
      return null; 
    }
  }
}