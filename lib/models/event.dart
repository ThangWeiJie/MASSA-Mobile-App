import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  String eventName;
  String description;
  DateTime startDateTime;
  DateTime endDateTime;
  String location;       // <-- Added
  int capacity;          // <-- Added
  int registeredCount;   // <-- Added

  Event({
    this.id,
    required this.eventName,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,       // <-- Added
    required this.capacity,       // <-- Added
    required this.registeredCount, // <-- Added
  });

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'description': description,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'location': location,             // <-- Added
      'capacity': capacity,             // <-- Added
      'registeredCount': registeredCount, // <-- Added
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, String documentId) {
    return Event(
      id: documentId,
      eventName: map['eventName'] ?? 'Unknown Event',
      description: map['description'] ?? 'No description provided.',
      startDateTime: (map['startDateTime'] as Timestamp).toDate(),
      endDateTime: (map['endDateTime'] as Timestamp).toDate(),
      // SAFE FALLBACKS: Prevents crashes on old events
      location: map['location'] ?? 'Location TBA', 
      capacity: map['capacity'] ?? 50,             
      registeredCount: map['registeredCount'] ?? 0, 
    );
  }
}