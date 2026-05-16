import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/models/crew_application.dart';
import 'package:massa/models/event.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/features/events/event_service.dart';

class CrewApplicationsViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;

  Event? _event;
  Event? get event => _event;

  List<CrewApplication> _applications = [];
  List<CrewApplication> get applications => _filteredApplications;

  List<CrewApplication> _filteredApplications = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String _statusFilter = 'all';
  String get statusFilter => _statusFilter;

  String _unitFilter = 'all';
  String get unitFilter => _unitFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  StreamSubscription<List<CrewApplication>>? _applicationsSubscription;
  StreamSubscription<Event>? _eventSubscription;

  CrewApplicationsViewModel({
    required this.eventService,
    required this.eventId,
  }) {
    _subscribeToEvent();
    _subscribeToApplications();
  }

  List<String> get unitOptions {
    final units = <String>{
      ...?_event?.crewUnits,
      ..._applications.map((application) => application.firstChoiceUnit),
      ..._applications
          .map((application) => application.secondChoiceUnit)
          .where((unit) => unit.isNotEmpty),
      ..._applications
          .map((application) => application.assignedUnit)
          .where((unit) => unit.isNotEmpty),
    }.toList();

    units.sort();
    return units;
  }

  void _subscribeToEvent() {
    _eventSubscription = eventService
        .streamEventById(eventId)
        .listen(
          (event) {
            _event = event;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Crew application event stream error: $error');
          },
        );
  }

  void _subscribeToApplications() {
    _applicationsSubscription = eventService
        .streamCrewApplications(eventId)
        .listen(
          (applications) {
            _applications = applications;
            _isLoading = false;
            _applyFilters();
          },
          onError: (error) {
            debugPrint('Crew applications stream error: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void updateStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
  }

  void updateUnitFilter(String unit) {
    _unitFilter = unit;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  Future<void> acceptApplication({
    required CrewApplication application,
    required String assignedUnit,
    required UserModel reviewer,
  }) async {
    await _decideApplication(
      application: application,
      status: CrewApplicationStatus.accepted,
      assignedUnit: assignedUnit,
      reviewer: reviewer,
    );
  }

  Future<void> declineApplication({
    required CrewApplication application,
    required UserModel reviewer,
  }) async {
    await _decideApplication(
      application: application,
      status: CrewApplicationStatus.declined,
      assignedUnit: '',
      reviewer: reviewer,
    );
  }

  Future<void> waitlistApplication({
    required CrewApplication application,
    required UserModel reviewer,
  }) async {
    await _decideApplication(
      application: application,
      status: CrewApplicationStatus.waitlisted,
      assignedUnit: '',
      reviewer: reviewer,
    );
  }

  Future<void> _decideApplication({
    required CrewApplication application,
    required CrewApplicationStatus status,
    required String assignedUnit,
    required UserModel reviewer,
  }) async {
    try {
      _isActionLoading = true;
      notifyListeners();
      await eventService.decideCrewApplication(
        eventId: eventId,
        applicationId: application.id,
        status: status,
        assignedUnit: assignedUnit,
        reviewer: reviewer,
      );
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredApplications = _applications.where((application) {
      final matchesStatus =
          _statusFilter == 'all' || application.status.name == _statusFilter;
      final matchesUnit =
          _unitFilter == 'all' ||
          application.firstChoiceUnit == _unitFilter ||
          application.secondChoiceUnit == _unitFilter ||
          application.assignedUnit == _unitFilter;
      final searchText =
          '${application.fullName} ${application.matricNumber} ${application.email} ${application.department} ${application.pitch}'
              .toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty || searchText.contains(_searchQuery);

      return matchesStatus && matchesUnit && matchesSearch;
    }).toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }
}
