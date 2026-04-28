import 'dart:convert';
import 'package:flutter_web_api/model/userDTO_model.dart';
import 'package:http/http.dart' as http;


class UserService {
  final String baseUrl = "http://localhost:7152/api/UserDTO";

  Future<List<String>> registerUser(UserDTO user) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        // ✅ Success: no errors
        return [];
      } else {
        print("❌ Error: ${response.statusCode}, ${response.body}");
        

        // Decode as list of errors
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("🚨 Exception: $e");
      return ["Exception occurred: $e"];
    }
  }
}
