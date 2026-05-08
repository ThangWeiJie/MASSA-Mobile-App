import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';
import '../../../models/event.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService;

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  
  // Store IDs of events the user has joined
  Set<String> _registeredEventIds = {};

  List<Event> get events => _filteredEvents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  EventViewModel(this._eventService) {
    fetchEvents();
  }

  // --- UPDATED: Accepts an optional userId to fetch registration status ---
  Future<void> fetchEvents({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch all events for the general list
      _allEvents = await _eventService.getAllEvents();

      // 2. Fetch registered IDs if a user is logged in
      if (userId != null) {
        final ids = await _eventService.getRegisteredEventIds(userId);
        _registeredEventIds = ids.toSet();
      } else {
        _registeredEventIds.clear();
      }

      _applySearch(); 
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to check if a specific event is registered
  bool isRegistered(String eventId) {
    return _registeredEventIds.contains(eventId);
  }

  // Helper to get ONLY registered events for the Student Homepage
  List<Event> getRegisteredEvents() {
    return _allEvents.where((e) => _registeredEventIds.contains(e.id)).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredEvents = List.from(_allEvents);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredEvents = _allEvents.where((e) =>
          e.eventName.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q)
      ).toList();
    }
    notifyListeners();
  }
}