class AdminUser {
  const AdminUser({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.enabled,
    required this.groupName,
  });

  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final bool enabled;
  final String groupName;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      enabled: json['enabled'] == true,
      groupName: (json['groupName'] ?? '').toString(),
    );
  }
}
