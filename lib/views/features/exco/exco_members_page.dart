import 'package:flutter/material.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/view_models/features/exco/exco_members_viewmodel.dart';
import 'package:provider/provider.dart';

class ExcoMembersPage extends StatelessWidget {
  const ExcoMembersPage({super.key});

  static const Color _backgroundColor = Color(0xFFFFFBF0);
  static const Color _massaBrown = Color(0xFF92400E);
  static const Color _massaOrange = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExcoMembersViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.amber[50]!, Colors.yellow[50]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  _PageHeader(
                    canAssign: viewModel.canAssignExcoMembers,
                    isLoading: viewModel.isActionLoading,
                    onAssign: () => _showAssignExcoDialog(context),
                  ),
                  _Header(totalMembers: viewModel.totalMembers),
                  if (viewModel.canAssignExcoMembers)
                    _AssignActionCard(
                      isLoading: viewModel.isActionLoading,
                      onTap: () => _showAssignExcoDialog(context),
                    ),
                  _SearchField(onChanged: viewModel.updateSearchQuery),
                  Expanded(child: _MembersBody(viewModel: viewModel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAssignExcoDialog(BuildContext context) async {
    final viewModel = context.read<ExcoMembersViewModel>();

    if (viewModel.assignableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user accounts available to assign.')),
      );
      return;
    }

    final result = await showModalBottomSheet<_AssignExcoResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignExcoSheet(users: viewModel.assignableUsers),
    );

    if (!context.mounted || result == null) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await viewModel.assignExcoMember(
        userId: result.userId,
        department: result.department,
        organizationRole: result.organizationRole,
      );

      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('EXCO member assigned successfully.'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.canAssign,
    required this.isLoading,
    required this.onAssign,
  });

  final bool canAssign;
  final bool isLoading;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 4,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange[600]!, Colors.amber[700]!],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.orange[800]!,
                          Colors.amber[700]!,
                          Colors.yellow[800]!,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'EXCO Members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber[600]!, Colors.transparent],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Committee structure and contacts',
                        style: TextStyle(
                          color: Colors.amber[900]!.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (canAssign)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[600]!,
                    Colors.amber[600]!,
                    Colors.yellow[700]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.amber[200]!.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onAssign,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.person_add_alt_1_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssignActionCard extends StatelessWidget {
  const _AssignActionCard({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.orange[100]!),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Colors.orange[800],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign EXCO Member',
                        style: TextStyle(
                          color: ExcoMembersPage._massaBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Promote or update a committee member',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.chevron_right, color: Colors.orange[800]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.totalMembers});

  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.groups_2_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Committee Directory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalMembers EXCO members',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search name, email, phone, department',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.orange[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.orange[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEA580C), width: 2),
          ),
        ),
      ),
    );
  }
}

class _MembersBody extends StatelessWidget {
  const _MembersBody({required this.viewModel});

  final ExcoMembersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ExcoMembersPage._massaOrange),
      );
    }

    if (viewModel.errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: 'Unable to load EXCO members',
        message: _friendlyErrorMessage(viewModel.errorMessage!),
      );
    }

    if (viewModel.members.isEmpty) {
      final isSearching = viewModel.searchQuery.isNotEmpty;
      return _MessageState(
        icon: isSearching ? Icons.search_off : Icons.group_off_outlined,
        title: isSearching ? 'No matching members' : 'No EXCO members found',
        message: isSearching
            ? 'Try a different name, department, email, or phone number.'
            : 'Assign users the EXCO role to show them here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemBuilder: (context, sectionIndex) {
        final section = viewModel.sections[sectionIndex];
        return _MemberSection(section: section);
      },
      itemCount: viewModel.sections.length,
    );
  }

  String _friendlyErrorMessage(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('permission-denied')) {
      return 'Please allow EXCO/admin users to read the users collection in Firestore rules.';
    }
    return 'Please check your connection and try again.';
  }
}

class _MemberSection extends StatelessWidget {
  const _MemberSection({required this.section});

  final ExcoMemberSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(section: section),
          const SizedBox(height: 10),
          ...section.members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MemberCard(member: member, sectionTitle: section.title),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final ExcoMemberSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForSection(section.title),
              color: Colors.orange[800],
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          color: ExcoMembersPage._massaBrown,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${section.members.length}',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (section.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    section.description,
                    style: TextStyle(
                      color: Colors.brown.withValues(alpha: 0.72),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForSection(String title) {
    if (title == 'Highest Council Members') return Icons.workspace_premium;
    if (title.contains('Corporate')) return Icons.handshake_outlined;
    if (title.contains('Multimedia')) return Icons.video_camera_back_outlined;
    if (title.contains('Publicity')) return Icons.campaign_outlined;
    if (title.contains('Sports')) return Icons.sports_soccer_outlined;
    if (title.contains('Cultural')) return Icons.diversity_3_outlined;
    if (title.contains('Entrepreneurship')) return Icons.storefront_outlined;
    if (title.contains('Welfare')) return Icons.school_outlined;
    return Icons.groups_2_outlined;
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.sectionTitle});

  final UserModel member;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange[100]!),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _roleColor(member.role).withValues(alpha: 0.14),
            child: Text(
              _initials(member.fullName),
              style: TextStyle(
                color: _roleColor(member.role),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        member.fullName.isEmpty
                            ? 'Unnamed member'
                            : member.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _RoleBadge(role: member.role),
                  ],
                ),
                const SizedBox(height: 10),
                _OrganizationRoleChip(
                  label: _organizationRoleText(member, sectionTitle),
                  isHighestCouncil: sectionTitle == 'Highest Council Members',
                ),
                const SizedBox(height: 4),
                _InfoRow(icon: Icons.mail_outline, value: member.email),
                if (member.phone.isNotEmpty)
                  _InfoRow(icon: Icons.phone_outlined, value: member.phone),
                if (member.department.isNotEmpty)
                  _InfoRow(
                    icon: Icons.apartment_outlined,
                    value: member.department,
                  ),
                if ((member.matricNumber ?? '').isNotEmpty)
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    value: member.matricNumber!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static String _organizationRoleText(UserModel member, String sectionTitle) {
    if (member.organizationRole.trim().isNotEmpty) {
      return member.organizationRole.trim();
    }

    if (sectionTitle == 'Highest Council Members') {
      return 'Highest Council Member';
    }

    return 'Department Member';
  }

  static Color _roleColor(Role role) {
    switch (role) {
      case Role.admin:
        return Colors.red[700]!;
      case Role.exco:
        return Colors.orange[800]!;
      case Role.user:
        return Colors.grey[700]!;
    }
  }
}

class _OrganizationRoleChip extends StatelessWidget {
  const _OrganizationRoleChip({
    required this.label,
    required this.isHighestCouncil,
  });

  final String label;
  final bool isHighestCouncil;

  @override
  Widget build(BuildContext context) {
    final color = isHighestCouncil ? Colors.red : Colors.orange;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHighestCouncil
                ? Icons.workspace_premium
                : Icons.assignment_ind_outlined,
            size: 16,
            color: color[800],
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color[900],
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    final color = role == Role.admin ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: color[800],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AssignExcoSheet extends StatefulWidget {
  const _AssignExcoSheet({required this.users});

  final List<UserModel> users;

  @override
  State<_AssignExcoSheet> createState() => _AssignExcoSheetState();
}

class _AssignExcoSheetState extends State<_AssignExcoSheet> {
  final TextEditingController _organizationRoleController =
      TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();

  late String _selectedUserId;
  String _selectedDepartment = ExcoMembersViewModel.assignableDepartments.first;
  String _userSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.users.first.uuid;
    _organizationRoleController.text =
        ExcoMembersViewModel.highestCouncilRoleOptions.first;
  }

  @override
  void dispose() {
    _organizationRoleController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _filteredUsers();
    final selectedUser = widget.users.firstWhere(
      (user) => user.uuid == _selectedUserId,
      orElse: () => widget.users.first,
    );

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomContentPadding = 24 + MediaQuery.paddingOf(context).bottom + 96;
    final isHighestCouncilSelected =
        _selectedDepartment == 'Highest Council Members';
    final organizationRoleOptions = isHighestCouncilSelected
        ? ExcoMembersViewModel.highestCouncilRoleOptions
        : ExcoMembersViewModel.departmentRoleOptions;
    final selectedOrganizationRole =
        organizationRoleOptions.contains(
          _organizationRoleController.text.trim(),
        )
        ? _organizationRoleController.text.trim()
        : organizationRoleOptions.first;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: ExcoMembersPage._backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, 10, 22, bottomContentPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Assign EXCO Member',
                        style: TextStyle(
                          color: ExcoMembersPage._massaBrown,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _userSearchController,
                  decoration: _sheetInputDecoration(
                    'Find user account',
                    hintText: 'Search name, email, department',
                  ).copyWith(prefixIcon: const Icon(Icons.search)),
                  onChanged: (value) {
                    setState(
                      () => _userSearchQuery = value.trim().toLowerCase(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _UserSearchResults(
                  users: filteredUsers,
                  selectedUserId: _selectedUserId,
                  totalMatches: _matchingUserCount(),
                  onSelected: (user) {
                    setState(() {
                      _selectedUserId = user.uuid;
                      _userSearchController.text = _displayName(user);
                      _userSearchQuery = _displayName(user).toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                _SelectedUserSummary(user: selectedUser),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment,
                  isExpanded: true,
                  menuMaxHeight: 320,
                  decoration: _sheetInputDecoration('Organization unit'),
                  items: ExcoMembersViewModel.assignableDepartments.map((
                    department,
                  ) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedDepartment = value;
                      if (value == 'Highest Council Members') {
                        final currentRole = _organizationRoleController.text
                            .trim();
                        if (!ExcoMembersViewModel.highestCouncilRoleOptions
                            .contains(currentRole)) {
                          _organizationRoleController.text =
                              ExcoMembersViewModel
                                  .highestCouncilRoleOptions
                                  .first;
                        }
                      } else if (_organizationRoleController.text
                              .trim()
                              .isEmpty ||
                          ExcoMembersViewModel.highestCouncilRoleOptions
                              .contains(
                                _organizationRoleController.text.trim(),
                              )) {
                        _organizationRoleController.text =
                            ExcoMembersViewModel.departmentRoleOptions.last;
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedOrganizationRole,
                  isExpanded: true,
                  decoration: _sheetInputDecoration('Organization role'),
                  items: organizationRoleOptions.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _organizationRoleController.text = value;
                    });
                  },
                ),
                if (isHighestCouncilSelected) ...[
                  const SizedBox(height: 10),
                  _RoleUniquenessNotice(
                    role: _organizationRoleController.text.trim(),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[800],
                          side: BorderSide(color: Colors.green[200]!),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExcoMembersPage._massaOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(
                            _AssignExcoResult(
                              userId: _selectedUserId,
                              department: _selectedDepartment,
                              organizationRole:
                                  _organizationRoleController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Assign'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<UserModel> _filteredUsers() {
    final query = _userSearchQuery;
    final matches = query.isEmpty
        ? widget.users
        : widget.users.where((user) => _userSearchText(user).contains(query));

    return matches.take(8).toList();
  }

  int _matchingUserCount() {
    final query = _userSearchQuery;
    if (query.isEmpty) return widget.users.length;
    return widget.users
        .where((user) => _userSearchText(user).contains(query))
        .length;
  }

  String _userSearchText(UserModel user) {
    return '${user.fullName} ${user.email} ${user.department} ${user.matricNumber ?? ''}'
        .toLowerCase();
  }

  InputDecoration _sheetInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange[100]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange[100]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: ExcoMembersPage._massaOrange,
          width: 2,
        ),
      ),
    );
  }

  static String _displayName(UserModel user) {
    if (user.fullName.trim().isNotEmpty) return user.fullName.trim();
    if (user.email.trim().isNotEmpty) return user.email.trim();
    return 'Unnamed user';
  }
}

class _SelectedUserSummary extends StatelessWidget {
  const _SelectedUserSummary({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email.isEmpty ? 'No email recorded' : user.email,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (user.department.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.department,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserSearchResults extends StatelessWidget {
  const _UserSearchResults({
    required this.users,
    required this.selectedUserId,
    required this.totalMatches,
    required this.onSelected,
  });

  final List<UserModel> users;
  final String selectedUserId;
  final int totalMatches;
  final ValueChanged<UserModel> onSelected;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange[100]!),
        ),
        child: Text(
          'No users found',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: users.length + (totalMatches > users.length ? 1 : 0),
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: Colors.orange[50],
          indent: 14,
          endIndent: 14,
        ),
        itemBuilder: (context, index) {
          if (index >= users.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                'Showing first ${users.length} of $totalMatches matches. Keep typing to narrow results.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            );
          }

          final user = users[index];
          final isSelected = user.uuid == selectedUserId;
          final status = user.role == Role.exco ? 'Current EXCO' : 'Student';

          return Material(
            color: isSelected ? Colors.orange[50] : Colors.transparent,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange[100],
                child: Text(
                  _initials(user.fullName),
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                _displayName(user),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                [
                  user.email,
                  if (user.department.isNotEmpty) user.department,
                  status,
                ].where((text) => text.isNotEmpty).join(' - '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: Colors.orange[800])
                  : null,
              onTap: () => onSelected(user),
            ),
          );
        },
      ),
    );
  }

  static String _displayName(UserModel user) {
    if (user.fullName.trim().isNotEmpty) return user.fullName.trim();
    if (user.email.trim().isNotEmpty) return user.email.trim();
    return 'Unnamed user';
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _RoleUniquenessNotice extends StatelessWidget {
  const _RoleUniquenessNotice({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final displayRole = role.isEmpty ? 'this role' : role;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.swap_horiz, size: 18, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Only one $displayRole is allowed. Assigning this role will automatically demote the previous holder to Student.',
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignExcoResult {
  final String userId;
  final String department;
  final String organizationRole;

  const _AssignExcoResult({
    required this.userId,
    required this.department,
    required this.organizationRole,
  });
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: Colors.brown.withValues(alpha: 0.28)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ExcoMembersPage._massaBrown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
