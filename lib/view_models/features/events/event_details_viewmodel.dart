import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';

import '../../../models/event.dart';

class EventDetailsViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;

  EventDetailsViewModel({required this.eventService, required this.eventId}) {
    fetchEventDetails();
  }

  Event? _event;
  Event? get event => _event;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchEventDetails() async {
    try {
      _event = await eventService.getEventById(eventId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}