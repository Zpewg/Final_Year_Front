class NotificationLeadTime {
  final int? notificationLeadTimeId;
  final int notificationId;
  final int notificationTime;

  NotificationLeadTime({
    this.notificationLeadTimeId,
    required this.notificationId,
    required this.notificationTime,
  });

  factory NotificationLeadTime.fromJson(Map<String, dynamic> json) {
    return NotificationLeadTime(
      notificationLeadTimeId: json['notificationLeadTimeId'] as int?,
      notificationId: json['notificationId'] as int,
      notificationTime: json['notificationTime'] as int,
    );
  }

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = {
    'notificationId': notificationId,
    'notificationTime': notificationTime,
  };
  
  // Trimitem ID-ul DOAR dacă nu este null (util pentru update)
  if (notificationLeadTimeId != null) {
    data['notificationLeadTimeId'] = notificationLeadTimeId;
  }
  
  return data;
}

  @override
  String toString() {
    return "NotificationLeadTime: $notificationTime";
  }
}