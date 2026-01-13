
class  NewPasswordFromUser{

  final String userEmail;
  final String newPassword;

  const NewPasswordFromUser({
    required this.userEmail,
    required this.newPassword
  
  });


factory NewPasswordFromUser.fromJson(Map<String, dynamic> json) {
  return NewPasswordFromUser(
    userEmail: json['userEmail'] as String,
    newPassword: json['newPassword'] as String,
  
  );
}


Map<String, dynamic> toJson() => {
  "UserEmail": userEmail,       
  "NewPassword": newPassword,
};
}