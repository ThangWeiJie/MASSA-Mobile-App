import 'dart:async';

import 'package:flutter/material.dart';
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

  StreamSubscription<Event>? _eventSubscription;
  StreamSubscription<bool>? _registrationSubscription;

  EventDetailsViewModel({
    required this.eventService,
    required this.eventId,
    this.currentUserId,
  }) {
    _subscribeToEvent();
    _subscribeToRegistration();
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

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _registrationSubscription?.cancel();
    super.dispose();
  }
}
