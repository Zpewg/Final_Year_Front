import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

class UserService {
  final String baseUrl = "https://localhost:7152/api/User";

  /// Sends user registration data as JSON and returns server response.
Future<void> registerUser(User user) async {
  try {
    await Future.sync(() async {
      print("It blocked before parse");
      final response = await http.post(
        
        Uri.parse("$baseUrl/register"),
        
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );
      print("It blocked after parse");
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        print("✅ Success: ${response.body}");
      } else {
        print("❌ Error: ${response.statusCode}, ${response.body}");
      }
    });
  } catch (e) {
    print("🚨 Exception: $e");
  }
}
}
