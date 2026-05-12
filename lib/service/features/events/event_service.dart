import 'package:massa/models/event.dart';
import 'package:massa/repository/event_repository.dart';

class EventService {
  final EventRepository eventRepository;

  EventService({required this.eventRepository});

  Future<void> createEvent({
    required String eventName,
    required String eventDescription,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String location,
    required int capacity,
    required int registeredCount,
  }) async {
    try {
      await eventRepository.createEvent(
        eventName: eventName,
        eventDescription: eventDescription,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: location,
        capacity: capacity,
        registeredCount: registeredCount,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      await eventRepository.updateEvent(id, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await eventRepository.deleteEvent(id);
    } catch (e) {
      rethrow;
    }
  }

  // --- Registration Methods ---

  Future<void> toggleEventRegistration({
    required String eventId,
    required String userId,
    required bool isJoining,
  }) async {
    await eventRepository.toggleRegistrationTransaction(
      eventId: eventId,
      userId: userId,
      isRegistering: isJoining,
    );
  }

  Future<bool> isUserRegistered(String eventId, String userId) async {
    return await eventRepository.checkUserRegistration(eventId, userId);
  }

  // NEW: Fetches all event IDs a specific user has joined
  Future<List<String>> getRegisteredEventIds(String userId) async {
    try {
      return await eventRepository.getRegisteredEventIds(userId);
    } catch (e) {
      rethrow;
    }
  }

  // --- Fetching Methods ---

  Future<List<Event>> getAllEvents() async {
    try {
      return await eventRepository.getAllEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> getEventById(String id) async {
    try {
      return await eventRepository.getEventById(id);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Event>> streamAllEvents() {
    return eventRepository.streamAllEvents();
  }

  Stream<Event> streamEventById(String id) {
    return eventRepository.streamEventById(id);
  }

  Stream<bool> streamUserRegistration(String eventId, String userId) {
    return eventRepository.streamUserRegistration(eventId, userId);
  }

  Stream<List<Map<String, dynamic>>> getEventParticipants(String eventId) {
    return eventRepository.getParticipantsStream(eventId);
  }

  Stream<List<String>> streamRegisteredEventIds(String userId) {
    return eventRepository.streamRegisteredEventIds(userId);
  }
}
