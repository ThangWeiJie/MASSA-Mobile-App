enum Role {
  user, exco, admin
}

extension RoleAccess on Role {
  bool get canManageEvents => this == Role.exco || this == Role.admin;

  bool get canAdministerApp => this == Role.admin;

  String get label {
    switch (this) {
      case Role.admin:
        return 'Admin';
      case Role.exco:
        return 'EXCO';
      case Role.user:
        return 'Student';
    }
  }
}
