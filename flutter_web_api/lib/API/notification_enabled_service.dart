import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/notification_enabled_model.dart';

class NotificationEnabledService {
  final String baseUrl = "http://localhost:7152/api/NotificationEnabled";

  Future<String?> enableNotification(NotificationEnabled notification) async {
    return _sendPostRequest("$baseUrl/enable", notification);
  }

  Future<String?> disableNotification(NotificationEnabled notification) async {
    return _sendPostRequest("$baseUrl/disable", notification);
  }

  // Metodă refolosibilă pentru a nu repeta codul
  Future<String?> _sendPostRequest(String url, NotificationEnabled notification) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(notification.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return null; // Succes
      } else {
        return response.body.isNotEmpty ? response.body : "Eroare: ${response.statusCode}";
      }
    } catch (e) {
      return "Excepție: $e";
    }
  }

  Future<List<NotificationEnabled>> getNotificationEnabled(int userId) async {
    try {
      final response = await http.post(Uri.parse("$baseUrl/get?userId=$userId"));
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        if (response.body.isEmpty) return [];
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('\$values')) {
          return (decoded['\$values'] as List).map((i) => NotificationEnabled.fromJson(i)).toList();
        } else if (decoded is List) {
          return decoded.map((i) => NotificationEnabled.fromJson(i)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}