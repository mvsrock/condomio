class AdminRole {
  const AdminRole({
    required this.roleId,
    required this.roleName,
    required this.description,
    required this.groupIds,
  });

  final String roleId;
  final String roleName;
  final String description;
  final List<String> groupIds;

  factory AdminRole.fromJson(Map<String, dynamic> json) {
    final rawGroupIds = json['groupIDs'];
    final groupIds = <String>[
      if (rawGroupIds is List)
        for (final id in rawGroupIds)
          if (id != null && id.toString().isNotEmpty) id.toString(),
    ];
    return AdminRole(
      roleId: (json['roleId'] ?? json['rolesId'] ?? '').toString(),
      roleName: (json['roleName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      groupIds: groupIds,
    );
  }
}
