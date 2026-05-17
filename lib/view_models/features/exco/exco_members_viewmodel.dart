import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';

class ExcoMembersViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final UserModel? currentUser;

  ExcoMembersViewModel({required this.userRepository, this.currentUser}) {
    _subscribeToMembers();
    if (canAssignExcoMembers) {
      _subscribeToAssignableUsers();
    }
  }

  List<UserModel> _members = [];
  List<UserModel> _filteredMembers = [];
  List<UserModel> _assignableUsers = [];
  StreamSubscription<List<UserModel>>? _membersSubscription;
  StreamSubscription<List<UserModel>>? _assignableUsersSubscription;

  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<UserModel> get members => _filteredMembers;
  List<ExcoMemberSection> get sections => _buildSections(_filteredMembers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get totalMembers => _members.length;
  bool get isActionLoading => _isActionLoading;
  List<UserModel> get assignableUsers => _assignableUsers;
  bool get canAssignExcoMembers {
    final user = currentUser;
    if (user == null) return false;
    return user.role == Role.admin || _isHighestCouncilUser(user);
  }

  void _subscribeToMembers() {
    _membersSubscription = userRepository.streamExcoMembers().listen(
      (members) {
        _members = members;
        _isLoading = false;
        _errorMessage = null;
        _applyFilters();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _subscribeToAssignableUsers() {
    _assignableUsersSubscription = userRepository
        .streamAssignableExcoUsers()
        .listen(
          (users) {
            _assignableUsers = users;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Assignable EXCO users stream error: $error');
          },
        );
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredMembers = List<UserModel>.from(_members);
    } else {
      _filteredMembers = _members.where((member) {
        final searchText =
            '${member.fullName} ${member.email} ${member.department} '
                    '${member.organizationRole} ${member.phone} ${member.role.label}'
                .toLowerCase();
        return searchText.contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  Future<void> assignExcoMember({
    required String userId,
    required String department,
    required String organizationRole,
  }) async {
    final trimmedDepartment = department.trim();
    final trimmedOrganizationRole = organizationRole.trim();

    if (!canAssignExcoMembers) {
      throw Exception(
        'Only admins and Highest Council members can assign EXCO.',
      );
    }

    if (userId.isEmpty) {
      throw Exception('Please choose a user account.');
    }

    if (trimmedDepartment.isEmpty) {
      throw Exception('Please choose a department.');
    }

    if (trimmedOrganizationRole.isEmpty) {
      throw Exception('Please enter an organization role.');
    }

    if (trimmedDepartment == _highestCouncilTitle &&
        !highestCouncilRoleOptions.contains(trimmedOrganizationRole)) {
      throw Exception('Please choose a valid Highest Council role.');
    }

    if (trimmedDepartment != _highestCouncilTitle &&
        !departmentRoleOptions.contains(trimmedOrganizationRole)) {
      throw Exception('Please choose a valid department role.');
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      await userRepository.assignExcoMember(
        userId: userId,
        department: trimmedDepartment,
        organizationRole: trimmedOrganizationRole,
      );
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  List<ExcoMemberSection> _buildSections(List<UserModel> members) {
    final groupedMembers = <String, List<UserModel>>{};

    for (final member in members) {
      final sectionTitle = _sectionForMember(member);
      groupedMembers.putIfAbsent(sectionTitle, () => []).add(member);
    }

    final sections = <ExcoMemberSection>[];

    for (final title in _sectionOrder) {
      final sectionMembers = groupedMembers[title] ?? [];
      if (sectionMembers.isEmpty) continue;

      sectionMembers.sort(_compareMembersWithinSection);
      sections.add(
        ExcoMemberSection(
          title: title,
          description: _sectionDescriptions[title] ?? '',
          members: sectionMembers,
        ),
      );
    }

    final otherMembers = groupedMembers[_otherSectionTitle] ?? [];
    if (otherMembers.isNotEmpty) {
      otherMembers.sort(_compareMembersWithinSection);
      sections.add(
        ExcoMemberSection(
          title: _otherSectionTitle,
          description: 'Members without a mapped organization department yet.',
          members: otherMembers,
        ),
      );
    }

    return sections;
  }

  String _sectionForMember(UserModel member) {
    if (_isHighestCouncil(member.organizationRole) ||
        _isHighestCouncil(member.department)) {
      return _highestCouncilTitle;
    }

    final normalizedDepartment = _normalize(member.department);
    if (normalizedDepartment.isEmpty) return _otherSectionTitle;

    for (final entry in _departmentAliases.entries) {
      if (entry.value.any(normalizedDepartment.contains)) {
        return entry.key;
      }
    }

    return _otherSectionTitle;
  }

  int _compareMembersWithinSection(UserModel first, UserModel second) {
    final positionOrder = _positionSortValue(
      first.organizationRole,
    ).compareTo(_positionSortValue(second.organizationRole));
    if (positionOrder != 0) return positionOrder;

    final roleOrder = _roleSortValue(
      first.role,
    ).compareTo(_roleSortValue(second.role));
    if (roleOrder != 0) return roleOrder;

    return first.fullName.toLowerCase().compareTo(
      second.fullName.toLowerCase(),
    );
  }

  int _roleSortValue(Role role) {
    switch (role) {
      case Role.admin:
        return 0;
      case Role.exco:
        return 1;
      case Role.user:
        return 2;
    }
  }

  bool _isHighestCouncil(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) return false;

    return normalized.contains('highest council') ||
        normalized.contains('high council') ||
        _highestCouncilPositions.any(normalized.contains);
  }

  bool _isHighestCouncilUser(UserModel user) {
    return user.role == Role.exco &&
        (_isHighestCouncil(user.organizationRole) ||
            _isHighestCouncil(user.department));
  }

  int _positionSortValue(String position) {
    final normalized = _normalize(position);
    if (normalized.isEmpty) return 999;

    final exactIndex = _highestCouncilPositions.indexWhere(
      (item) => normalized == item,
    );
    if (exactIndex != -1) return exactIndex;

    final index = _highestCouncilPositions.indexWhere(normalized.contains);
    if (index != -1) return index;

    return 100;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _membersSubscription?.cancel();
    _assignableUsersSubscription?.cancel();
    super.dispose();
  }

  static const String _highestCouncilTitle = 'Highest Council Members';
  static const String _otherSectionTitle = 'Other EXCO Members';

  static const List<String> _sectionOrder = [
    _highestCouncilTitle,
    'Corporate and External Affairs Department',
    'Multimedia Department',
    'Publicity Department',
    'Sports, Technical and Logistics Department',
    'Cultural Department',
    'Entrepreneurship Department',
    'Welfare and Academic Department',
  ];

  static const List<String> assignableDepartments = [
    _highestCouncilTitle,
    'Corporate and External Affairs Department',
    'Multimedia Department',
    'Publicity Department',
    'Sports, Technical and Logistics Department',
    'Cultural Department',
    'Entrepreneurship Department',
    'Welfare and Academic Department',
  ];

  static const List<String> highestCouncilRoleOptions = [
    'President',
    'Vice President',
    'Secretary',
    'Vice Secretary',
    'Treasurer',
    'Vice Treasurer',
  ];

  static const List<String> departmentRoleOptions = [
    'Head of Department',
    'Assistant Head of Department',
    'Department Member',
  ];

  static const Map<String, String> _sectionDescriptions = {
    _highestCouncilTitle:
        'President, vice president, secretary, treasurer, and their deputies.',
    'Corporate and External Affairs Department':
        'Partnerships, sponsorships, and external relations.',
    'Multimedia Department':
        'Creative media, photo, video, and design support.',
    'Publicity Department':
        'Promotion, announcements, and public communications.',
    'Sports, Technical and Logistics Department':
        'Sports activities, venue setup, equipment, operations, and logistics.',
    'Cultural Department':
        'Cultural programs, performances, and heritage activities.',
    'Entrepreneurship Department':
        'Business, sales, and entrepreneurship initiatives.',
    'Welfare and Academic Department':
        'Student welfare, academic support, and member care.',
  };

  static const Map<String, List<String>> _departmentAliases = {
    'Corporate and External Affairs Department': [
      'corporate and external affairs',
      'corporate external affairs',
      'external affairs',
      'corporate',
    ],
    'Multimedia Department': ['multimedia', 'media'],
    'Publicity Department': [
      'publicity',
      'public relation',
      'public relations',
    ],
    'Sports, Technical and Logistics Department': [
      'sports technical and logistics',
      'sport technical and logistics',
      'sports technical logistics',
      'sport technical logistics',
      'sports',
      'sport',
      'technical and logistics',
      'technical logistics',
      'technical',
      'logistics',
    ],
    'Cultural Department': ['cultural', 'culture'],
    'Entrepreneurship Department': ['entrepreneurship', 'entrepreneur'],
    'Welfare and Academic Department': [
      'welfare and academic',
      'welfare academic',
      'welfare',
      'academic',
    ],
  };

  static const List<String> _highestCouncilPositions = [
    'president',
    'vice president',
    'secretary',
    'vice secretary',
    'treasurer',
    'vice treasurer',
  ];
}

class ExcoMemberSection {
  final String title;
  final String description;
  final List<UserModel> members;

  const ExcoMemberSection({
    required this.title,
    required this.description,
    required this.members,
  });
}
