class UserModel {
  final String userId, userName, email, userType, token;

  UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.userType,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      userId: jsonData["user"]["userid"].toString(),
      userName: jsonData["user"]["username"],
      email: jsonData["user"]["email"],
      userType: jsonData["user"]["user_type"],
      token: jsonData["token"],
    );
  }
}
