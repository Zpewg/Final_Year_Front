import 'dart:convert';

import 'package:flutter_web_api/model/model.dart';
import 'package:http/http.dart'as http;
import '../services/location_service_selector.dart';

class ApiHandler{
  final String baseUri = "http://localhost:7152/api/User";
  
  Future<List<User>> getUserData() async{
    List<User> data = [];

    final uri = Uri.parse(baseUri);
    try{

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type' : 'application/json; charset=UTF-8' 
        },
      );
      if(response.statusCode >= 200 && response.statusCode <= 299){
        final List<dynamic> jsonData = json.decode(response.body);
        data = jsonData.map((json) => User.fromJson(json)).toList();

      }
    }catch(e){
       print("Error fetching users: $e");
      return data;
    }
    return data;
  }
    Future<void> registerUser(User user) async {
    final response = await http.post(
      Uri.parse("$baseUri/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      print("Success: ${response.body}");
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
    }
  }
Future<bool> updateLocation(int userId, int km) async {
  try {
    final locationService = getLocationService();
    final coords = await locationService.getCurrentLocation();

    if (coords == null) return false;

    final uri = Uri.parse("$baseUri/location");

    final body = {
      "userId": userId,
      "latitude": coords["lat"],
      "longitude": coords["lng"],
      "km": km,
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (e) {
    print("🚨 Eroare prinsă la updateLocation: $e");
    return false; // Previne crash-ul
  }
}
}