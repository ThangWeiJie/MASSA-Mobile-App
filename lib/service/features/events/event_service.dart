import 'package:massa/repository/event_repository.dart';

class EventService {
  final EventRepository eventRepository;

  EventService({required this.eventRepository});

  Future<void> createEvent({required String eventName, required String eventDescription, required DateTime startDateTime, required DateTime endDateTime}) async {
    try {
      await eventRepository.createEvent(
          eventName: eventName,
          eventDescription: eventDescription,
          startDateTime: startDateTime,
          endDateTime: endDateTime
      );
    } catch(e) {
      rethrow;
    }
  }
}