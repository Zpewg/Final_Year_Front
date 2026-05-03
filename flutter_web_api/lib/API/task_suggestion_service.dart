import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/task_suggestion_model.dart'; // Asigură-te că pui importul corect

class TaskSuggestionService {

  static const String baseUrl = "http://localhost:7152/api/TaskSuggestion";

  /// ENABLE SUGGESTIONS
  Future<String?> enableSuggestion(TaskSuggestion suggestion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enable'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(suggestion.toJson()),
      );

      if (response.statusCode == 200) {
        return response.body; // Returnează mesajul de succes din backend
      } else {
        print("Enable Error: ${response.body}");
        return null; // Returnează null dacă a fost BadRequest ("User not found")
      }
    } catch (e) {
      print("Enable Exception: $e");
      return null;
    }
  }

  /// DISABLE SUGGESTIONS
  Future<String?> disableSuggestion(TaskSuggestion suggestion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/disable'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(suggestion.toJson()),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("Disable Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Disable Exception: $e");
      return null;
    }
  }

  /// GET SUGGESTIONS
  Future<List<TaskSuggestion>> getSuggestions(int userId) async {
    try {
      // Notă: API-ul tău C# folosește [HttpPost("get")] cu userId ca parametru.
      // În ASP.NET, asta înseamnă că așteaptă "userId" în URL (Query String), nu în Body.
      final response = await http.post(
        Uri.parse('$baseUrl/get?userId=$userId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TaskSuggestion.fromJson(json)).toList();
      } else {
        print("Get Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Get Exception: $e");
      return [];
    }
  }
}