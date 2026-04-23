import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_task_model.dart';
import 'package:flutter/foundation.dart'; // Pentru debugPrint
class UserTasksService {
  final String baseUrl = "https://localhost:7152/api/UserTasks";

  Future<List<String>> createUserTask(UserTasks UserTasks) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(UserTasks.toJson()),
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
Future<List<UserTasks>> getUserTasks(int userId) async {
    try {
      final uri = Uri.parse("$baseUrl/get?userId=$userId");
      debugPrint("🚀 TRIMIT REQUEST CATRE: $uri"); // Trebuie să apară!

      final response = await http.get(uri);
      
      debugPrint("📦 STATUS CODE PRIMIT: ${response.statusCode}");
      debugPrint("📦 BODY PRIMIT: ${response.body}"); // Asta ne arată exact ce trimite C#

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) return [];

        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map) {
          if (decoded.containsKey('\$values')) {
            final List<dynamic> body = decoded['\$values'];
            return body.map((item) => UserTasks.fromJson(item)).toList();
          }
          if (decoded.containsKey('data')) {
            final List<dynamic> body = decoded['data'];
            return body.map((item) => UserTasks.fromJson(item)).toList();
          }
          // Dacă e un Map dubios (ex o eroare formatată JSON), forțăm afișarea în consolă
          debugPrint("⚠️ JSON NECUNOSCUT (MAP): $decoded");
          return [];
        }

        if (decoded is List) {
          return decoded.map((item) => UserTasks.fromJson(item)).toList();
        }

        return [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("🚨 EROARE FATALĂ IN GET TASKS: $e");
      // Aruncăm eroarea mai departe ca să o vedem clar în UI
      throw Exception("Eroare la citirea task-urilor: $e");
    }
  }
  Future<bool> deleteUserTask(UserTasks task) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return true; // ✅ Success
      } else {
        print("❌ Error deleting task: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🚨 Exception deleting task: $e");
      return false;
    }
  }

  Future<bool> updateUserTask(UserTasks task) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return true; // ✅ Succes
      } else {
        print("❌ Error updating task: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("🚨 Exception updating task: $e");
      return false;
    }
  }
}