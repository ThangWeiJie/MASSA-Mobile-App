// view_models/features/events/attendee_list_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';

class AttendeeListViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;

  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> get participants => _participants;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AttendeeListViewModel({required this.eventService, required this.eventId}) {
    _listenToParticipants();
  }

  void _listenToParticipants() {
    eventService.getEventParticipants(eventId).listen((data) {
      _participants = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error fetching participants: $error");
      _isLoading = false;
      notifyListeners();
    });
  }
}