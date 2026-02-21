import 'package:flutter/material.dart'; 

class UserTasks {
  final int? userTaskId; // ✅ ADĂUGAT: Primary Key-ul din baza de date
  final int userId;
  final String description;
  final DateTime date; 
  final TimeOfDay time; 
  final String nameOfTask;

  const UserTasks({
    this.userTaskId, // ✅ ADĂUGAT (opțional la creare)
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
      // ✅ ADĂUGAT: Citește ID-ul (verifică să se potrivească cu ce trimite C# - ex: 'userTaskId' sau 'id')
      userTaskId: json['userTaskId'] ?? json['Id'] ?? 0, 
      userId: json['userId'] as int,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String), 
      time: parsedTime,
      nameOfTask: json['nameOfTask'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final String timeString = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

    return {
      "UserTaskId": userTaskId ?? 0, // ✅ ADĂUGAT: Trimite ID-ul către backend (0 pt creare, ID real pt ștergere)
      "UserId": userId,
      "Description": description,
      "Date": dateString, 
      "Time": timeString, 
      "NameOfTask": nameOfTask,
    };
  }
}