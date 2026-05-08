import 'package:massa/models/event.dart';

var mockEventsList = <Event>[
  Event(
      eventName: 'Event 1',
      description: 'This is the description for event 1. Cool, right?',
      startDateTime: DateTime.now().add(Duration(days: 2)),
      endDateTime: DateTime.now().add(Duration(days: 5))
  ),
  Event(
      eventName: 'Event 2',
      description: 'This is the description for event 1. Cool, right?',
      startDateTime: DateTime.now().add(Duration(days: 2)),
      endDateTime: DateTime.now().add(Duration(days: 5))
  ),
  Event(
      eventName: 'Event 3',
      description: 'This is the description for event 1. Cool, right?',
      startDateTime: DateTime.now().add(Duration(days: 2)),
      endDateTime: DateTime.now().add(Duration(days: 5))
  ),
];