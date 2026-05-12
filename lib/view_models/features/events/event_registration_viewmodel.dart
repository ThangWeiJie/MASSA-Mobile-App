import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';

import '../../../models/event.dart';

class EventRegistrationViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;

  EventRegistrationViewModel({
    required this.eventService,
    required this.eventId,
  }) {
    loadEvent();
  }

  Event? _event;
  Event? get event => _event;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  bool _isRegistered = false;
  bool get isRegistered => _isRegistered;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadEvent() async {
    _isLoading = true;
    notifyListeners();

    try {
      _event = await eventService.getEventById(eventId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Could not load event details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerForEvent() async {
    if (_isRegistered || _event == null) return;

    _isRegistering = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 350));

    _isRegistering = false;
    _isRegistered = true;
    notifyListeners();
  }
}
