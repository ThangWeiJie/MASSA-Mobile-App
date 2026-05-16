import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/models/crew_application.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/features/events/event_service.dart';
import '../../../models/event.dart';

class EventDetailsViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;
  final String? currentUserId;

  Event? _event;
  Event? get event => _event;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  bool _isUserRegistered = false;
  bool get isUserRegistered => _isUserRegistered;

  CrewApplication? _crewApplication;
  CrewApplication? get crewApplication => _crewApplication;

  StreamSubscription<Event>? _eventSubscription;
  StreamSubscription<bool>? _registrationSubscription;
  StreamSubscription<CrewApplication?>? _crewApplicationSubscription;

  EventDetailsViewModel({
    required this.eventService,
    required this.eventId,
    this.currentUserId,
  }) {
    _subscribeToEvent();
    _subscribeToRegistration();
    _subscribeToCrewApplication();
  }

  void _subscribeToEvent() {
    _eventSubscription = eventService
        .streamEventById(eventId)
        .listen(
          (updatedEvent) {
            _event = updatedEvent;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Event details stream error: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _subscribeToRegistration() {
    if (currentUserId == null) return;

    _registrationSubscription = eventService
        .streamUserRegistration(eventId, currentUserId!)
        .listen(
          (isRegistered) {
            _isUserRegistered = isRegistered;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Event registration stream error: $error');
          },
        );
  }

  void _subscribeToCrewApplication() {
    if (currentUserId == null) return;

    _crewApplicationSubscription = eventService
        .streamUserCrewApplication(eventId: eventId, userId: currentUserId!)
        .listen(
          (application) {
            _crewApplication = application;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Crew application stream error: $error');
          },
        );
  }

  Future<bool> updateEvent(Map<String, dynamic> data) async {
    try {
      _isActionLoading = true;
      notifyListeners();
      await eventService.updateEvent(eventId, data);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEvent() async {
    try {
      _isActionLoading = true;
      notifyListeners();
      await eventService.deleteEvent(eventId);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleRegistration() async {
    if (_event == null || currentUserId == null || _isActionLoading) return;

    try {
      _isActionLoading = true;
      notifyListeners();
      await eventService.toggleEventRegistration(
        eventId: eventId,
        userId: currentUserId!,
        isJoining: !_isUserRegistered,
      );
      return;
    } catch (e) {
      debugPrint("Registration error: $e");
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForCrew({
    required UserModel applicant,
    required String firstChoiceUnit,
    required String secondChoiceUnit,
    required String pitch,
    required bool commitmentAccepted,
  }) async {
    if (_event == null || _isActionLoading) return;

    try {
      _isActionLoading = true;
      notifyListeners();
      await eventService.applyForCrew(
        eventId: eventId,
        applicant: applicant,
        firstChoiceUnit: firstChoiceUnit,
        secondChoiceUnit: secondChoiceUnit,
        pitch: pitch,
        commitmentAccepted: commitmentAccepted,
      );
    } catch (e) {
      debugPrint("Crew application error: $e");
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _registrationSubscription?.cancel();
    _crewApplicationSubscription?.cancel();
    super.dispose();
  }
}
