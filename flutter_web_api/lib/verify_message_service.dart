import 'dart:convert';
import 'package:flutter_web_api/verification_model.dart';
import 'package:http/http.dart' as http;


class VerifyService{
  final String baseUrl = "https://localhost:7152/api/VerifyMessage";

  Future <void> registerMessage(VerifyMessage message) async {
    try{
      await Future.sync(() async  {
        final response = await http.post(
          Uri.parse("$baseUrl/register"),

          headers: {"Content-Type": "application/json"},
          body: jsonEncode(message.toJson()),
        );

        if(response.statusCode >= 200 && response.statusCode <= 299){
          print ("Success: ${response.body}");
          
        }
        else {
          print ("Error : ${response.statusCode}, ${response.body}");
        }
      });
    }
    catch(e){
      print("Exception: $e");
    }
  }
}