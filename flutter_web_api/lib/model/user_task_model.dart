import 'package:flutter/material.dart';

class UserTasks {
  final int? userTaskId;
  final int userId;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String nameOfTask;
  final int? taskDifficulty;
  final int? taskUrgency;
  final double? taskLength;
  final double? taskWeight; 

  const UserTasks({
    this.userTaskId,
    required this.userId,
    required this.description,
    required this.date,
    required this.time,
    required this.nameOfTask,
    this.taskDifficulty,
    this.taskUrgency,
    this.taskLength,
    this.taskWeight, 
  });
  UserTasks copyWith({
    int? userTaskId,
    int? userId,
    String? nameOfTask,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    int? taskDifficulty,
    int? taskUrgency,
    double? taskLength,
    double? taskWeight,
  }) {
    return UserTasks(
      userTaskId: userTaskId ?? this.userTaskId,
      userId: userId ?? this.userId,
      nameOfTask: nameOfTask ?? this.nameOfTask,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      taskDifficulty: taskDifficulty ?? this.taskDifficulty,
      taskUrgency: taskUrgency ?? this.taskUrgency,
      taskLength: taskLength ?? this.taskLength,
      taskWeight: taskWeight ?? this.taskWeight,
    );
  }

  factory UserTasks.fromJson(Map<String, dynamic> json) {
    final String rawTime = json['time'] as String;
    final List<String> timeParts = rawTime.split(':');
    final TimeOfDay parsedTime = TimeOfDay(
        hour: int.parse(timeParts[0]), 
        minute: int.parse(timeParts[1])
    );

    return UserTasks(
      userTaskId: json['userTaskId'] ?? json['Id'] ?? 0,
      userId: json['userId'] as int,
      description: json['description'] ?? "",
      date: DateTime.parse(json['date'] as String),
      time: parsedTime,
      nameOfTask: json['nameOfTask'] as String,
      taskDifficulty: json['taskDifficulty'] as int?,
      taskUrgency: json['taskUrgency'] as int?,
      taskLength: (json['taskLength'] as num?)?.toDouble(),
      taskWeight: (json['taskWeight'] as num?)?.toDouble(), 
    );
  }

  Map<String, dynamic> toJson() {
    final String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final String timeString =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

    return {
      "UserTaskId": userTaskId ?? 0,
      "UserId": userId,
      "Description": description,
      "Date": dateString,
      "Time": timeString,
      "NameOfTask": nameOfTask,
      "taskDifficulty": taskDifficulty,
      "taskUrgency": taskUrgency,
      "taskLength": taskLength,
      "taskWeight": taskWeight, 
    };
  }
}