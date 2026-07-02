class UserModel {
  final String uid;
  final String name;
  final String username;
  final String password;
  final String role; // 'admin' or 'employee'
  final String pushToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    this.password = '',
    required this.role,
    this.pushToken = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'employee',
      pushToken: json['push_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'push_token': pushToken,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
}
