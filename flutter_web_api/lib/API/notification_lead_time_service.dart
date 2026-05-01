import 'dart:convert';
import 'package:http/http.dart' as http;
// Asigură-te că ruta către model este corectă
import '../model/notification_lead_time_model.dart'; 

class NotificationLeadTimeService {
  final String baseUrl = "http://localhost:7152/api/NotificationLeadTime";

  Future<String?> addNotificationLeadTime(NotificationLeadTime leadTime) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/insert"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(leadTime.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return null; // Succes, nicio eroare
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
        return response.body.isNotEmpty ? response.body : "Failed to insert notification lead time.";
      }
    } catch (e) {
      print("Exception: $e");
      return "Exception occurred: $e";
    }
  }

  Future<String?> updateNotificationLeadTime(NotificationLeadTime leadTime) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(leadTime.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return null; // Succes, nicio eroare
      } else {
        print("Error updating: ${response.statusCode}, ${response.body}");
        return response.body.isNotEmpty ? response.body : "Failed to update notification lead time.";
      }
    } catch (e) {
      print("Exception updating: $e");
      return "Exception occurred: $e";
    }
  }

  Future<bool> deleteNotificationLeadTime(NotificationLeadTime leadTime) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(leadTime.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return true; 
      } else {
        print("Error deleting: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception deleting: $e");
      return false;
    }
  }

  Future<List<NotificationLeadTime>> getNotificationLeadTime(int userId) async {
    try {
      final uri = Uri.parse("$baseUrl/get?userId=$userId");
      final response = await http.get(uri);

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (response.body.isEmpty) return [];

        final dynamic decoded = jsonDecode(response.body);

        // Tratăm cazul standard și cazul în care C# returnează $values (ReferenceHandler.Preserve)
        if (decoded is Map && decoded.containsKey('\$values')) {
          final List<dynamic> body = decoded['\$values'];
          return body.map((item) => NotificationLeadTime.fromJson(item)).toList();
        } else if (decoded is List) {
          return decoded.map((item) => NotificationLeadTime.fromJson(item)).toList();
        }
        return [];
      } else {
        print("Error fetching lead times: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception fetching lead times: $e");
      return [];
    }
  }
}