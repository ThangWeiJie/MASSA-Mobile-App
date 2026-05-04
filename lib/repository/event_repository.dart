import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:massa/models/event.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(
      {
        required String eventName,
        required String eventDescription,
        required DateTime startDateTime,
        required DateTime endDateTime
      }
      ) async {

    eventName = eventName.trim();
    eventDescription = eventDescription.trim();

    if (eventName.isEmpty || eventDescription.isEmpty) {
      throw Exception("Please enter an event name or description");
    }

    if (startDateTime.compareTo(endDateTime) >= 0) {
      throw Exception("Start date cannot be later than end date");
    }

    DateTime currentDateTime = DateTime.now();
    DateTime today = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);

    if (startDateTime.isBefore(today) || endDateTime.isBefore(today)) {
      throw Exception("Start date or end date cannot be earlier than current time");
    }

    Event newEvent = Event(eventName: eventName, description: eventDescription, startDateTime: startDateTime, endDateTime: endDateTime);

    try {
      await _firestore.collection("events").add(newEvent.toMap());
    } catch (e) {
      rethrow;
    }
  }
}