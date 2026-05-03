import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_task_model.dart';
import 'package:flutter/foundation.dart';

class OptimizationService {
  final String baseUrl = "http://localhost:7152/api/Optimization";

  Future<List<UserTasks>> getOptimizationSuggestions(int userId) async {
    try {
      final uri = Uri.parse("$baseUrl/suggest/$userId");
      debugPrint("🔍 Solicităm sugestii de optimizare pentru user: $userId");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        // Gestionăm formatul JSON cu $values (dacă există) sau Listă simplă
        List<dynamic> data = [];
        if (decoded is Map && decoded.containsKey('\$values')) {
          data = decoded['\$values'];
        } else if (decoded is List) {
          data = decoded;
        }

        return data.map((item) => UserTasks.fromJson(item)).toList();
      } else if (response.statusCode == 204) {
        // 204 No Content înseamnă că programul este deja optimizat
        return [];
      } else {
        debugPrint("❌ Eroare Server Optimizare: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("🚨 Excepție la optimizare: $e");
      return [];
    }
  }
}