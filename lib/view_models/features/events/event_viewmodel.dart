import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';

import '../../../models/event.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService;

  List<Event> _events = [];
  List<Event> get events => _events;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EventViewModel(this._eventService) {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _eventService.getAllEvents();
    } catch(e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}