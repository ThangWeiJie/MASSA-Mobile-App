import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';
import '../../../models/event.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService;

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  Set<String> _registeredEventIds = {};

  StreamSubscription<List<Event>>? _eventsSubscription;
  StreamSubscription<List<String>>? _registeredEventsSubscription;

  String? _currentUserId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Event> get events => _filteredEvents;

  EventViewModel(this._eventService) {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _eventsSubscription = _eventService.streamAllEvents().listen(
      (events) {
        _allEvents = events;
        _applySearch(notify: false);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void updateCurrentUserId(String? userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    _registeredEventIds.clear();
    _registeredEventsSubscription?.cancel();

    if (userId == null) {
      _applySearch();
      return;
    }

    _registeredEventsSubscription = _eventService
        .streamRegisteredEventIds(userId)
        .listen(
          (ids) {
            _registeredEventIds = ids.toSet();
            _applySearch();
          },
          onError: (error) {
            debugPrint('Registered IDs stream error: $error');
          },
        );
  }

  bool isRegistered(String eventId) {
    return _registeredEventIds.contains(eventId);
  }

  List<Event> getRegisteredEvents() {
    return _allEvents.where((e) => _registeredEventIds.contains(e.id)).toList();
  }

  Future<void> fetchEvents({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allEvents = await _eventService.getAllEvents();
      if (userId != null) {
        final ids = await _eventService.getRegisteredEventIds(userId);
        _registeredEventIds = ids.toSet();
      }
      _applySearch(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch({bool notify = true}) {
    final query = _searchQuery.trim().toLowerCase();
    _filteredEvents = query.isEmpty
        ? List.from(_allEvents)
        : _allEvents.where((event) {
            return event.eventName.toLowerCase().contains(query) ||
                event.description.toLowerCase().contains(query);
          }).toList();

    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _registeredEventsSubscription?.cancel();
    super.dispose();
  }
}
