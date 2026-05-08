import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:massa/models/event.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent({
    required String eventName,
    required String eventDescription,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String location,
    required int capacity,
    required int registeredCount,
  }) async {
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

    Event newEvent = Event(
      eventName: eventName, 
      description: eventDescription, 
      startDateTime: startDateTime, 
      endDateTime: endDateTime,
      location: location,
      capacity: capacity,
      registeredCount: registeredCount,
    );

    try {
      await _firestore.collection("events").add(newEvent.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      if (data.containsKey('eventName') && data['eventName'].toString().trim().isEmpty) {
        throw Exception("Event name cannot be empty");
      }
      await _firestore.collection("events").doc(id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection("events").doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // --- NEW: Registration Transaction ---
 Future<void> toggleRegistrationTransaction({
  required String eventId,
  required String userId,
  required bool isRegistering,
}) async {
  final eventRef = _firestore.collection('events').doc(eventId);
  final participantRef = eventRef.collection('participants').doc(userId);
  final userRef = _firestore.collection('users').doc(userId);

  return _firestore.runTransaction((transaction) async {
    // 1. READ: Get Event Data and User Data
    DocumentSnapshot eventSnap = await transaction.get(eventRef);
    DocumentSnapshot userSnap = await transaction.get(userRef);

    if (!eventSnap.exists) throw Exception("Event not found");
    if (!userSnap.exists) throw Exception("User profile not found");

    int currentCount = eventSnap.get('registeredCount') ?? 0;
    int capacity = eventSnap.get('capacity') ?? 100;
    
    // Extract name and matric number from the users collection
    String fullName = userSnap.get('fullName') ?? 'Unknown Student';
    String matricNumber = userSnap.get('matricNumber') ?? 'N/A';

    // 2. LOGIC & WRITE
    if (isRegistering) {
      if (currentCount >= capacity) throw Exception("Event is full!");
      
      transaction.update(eventRef, {'registeredCount': currentCount + 1});
      transaction.set(participantRef, {
        'userId': userId,
        'fullName': fullName,
        'matricNumber': matricNumber,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } else {
      transaction.update(eventRef, {'registeredCount': (currentCount - 1).clamp(0, capacity)});
      transaction.delete(participantRef);
    }
  });
}

  Future<bool> checkUserRegistration(String eventId, String userId) async {
    final doc = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userId)
        .get();
    return doc.exists;
  }

  Future<List<Event>> getAllEvents() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('events').get();
      return snapshot.docs.map((document) {
        final data = document.data() as Map<String, dynamic>;
        return Event.fromMap(data, document.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch events: $e");
    }
  }

  Future<Event> getEventById(String id) async {
    try {
      final doc = await _firestore.collection('events').doc(id).get();
      if (!doc.exists) throw Exception("Event not found");
      return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch(e) {
      throw Exception("Failed to fetch event: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getParticipantsStream(String eventId) {
  return _firestore
      .collection('events')
      .doc(eventId)
      .collection('participants')
      .orderBy('joinedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}

Future<List<String>> getRegisteredEventIds(String userId) async {
  try {
    // This query looks for the user's ID within the participants subcollection 
    // across all events using a Group Query.
    final snapshot = await _firestore
        .collectionGroup('participants')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      // The parent of the participant document is the 'participants' collection,
      // and the parent of that is the specific 'event' document.
      return doc.reference.parent.parent!.id;
    }).toList();
  } catch (e) {
    throw Exception("Failed to fetch registered events: $e");
  }
}
}