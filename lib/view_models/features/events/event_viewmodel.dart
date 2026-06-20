import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';
import '../../../models/event.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService;

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  Map<int, List<Event>> _filteredPastEventsByYear = {};
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
  Map<int, List<Event>> get pastEventsByYear => _filteredPastEventsByYear;
  int get pastEventCount => _filteredPastEventsByYear.values.fold(
        0,
        (total, events) => total + events.length,
      );

  Map<int, List<Event>> getRegisteredPastEventsByYear() {
    final Map<int, List<Event>> filtered = {};
    _filteredPastEventsByYear.forEach((year, list) {
      final studentList = list.where((event) => isRegistered(event.id ?? '')).toList();
      if (studentList.isNotEmpty) {
        filtered[year] = studentList;
      }
    });
    return filtered;
  }

  int getRegisteredPastEventCount() {
    return getRegisteredPastEventsByYear().values.fold(
          0,
          (total, events) => total + events.length,
        );
  }

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
    _errorMessage = null;
    _registeredEventsSubscription?.cancel();

    if (userId == null) {
      _applySearch();
      return;
    }

    _registeredEventsSubscription = _eventService
        .streamRegisteredEventIds(userId)
        .listen(
          (ids) {
            if (_currentUserId != userId) return;
            _registeredEventIds = ids.toSet();
            _applySearch();
          },
          onError: (error) {
            debugPrint('Registered IDs stream error: $error');
            if (_currentUserId != userId) return;
            _registeredEventIds.clear();
            _applySearch();
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
      if (userId != null && userId == _currentUserId) {
        try {
          final ids = await _eventService.getRegisteredEventIds(userId);
          if (userId == _currentUserId) {
            _registeredEventIds = ids.toSet();
          }
        } catch (e) {
          debugPrint('Registered IDs fetch error: $e');
          if (userId == _currentUserId) {
            _registeredEventIds.clear();
          }
        }
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
    final now = DateTime.now();
    final activeEvents = <Event>[];
    final pastEvents = <Event>[];

    for (final event in _allEvents) {
      if (_isPastEvent(event, now)) {
        pastEvents.add(event);
      } else {
        activeEvents.add(event);
      }
    }

    _filteredEvents = _filterEvents(activeEvents, query)
      ..sort(
        (first, second) => first.startDateTime.compareTo(second.startDateTime),
      );

    final filteredPastEvents = _filterEvents(pastEvents, query)
      ..sort(
        (first, second) => second.endDateTime.compareTo(first.endDateTime),
      );

    _filteredPastEventsByYear = _groupPastEventsByYear(filteredPastEvents);

    if (notify) notifyListeners();
  }

  bool _isPastEvent(Event event, DateTime now) {
    return event.endDateTime.isBefore(now);
  }

  List<Event> _filterEvents(List<Event> events, String query) {
    if (query.isEmpty) return List<Event>.from(events);

    return events.where((event) {
      return event.eventName.toLowerCase().contains(query) ||
          event.description.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query);
    }).toList();
  }

  Map<int, List<Event>> _groupPastEventsByYear(List<Event> pastEvents) {
    final groupedEvents = <int, List<Event>>{};

    for (final event in pastEvents) {
      groupedEvents.putIfAbsent(event.startDateTime.year, () => []).add(event);
    }

    return groupedEvents;
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _registeredEventsSubscription?.cancel();
    super.dispose();
  }
}
