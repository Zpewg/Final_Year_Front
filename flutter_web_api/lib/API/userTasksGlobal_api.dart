import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_task_global_model.dart'; 
import '../model/model.dart';
import '../model/global_task_request_model.dart'; // Numele fișierului unde ai modelul UserTasksGlobal

class UserTasksGlobalService {
  final String baseUrl = "http://localhost:7152/api/UserTasksGlobal";

// ✅ Am adăugat parametrul "User user"
Future<List<String>> createUserTaskGlobal(UserTasksGlobal taskToSave, User user) async {
  final requestDto = GlobalTaskRequestDto(task: taskToSave, user: user);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestDto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final decoded = jsonDecode(response.body);
      List<String> errorsList = [];

      // Extragem erorile indiferent de formatul returnat de .NET (Listă sau Map)
      if (decoded is List) {
        errorsList = List<String>.from(decoded);
      } else if (decoded is Map<String, dynamic>) {
        final errorsData = decoded['errors'];
        
        if (errorsData is List) {
          errorsList = List<String>.from(errorsData);
        } else if (errorsData is Map) {
          for (var value in errorsData.values) {
            if (value is List) {
              errorsList.addAll(List<String>.from(value));
            }
          }
        }
      }

      if (errorsList.isNotEmpty) {
        print('⚠️ Erori returnate de API: $errorsList');
      }
      
      return errorsList;
    } else {
      print('❌ Eroare HTTP. Status code: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to create task');
    }
  } catch (e) {
    print('🚨 Excepție la apelul API (ex: problemă de rețea): $e');
    throw Exception('Failed to create task: $e');
  }
}

Future<List<UserTasksGlobal>> getGlobalTasksByUserId(User user) async {
  try {
    final uri = Uri.parse("$baseUrl/getGlobalTasksById");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204){
      print("📦 RAW JSON: ${response.body}");
      if(response.body.isEmpty) return [];

      final dynamic decoded = jsonDecode(response.body);

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
  } catch(e, stacktrace) {
       print("🚨 EROARE PARSARE: $e"); // 2. Vezi exact de ce a crăpat fromJson
       print("STACKTRACE: $stacktrace");
      return [];
  }
}

  // Aici presupun că trimiți doar Km în query (ID-ul sau Point-ul depinde de implementarea ta exactă de pe backend. 
  // Din controller-ul tău C# văd că ai "User user" ca parametru la Get, ceea ce de obicei înseamnă un [FromBody] la POST, nu GET. 
  // Dar dacă ai schimbat să folosească direct din DB baza pe un parametru, va arăta cam așa:
Future<List<UserTasksGlobal>> getGlobalTasksByKm(User user) async {
    try {
      // Punem km în URL, iar obiectul User va fi în body
      final uri = Uri.parse("$baseUrl/get");
      
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

  Future<bool> deleteUserTaskGlobal(UserTasksGlobal taskToDelete) async {
    try {
      final uri = Uri.parse("$baseUrl/delete");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(taskToDelete.toJson()),
      );

      if (response.statusCode == 200) {
        print("✅ Task șters cu succes: ${response.body}");
        return true;
      } else {
        print("❌ Eroare la ștergerea task-ului: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("🚨 Excepție la ștergere: $e");
      return false;
    }
  }

  Future<List<String>> updateUserTaskGlobal(UserTasksGlobal taskToUpdate) async {
    try {
      final uri = Uri.parse("$baseUrl/update");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(taskToUpdate.toJson()),
      );

      if (response.statusCode == 200) {
        print("✅ Task actualizat: ${response.body}");
        return []; // [] înseamnă succes, nicio eroare
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<String>.from(decoded);
        }
        return ["A apărut o eroare de validare."];
      } else {
        return ["Eroare server: ${response.statusCode}"];
      }
    } catch (e) {
      print("🚨 Excepție la update: $e");
      return ["Excepție: $e"];
    }
  }


}