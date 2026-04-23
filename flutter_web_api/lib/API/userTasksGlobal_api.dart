import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_task_global_model.dart'; 
import '../model/model.dart'; // Numele fișierului unde ai modelul UserTasksGlobal

class UserTasksGlobalService {
  final String baseUrl = "https://localhost:7152/api/UserTasksGlobal";

// ✅ Am adăugat parametrul "User user"
  Future<List<String>> createUserTaskGlobal(UserTasksGlobal task, User user) async {
    try {
      // ✅ Împachetăm ambele obiecte într-un singur Map
      final requestBody = {
        "Task": task.toJson(),
        "User": user.toJson(),
      };

      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody), // Trimitem pachetul combinat
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return []; // ✅ Success
      } else {
        final dynamic decoded = jsonDecode(response.body);
        
        // ... (Aici rămâne exact logica ta de tratare a erorilor de mai devreme cu "if (decoded is Map)") ...
        
        if (decoded is Map) {
          List<String> extractedErrors = [];
          if (decoded.containsKey('errors')) {
             // ... restul logicii de extragere erori
             return extractedErrors;
          }
          if (decoded.containsKey('title')) return [decoded['title'].toString()];
          return ["Eroare la server (Cod ${response.statusCode})"];
        }
        
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
        return ["Eroare necunoscută la server."];
      }
    } catch (e) {
      print("🚨 Exception: $e");
      return ["Exception occurred: $e"];
    }
  }

  // Aici presupun că trimiți doar Km în query (ID-ul sau Point-ul depinde de implementarea ta exactă de pe backend. 
  // Din controller-ul tău C# văd că ai "User user" ca parametru la Get, ceea ce de obicei înseamnă un [FromBody] la POST, nu GET. 
  // Dar dacă ai schimbat să folosească direct din DB baza pe un parametru, va arăta cam așa:
Future<List<UserTasksGlobal>> getGlobalTasksByKm(User user, int km) async {
    try {
      // Punem km în URL, iar obiectul User va fi în body
      final uri = Uri.parse("$baseUrl/get?km=$km");
      
      // ✅ Folosim POST în loc de GET pentru a putea trimite JSON-ul în body
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) return [];

        final dynamic decoded = jsonDecode(response.body);

        // Tratăm cazul în care C# returnează cu ReferenceHandler.Preserve
        if (decoded is Map && decoded.containsKey('\$values')) {
          final List<dynamic> body = decoded['\$values'];
          return body.map((item) => UserTasksGlobal.fromJson(item)).toList();
        } 
        
        if (decoded is List) {
          return decoded.map((item) => UserTasksGlobal.fromJson(item)).toList();
        }

        return [];
      } else {
        print("❌ Error fetching global tasks: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("🚨 Exception fetching global tasks: $e");
      return [];
    }
  }
}