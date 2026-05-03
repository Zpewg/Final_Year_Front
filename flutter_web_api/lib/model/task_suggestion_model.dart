class TaskSuggestion {
  final int? taskSuggestionId; // Este opțional (nullable) pentru că este generat de baza de date
  final int userId;
  final bool isEnabled;

  const TaskSuggestion({
    this.taskSuggestionId,
    required this.userId,
    required this.isEnabled,
  });

  // Metodă pentru a parsa datele primite de la API (C#)
  factory TaskSuggestion.fromJson(Map<String, dynamic> json) {
    return TaskSuggestion(
      // Folosim ?? pentru a acoperi atât PascalCase (C# default) cât și camelCase (JsonSerializer options)
      taskSuggestionId: json['taskSuggestionId'] ?? json['TaskSuggestionId'] ?? 0,
      userId: json['userId'] ?? json['UserId'] as int,
      isEnabled: json['isEnabled'] ?? json['IsEnabled'] as bool,
    );
  }

  // Metodă pentru a trimite datele către API (C#)
  Map<String, dynamic> toJson() {
    return {
      "TaskSuggestionId": taskSuggestionId ?? 0, // Trimitem 0 dacă e un obiect nou
      "UserId": userId,
      "IsEnabled": isEnabled,
    };
  }

  // Suprascrierea metodei toString exact ca în C#
  @override
  String toString() {
    return isEnabled ? "Enabled" : "Disabled";
  }
}