class UserDTO {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;

  const UserDTO({
    this.id = 0,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: int.tryParse(json['UserDTOId']?.toString() ?? '0') ?? 0,
      name: json['UserDTOName']?.toString() ?? '',
      email: json['UserDTOEmail']?.toString() ?? '',
      password: json['UserDTOPassword']?.toString() ?? '',
      phoneNumber: json['UserDTOPhoneNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "UserDTOId": id,
        "UserDTOName": name,
        "UserDTOEmail": email,
        "UserDTOPassword": password,
        "UserDTOPhoneNumber": phoneNumber,
      };
}