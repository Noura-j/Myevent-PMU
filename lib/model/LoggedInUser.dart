class LoggedInUser {
  String uid;
  String email;
  String username;
  String role;
  String phone;

  LoggedInUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    required this.phone,
  });

  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      role: json['role'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'role': role,
        'phone': phone,
      };
}
