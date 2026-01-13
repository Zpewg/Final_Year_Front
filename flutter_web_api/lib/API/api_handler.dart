import 'dart:convert';

import 'package:flutter_web_api/model.dart';
import 'package:http/http.dart'as http;

class ApiHandler{
  final String baseUri = "https://localhost:7152/api/User";
  
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
  

}