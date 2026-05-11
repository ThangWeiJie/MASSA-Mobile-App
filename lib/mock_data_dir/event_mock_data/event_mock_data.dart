import 'package:massa/models/event.dart';

var mockEventsList = <Event>[
  Event(
    eventName: 'Annual Tech Meetup',
    description: 'Join us for our annual tech meetup where we discuss the latest trends in Flutter and mobile development.',
    startDateTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
    endDateTime: DateTime.now().add(const Duration(days: 2, hours: 6)),
    location: 'Dewan Sultan Iskandar',
    capacity: 100,
    registeredCount: 45,
  ),
  Event(
    eventName: 'Community Cleanup Drive',
    description: 'A brief morning event to help clean up the local park. Gloves and trash bags will be provided.',
    startDateTime: DateTime.now().add(const Duration(days: 5)),
    endDateTime: DateTime.now().add(const Duration(days: 5, hours: 3)),
    location: 'Taman Merdeka',
    capacity: 50,
    registeredCount: 12,
  ),
  Event(
    eventName: 'Leadership Workshop',
    description: 'An intensive workshop focusing on team management and agile methodologies for student leaders.',
    startDateTime: DateTime.now().add(const Duration(days: 14)),
    endDateTime: DateTime.now().add(const Duration(days: 17)),
    location: 'Seminar Room 2, Block L50',
    capacity: 30,
    registeredCount: 30, // Showcasing a full event
  ),
];