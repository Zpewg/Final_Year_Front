class NotificationEnabled {
  final int? notificationId; // Opțional pentru momentele când creezi un obiect nou
  final int userId;
  final bool isEnabled;

  NotificationEnabled({
    this.notificationId,
    required this.userId,
    required this.isEnabled,
  });

  factory NotificationEnabled.fromJson(Map<String, dynamic> json) {
    return NotificationEnabled(
      notificationId: json['notificationId'] as int?,
      userId: json['userId'] as int,
      isEnabled: json['isEnabled'] as bool,
    );
  }

Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId ?? 0, // <-- modificarea e aici
      'userId': userId,
      'isEnabled': isEnabled,
    };
  }

  @override
  String toString() {
    return isEnabled ? "Enabled" : "Disabled";
  }
}