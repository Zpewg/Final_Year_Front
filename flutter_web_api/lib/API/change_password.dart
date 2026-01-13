import 'dart:convert';
import 'package:flutter_web_api/model/verification_model.dart';
import 'package:http/http.dart' as http;
import '../model/new_password_from_user_model.dart'; 

class ChangePasswordService {
  final String baseUrl = "https://localhost:7152/api/ChangePassword";

  // Step 1: Check Email
  Future<bool> checkMailExist(String mail) async {
    try {
      return await Future.sync(() async {
        final response = await http.post(
          Uri.parse("$baseUrl/CheckMailExist"),
          headers: {"Content-Type": "application/json"},
          // Sending a simple string in body requires jsonEncode to add quotes
          body: jsonEncode(mail), 
        );

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          print("Success CheckMail: ${response.body}");
          return true;
        } else {
          print("Error CheckMail: ${response.statusCode}, ${response.body}");
          return false;
        }
      });
    } catch (e) {
      print("Exception CheckMail: $e");
      return false;
    }
  }

  // Step 2: Check Code
  Future<bool> checkCodeExist(VerifyMessage codeMessage) async {
    try {
      return await Future.sync(() async {
        final response = await http.post(
          Uri.parse("$baseUrl/CheckCodeExist"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(codeMessage.toJson()),
        );

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          print("Success CheckCode: ${response.body}");
          return true;
        } else {
          print("Error CheckCode: ${response.statusCode}, ${response.body}");
          return false;
        }
      });
    } catch (e) {
      print("Exception CheckCode: $e");
      return false;
    }
  }

  // Step 3: Change Password
  Future<bool> changePassword(NewPasswordFromUser passwordMessage) async {
    try {
      return await Future.sync(() async {
        final response = await http.post(
          Uri.parse("$baseUrl/ChangePassword"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(passwordMessage.toJson()),
        );

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          print("Success ChangePassword: ${response.body}");
          return true;
        } else {
          print("Error ChangePassword: ${response.statusCode}, ${response.body}");
          return false;
        }
      });
    } catch (e) {
      print("Exception ChangePassword: $e");
      return false;
    }
  }
}