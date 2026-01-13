class VerifyMessage {
 
  final String message;
  final String userMail;

  const VerifyMessage({
    required this.message,
    required this.userMail
  });

  factory VerifyMessage.fromJson(Map<String, dynamic> json) {
    return VerifyMessage(
      message: json['Code'] as String,
      userMail: json['userMail'] as String
     );
  }

  Map<String, dynamic> toJson() => {
        "Code": message,
        "Mail": userMail
      };
}
