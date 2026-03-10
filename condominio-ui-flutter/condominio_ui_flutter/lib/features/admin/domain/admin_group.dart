class AdminGroup {
  const AdminGroup({
    required this.groupId,
    required this.groupName,
    required this.roles,
  });

  final String groupId;
  final String groupName;
  final List<String> roles;

  factory AdminGroup.fromJson(Map<String, dynamic> json) {
    final rawRoles = (json['roles'] as List?) ?? const [];
    return AdminGroup(
      groupId: (json['groupId'] ?? '').toString(),
      groupName: (json['groupName'] ?? '').toString(),
      roles: rawRoles.map((item) => item.toString()).toList(growable: false),
    );
  }
}
