import 'package:flutter/material.dart'; 

class UserTasks {
  final int userId;
  final String description;
  final DateTime date;       // "DateOnly"
  final TimeOfDay time;      // "TimeOnly"
  final String nameOfTask;

  const UserTasks({
    required this.userId,
    required this.description,
    required this.date,
    required this.time,
    required this.nameOfTask,
  });

  factory UserTasks.fromJson(Map<String, dynamic> json) {
    
    final String rawTime = json['time'] as String; 
    final List<String> timeParts = rawTime.split(':');
    final TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(timeParts[0]), 
      minute: int.parse(timeParts[1])
    );

    return UserTasks(
      userId: json['userId'] as int,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String), 
      time: parsedTime,
      nameOfTask: json['nameOfTask'] as String,
    );
  }

Map<String, dynamic> toJson() {
  // .NET preferă "YYYY-MM-DD" pentru DateOnly
  final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  
  // .NET preferă "HH:mm:ss" sau "HH:mm" pentru TimeOnly (format 24h)
  final String timeString = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

  return {
    "UserId": userId,
    "Description": description,
    "Date": dateString, // Asigură-te că cheia JSON corespunde cu proprietatea C# ("Date")
    "Time": timeString, // Asigură-te că cheia JSON corespunde cu proprietatea C# ("Time")
    "NameOfTask": nameOfTask,
  };
}
}