import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  String eventName;
  String description;
  DateTime startDateTime;
  DateTime endDateTime;

  Event({
    this.id,
    required this.eventName,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'description': description,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, String documentId) {
    return Event(
      id: documentId,
      eventName: map['eventName'],
      description: map['description'],
      startDateTime: (map['startDateTime'] as Timestamp).toDate(),
      endDateTime: (map['endDateTime'] as Timestamp).toDate(),
    );
  }
}
