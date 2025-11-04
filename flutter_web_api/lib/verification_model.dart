class VerifyMessage {
  final String message;

  const VerifyMessage({required this.message});

  factory VerifyMessage.fromJson(Map<String, dynamic> json) {
    return VerifyMessage(
      message: json['VerifyMessage'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        "VerifyMessage": message,
      };
}
