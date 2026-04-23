import 'package:flutter/material.dart';

class UserTasksGlobal {
  final int? userTaskId;
  final int userId;
  final Map<String, dynamic>? location; // Point din C# (ex: GeoJSON)
  final String? description; // Nullable în C#
  final DateTime date;
  final TimeOfDay time;
  final String nameOfTask;

  const UserTasksGlobal({
    this.userTaskId,
    required this.userId,
    this.location,
    this.description,
    required this.date,
    required this.time,
    required this.nameOfTask,
  });

  factory UserTasksGlobal.fromJson(Map<String, dynamic> json) {
    // Tratăm time-ul (pentru TimeOnly din C#)
    final String rawTime = json['time'] ?? json['Time'] ?? "00:00";
    final List<String> timeParts = rawTime.split(':');
    final TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return UserTasksGlobal(
      userTaskId: json['userTaskId'] ?? json['UserTaskId'] ?? 0,
      userId: json['userId'] ?? json['UserId'] ?? 0,
      location: json['location'] ?? json['Location'],
      description: json['description'] ?? json['Description'],
      date: DateTime.parse(json['date'] ?? json['Date']),
      time: parsedTime,
      nameOfTask: json['nameOfTask'] ?? json['NameOfTask'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final String timeString = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

    return {
      "UserTaskId": userTaskId ?? 0,
      "UserId": userId,
      "Location": location, // C# așteaptă Point (ex: {"type": "Point", "coordinates": [lon, lat]})
      "Description": description,
      "Date": dateString,
      "Time": timeString,
      "NameOfTask": nameOfTask,
    };
  }
}