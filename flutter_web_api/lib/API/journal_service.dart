import 'dart:convert';

import 'package:http/http.dart' as http;
import '../model/journal_model.dart';

class JournalService {
  final String baseUrl = "https://localhost:7152/api/WriteInJournal";

  Future<List<String>> addJournal( Journal journal) async {
    try{
      final response = await http.post(
        Uri.parse("$baseUrl/createJournal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(journal.toJson()),
      );

      if(response.statusCode >= 200 && response.statusCode <=299){
        return [];
      }else{
        print("Error: ${response.statusCode}, ${response.body}");
      }
         final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => e.toString()).toList();
    } catch (e){
      print ("Exception: $e");
      return ["Exception occured: $e"];
    }
  }

  Future<List<Journal>> getJournals(int userId) async{
    try{
      final uri = Uri.parse("$baseUrl/getJournal?userId=$userId");

      final response = await http.get(uri);

      if(response.statusCode >= 200 && response.statusCode <=299){
        final List<dynamic> body = jsonDecode(response.body);

        final List<Journal> journal = body.map((dynamic item) => Journal.fromJson(item)).toList();
        return journal;
      }else {
        print ("Error fetching journals: ${response.statusCode}");
        return [];
      }
    } catch (e){
      print ("Exception fetching journals: $e");
      return [];
    }
  }

  Future<bool> deleteJournal(Journal journal) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/DeleteJournal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(journal.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return true; // ✅ Succes
      } else {
        print("Error deleting journal: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception deleting journal: $e");
      return false;
    }
  }

  Future<String?> updateJournal(Journal journal) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/updateJournal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(journal.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return null; // ✅ Succes, nicio eroare
      } else {
        print("❌ Error updating journal: ${response.statusCode}, ${response.body}");
        return response.body.isNotEmpty ? response.body : "Failed to update journal.";
      }
    } catch (e) {
      print("🚨 Exception updating journal: $e");
      return "Exception occurred: $e";
    }
  }

}