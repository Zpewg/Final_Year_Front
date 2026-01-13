import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_task_model.dart';

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
      // Build URL with Query Parameter: .../api/UserTasks/get?userId=1
      final uri = Uri.parse("$baseUrl/get?userId=$userId");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // 1. Decode the raw JSON string into a List<dynamic>
        final List<dynamic> body = jsonDecode(response.body);

        // 2. Map each item in the list to a UserTasks object
        final List<UserTasks> tasks = body
            .map((dynamic item) => UserTasks.fromJson(item))
            .toList();

        return tasks;
      } else {
        print("❌ Error fetching tasks: ${response.statusCode}");
        return []; // Return empty list on failure
      }
    } catch (e) {
      print("🚨 Exception fetching tasks: $e");
      return []; // Return empty list on exception
    }
  }
}