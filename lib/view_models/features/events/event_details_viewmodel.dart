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

  EventDetailsViewModel({
    required this.eventService,
    required this.eventId,
    this.currentUserId,
  }) {
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      _isLoading = true;
      notifyListeners();
      _event = await eventService.getEventById(eventId);

      if (currentUserId != null) {
        _isUserRegistered = await eventService.isUserRegistered(
          eventId,
          currentUserId!,
        );
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEvent(Map<String, dynamic> data) async {
    try {
      _isActionLoading = true;
      notifyListeners();
      await eventService.updateEvent(eventId, data);
      await fetchEventDetails();
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

  // --- UPDATED: Registration Toggle ---
  Future<void> toggleRegistration() async {
    // If currentUserId is null, the code returns here and nothing happens
    if (_event == null || currentUserId == null || _isActionLoading) return;

    try {
      _isActionLoading = true;
      notifyListeners();

      await eventService.toggleEventRegistration(
        eventId: eventId,
        userId: currentUserId!,
        isJoining: !_isUserRegistered,
      );

      // CRITICAL: Refresh details to update the UI count and button state
      await fetchEventDetails();
    } catch (e) {
      debugPrint("Registration error: $e");
      rethrow; // Pass error to UI for snackbar
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
