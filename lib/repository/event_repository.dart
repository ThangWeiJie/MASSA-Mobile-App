import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/attendance_record.dart';
import 'package:massa/models/attendance_session.dart';
import 'package:massa/models/crew_application.dart';
import 'package:massa/models/event.dart';
import 'package:massa/models/event_image_upload.dart';
import 'package:massa/models/user.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Random _secureRandom = Random.secure();

  Future<void> createEvent({
    required String eventName,
    required String eventDescription,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String location,
    required int capacity,
    required int registeredCount,
    List<EventImageUpload> images = const [],
    int mainImageIndex = 0,
    bool isCrewRegistrationOpen = false,
    String crewRegistrationDescription = '',
    List<String> crewUnits = const [],
    String crewRequirements = '',
    DateTime? crewRegistrationDeadline,
    String crewContactInfo = '',
    int crewCapacity = 0,
    String crewApplicantInstructions = '',
    String crewWhatsappGroupLink = '',
    String createdByUserId = '',
    String createdByName = '',
  }) async {
    eventName = eventName.trim();
    eventDescription = eventDescription.trim();
    final trimmedCrewDescription = crewRegistrationDescription.trim();
    final trimmedCrewRequirements = crewRequirements.trim();
    final trimmedCrewContactInfo = crewContactInfo.trim();
    final trimmedCrewApplicantInstructions = crewApplicantInstructions.trim();
    final trimmedCrewWhatsappGroupLink = crewWhatsappGroupLink.trim();
    final safeCrewCapacity = crewCapacity < 0 ? 0 : crewCapacity;
    final cleanedCrewUnits = crewUnits
        .map((unit) => unit.trim())
        .where((unit) => unit.isNotEmpty)
        .toList();

    if (eventName.isEmpty || eventDescription.isEmpty) {
      throw Exception("Please enter an event name or description");
    }

    if (isCrewRegistrationOpen &&
        (trimmedCrewDescription.isEmpty || cleanedCrewUnits.isEmpty)) {
      throw Exception(
        "Please add a crew registration description and at least one unit",
      );
    }

    if (isCrewRegistrationOpen &&
        crewRegistrationDeadline != null &&
        crewRegistrationDeadline.isAfter(startDateTime)) {
      throw Exception("Crew registration deadline cannot be after the event");
    }

    if (startDateTime.compareTo(endDateTime) >= 0) {
      throw Exception("Start date cannot be later than end date");
    }

    DateTime currentDateTime = DateTime.now();
    DateTime today = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
    );

    if (startDateTime.isBefore(today) || endDateTime.isBefore(today)) {
      throw Exception(
        "Start date or end date cannot be earlier than current time",
      );
    }

    final safeMainImageIndex = images.isEmpty
        ? 0
        : mainImageIndex.clamp(0, images.length - 1);
    final docRef = _firestore.collection("events").doc();

    try {
      final uploadedImages = await _uploadEventImages(
        eventId: docRef.id,
        images: images,
      );

      Event newEvent = Event(
        eventName: eventName,
        description: eventDescription,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: location,
        capacity: capacity,
        registeredCount: registeredCount,
        imageUrls: uploadedImages.map((image) => image.downloadUrl).toList(),
        imageStoragePaths: uploadedImages
            .map((image) => image.storagePath)
            .toList(),
        mainImageIndex: safeMainImageIndex,
        isCrewRegistrationOpen: isCrewRegistrationOpen,
        crewRegistrationDescription: trimmedCrewDescription,
        crewUnits: cleanedCrewUnits,
        crewRequirements: trimmedCrewRequirements,
        crewRegistrationDeadline: crewRegistrationDeadline,
        crewContactInfo: trimmedCrewContactInfo,
        crewCapacity: safeCrewCapacity,
        crewApplicantInstructions: trimmedCrewApplicantInstructions,
        crewWhatsappGroupLink: trimmedCrewWhatsappGroupLink,
        createdByUserId: createdByUserId,
        createdByName: createdByName,
      );

      await docRef.set(newEvent.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      if (data.containsKey('eventName') &&
          data['eventName'].toString().trim().isEmpty) {
        throw Exception("Event name cannot be empty");
      }
      await _firestore.collection("events").doc(id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      final doc = await _firestore.collection("events").doc(id).get();
      final data = doc.data();
      final storagePaths =
          (data?['imageStoragePaths'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          <String>[];

      for (final storagePath in storagePaths) {
        await _deleteStorageFile(storagePath);
      }

      await _firestore.collection("events").doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<({String downloadUrl, String storagePath})>> _uploadEventImages({
    required String eventId,
    required List<EventImageUpload> images,
  }) async {
    final uploadedImages = <({String downloadUrl, String storagePath})>[];

    for (final image in images) {
      final safeFileName = _sanitizeFileName(image.fileName);
      final storagePath =
          'event_images/$eventId/${DateTime.now().microsecondsSinceEpoch}_$safeFileName';
      final imageRef = _storage.ref().child(storagePath);
      final metadata = SettableMetadata(contentType: image.contentType);
      final uploadTask = await imageRef.putData(image.bytes, metadata);

      uploadedImages.add((
        downloadUrl: await uploadTask.ref.getDownloadURL(),
        storagePath: storagePath,
      ));
    }

    return uploadedImages;
  }

  Future<void> _deleteStorageFile(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  String _sanitizeFileName(String fileName) {
    final trimmed = fileName.trim();
    final normalized = trimmed.isEmpty ? 'event_image' : trimmed;
    return normalized.replaceAll(RegExp(r'[\\/#?%*:|"<>]'), '_');
  }

  CollectionReference<Map<String, dynamic>> _crewApplicationsCollection(
    String eventId,
  ) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('crewApplications');
  }

  Stream<CrewApplication?> streamUserCrewApplication({
    required String eventId,
    required String userId,
  }) {
    return _crewApplicationsCollection(eventId).doc(userId).snapshots().map((
      doc,
    ) {
      if (!doc.exists || doc.data() == null) return null;

      return CrewApplication.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<CrewApplication>> streamCrewApplications(String eventId) {
    return _crewApplicationsCollection(
      eventId,
    ).orderBy('appliedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CrewApplication.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> applyForCrew({
    required String eventId,
    required UserModel applicant,
    required String firstChoiceUnit,
    required String secondChoiceUnit,
    required String pitch,
    required bool commitmentAccepted,
  }) async {
    final trimmedPitch = pitch.trim();
    final trimmedFirstChoice = firstChoiceUnit.trim();
    final trimmedSecondChoice = secondChoiceUnit.trim();

    if (trimmedFirstChoice.isEmpty) {
      throw Exception('Please choose your first choice unit.');
    }

    if (trimmedSecondChoice.isNotEmpty &&
        trimmedSecondChoice == trimmedFirstChoice) {
      throw Exception('Second choice must be different from first choice.');
    }

    if (trimmedPitch.isEmpty) {
      throw Exception('Please write a short pitch or past experience.');
    }

    if (_wordCount(trimmedPitch) > 300) {
      throw Exception('Please keep your pitch under 300 words.');
    }

    if (!commitmentAccepted) {
      throw Exception('Please confirm the commitment check.');
    }

    final event = await getEventById(eventId);

    if (!event.isCrewRegistrationAvailable) {
      throw Exception('Crew registration is closed.');
    }

    if (!event.crewUnits.contains(trimmedFirstChoice)) {
      throw Exception('Selected unit is no longer available.');
    }

    if (trimmedSecondChoice.isNotEmpty &&
        !event.crewUnits.contains(trimmedSecondChoice)) {
      throw Exception('Selected second choice is no longer available.');
    }

    final applicationRef = _crewApplicationsCollection(
      eventId,
    ).doc(applicant.uuid);
    final existingApplication = await applicationRef.get();

    if (existingApplication.exists) {
      throw Exception('You have already submitted a crew application.');
    }

    final now = DateTime.now();
    final application = CrewApplication(
      id: applicant.uuid,
      userId: applicant.uuid,
      fullName: applicant.fullName,
      email: applicant.email,
      matricNumber: applicant.matricNumber ?? '',
      phone: applicant.phone,
      department: applicant.department,
      firstChoiceUnit: trimmedFirstChoice,
      secondChoiceUnit: trimmedSecondChoice,
      pitch: trimmedPitch,
      commitmentAccepted: commitmentAccepted,
      status: CrewApplicationStatus.pending,
      assignedUnit: '',
      inviteLink: '',
      appliedAt: now,
      updatedAt: now,
    );

    await applicationRef.set(application.toMap());

    if (event.createdByUserId.isNotEmpty) {
      await _tryCreateNotification(
        userId: event.createdByUserId,
        title: 'New crew application',
        message:
            '${applicant.fullName} applied to join ${event.eventName} as crew.',
        eventId: eventId,
        type: 'crew_application_submitted',
        metadata: {
          'applicationId': applicant.uuid,
          'firstChoiceUnit': trimmedFirstChoice,
          'secondChoiceUnit': trimmedSecondChoice,
        },
      );
    }
  }

  Future<void> decideCrewApplication({
    required String eventId,
    required String applicationId,
    required CrewApplicationStatus status,
    required String assignedUnit,
    required UserModel reviewer,
  }) async {
    final event = await getEventById(eventId);
    final applicationRef = _crewApplicationsCollection(
      eventId,
    ).doc(applicationId);
    final applicationSnapshot = await applicationRef.get();

    if (!applicationSnapshot.exists || applicationSnapshot.data() == null) {
      throw Exception('Crew application not found.');
    }

    final application = CrewApplication.fromMap(
      applicationSnapshot.data()!,
      applicationSnapshot.id,
    );

    final trimmedAssignedUnit = assignedUnit.trim();
    final now = DateTime.now();
    final inviteLink = status == CrewApplicationStatus.accepted
        ? event.crewWhatsappGroupLink
        : '';

    if (status == CrewApplicationStatus.accepted &&
        trimmedAssignedUnit.isEmpty) {
      throw Exception('Please choose an assigned unit.');
    }

    await applicationRef.update({
      'status': status.name,
      'assignedUnit': status == CrewApplicationStatus.accepted
          ? trimmedAssignedUnit
          : '',
      'inviteLink': inviteLink,
      'reviewedByUserId': reviewer.uuid,
      'reviewedByName': reviewer.fullName,
      'decidedAt': now,
      'updatedAt': now,
    });

    await _tryCreateNotification(
      userId: application.userId,
      title: _decisionNotificationTitle(status),
      message: _decisionNotificationMessage(
        status: status,
        eventName: event.eventName,
        assignedUnit: trimmedAssignedUnit,
      ),
      eventId: eventId,
      type: 'crew_application_${status.name}',
      linkUrl: inviteLink,
      metadata: {
        'applicationId': applicationId,
        'assignedUnit': trimmedAssignedUnit,
        'status': status.name,
      },
    );
  }

  Future<void> _tryCreateNotification({
    required String userId,
    required String title,
    required String message,
    required String eventId,
    required String type,
    String linkUrl = '',
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      await _createNotification(
        userId: userId,
        title: title,
        message: message,
        eventId: eventId,
        type: type,
        linkUrl: linkUrl,
        metadata: metadata,
      );
    } catch (e, stack) {
      developer.log(
        'Notification creation failed',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String eventId,
    required String type,
    String linkUrl = '',
    Map<String, dynamic> metadata = const {},
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'eventId': eventId,
      'type': type,
      'linkUrl': linkUrl,
      'metadata': metadata,
      'isRead': false,
      'createdAt': DateTime.now(),
    });
  }

  int _wordCount(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
  }

  String _decisionNotificationTitle(CrewApplicationStatus status) {
    switch (status) {
      case CrewApplicationStatus.accepted:
        return 'Crew application accepted';
      case CrewApplicationStatus.declined:
        return 'Crew application update';
      case CrewApplicationStatus.waitlisted:
        return 'Crew application waitlisted';
      case CrewApplicationStatus.pending:
        return 'Crew application pending';
    }
  }

  String _decisionNotificationMessage({
    required CrewApplicationStatus status,
    required String eventName,
    required String assignedUnit,
  }) {
    switch (status) {
      case CrewApplicationStatus.accepted:
        return 'Congratulations! You have been accepted into the $assignedUnit team for $eventName.';
      case CrewApplicationStatus.declined:
        return 'Thank you for your interest in $eventName. The crew quota is currently full.';
      case CrewApplicationStatus.waitlisted:
        return 'Your crew application for $eventName has been kept in view. We will update you if a slot opens.';
      case CrewApplicationStatus.pending:
        return 'Your crew application for $eventName is pending review.';
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

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. READ: Get Event Data and User Data
        DocumentSnapshot eventSnap = await transaction.get(eventRef);
        DocumentSnapshot userSnap = await transaction.get(userRef);
        final participantSnap = await transaction.get(participantRef);

        if (!eventSnap.exists) throw Exception("Event not found");
        if (!userSnap.exists) throw Exception("User profile not found");

        final eventData = eventSnap.data() as Map<String, dynamic>;
        final userData = userSnap.data() as Map<String, dynamic>;

        int currentCount = (eventData['registeredCount'] as num? ?? 0).toInt();
        int capacity = (eventData['capacity'] as num? ?? 100).toInt();
        bool alreadyRegistered = participantSnap.exists;

        // 2. LOGIC & WRITE
        if (isRegistering) {
          if (alreadyRegistered) return;

          if (currentCount >= capacity) throw Exception("Event is full!");

          transaction.update(eventRef, {'registeredCount': currentCount + 1});
          transaction.set(participantRef, {
            'userId': userId,
            'fullName': userData['fullName'] ?? 'Unknown Student',
            'matricNumber': userData['matricNumber'] ?? 'N/A',
            'joinedAt': FieldValue.serverTimestamp(),
          });
        } else {
          if (!alreadyRegistered) return;

          transaction.update(eventRef, {
            'registeredCount': ((currentCount - 1).clamp(0, capacity)).toInt(),
          });
          transaction.delete(participantRef);
        }
      });
    } catch (e, stack) {
      developer.log(
        'Registration transaction failed',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
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
      final QuerySnapshot snapshot = await _firestore
          .collection('events')
          .get();
      return snapshot.docs.map((document) {
        final data = document.data() as Map<String, dynamic>;
        return Event.fromMap(data, document.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch events: $e");
    }
  }

  Stream<List<Event>> streamAllEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();
        return Event.fromMap(data, document.id);
      }).toList();
    });
  }

  Future<Event> getEventById(String id) async {
    try {
      final doc = await _firestore.collection('events').doc(id).get();
      if (!doc.exists) throw Exception("Event not found");
      return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception("Failed to fetch event: $e");
    }
  }

  Stream<Event> streamEventById(String id) {
    return _firestore.collection('events').doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception("Event not found");
      }
      return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<bool> streamUserRegistration(String eventId, String userId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
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

  CollectionReference<Map<String, dynamic>> _attendanceSessionsCollection(
    String eventId,
  ) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('attendanceSessions');
  }

  CollectionReference<Map<String, dynamic>> _attendanceRecordsCollection(
    String eventId,
  ) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('attendanceRecords');
  }

  Stream<List<AttendanceSession>> streamAttendanceSessions(String eventId) {
    return _attendanceSessionsCollection(eventId).snapshots().map((snapshot) {
      final sessions = snapshot.docs
          .map((doc) => AttendanceSession.fromMap(doc.data(), doc.id))
          .toList();
      sessions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return sessions;
    });
  }

  Stream<List<AttendanceRecord>> streamAttendanceRecords(String eventId) {
    return _attendanceRecordsCollection(eventId).snapshots().map((snapshot) {
      final records = snapshot.docs
          .map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id))
          .toList();
      records.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return records;
    });
  }

  Future<AttendanceSession> generateAttendanceSession({
    required String eventId,
    required UserModel requester,
    required int durationMinutes,
  }) async {
    if (![5, 10, 15].contains(durationMinutes)) {
      throw Exception('Please choose a duration of 5, 10, or 15 minutes.');
    }

    final eventRef = _firestore.collection('events').doc(eventId);
    final requesterRef = _firestore.collection('users').doc(requester.uuid);
    final checkInRef = _attendanceSessionsCollection(eventId).doc('check_in');
    final checkOutRef = _attendanceSessionsCollection(eventId).doc('check_out');

    return _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      final requesterSnapshot = await transaction.get(requesterRef);
      final checkInSnapshot = await transaction.get(checkInRef);
      final checkOutSnapshot = await transaction.get(checkOutRef);

      if (!eventSnapshot.exists || eventSnapshot.data() == null) {
        throw Exception('Event not found.');
      }

      _assertCanManageAttendance(
        eventData: eventSnapshot.data()!,
        requesterId: requester.uuid,
        requesterData: requesterSnapshot.data(),
      );

      final generatedCount =
          (eventSnapshot.data()!['attendanceSessionGenerationCount'] as num?)
              ?.toInt() ??
          (checkInSnapshot.exists ? 1 : 0) + (checkOutSnapshot.exists ? 1 : 0);

      if (generatedCount >= 2 || checkOutSnapshot.exists) {
        throw Exception(
          'Maximum 2 attendance sessions already generated for this event.',
        );
      }

      final now = DateTime.now();
      AttendanceType type;
      DocumentReference<Map<String, dynamic>> sessionRef;

      if (!checkInSnapshot.exists) {
        type = AttendanceType.checkIn;
        sessionRef = checkInRef;
      } else {
        final firstSession = AttendanceSession.fromMap(
          checkInSnapshot.data()!,
          checkInSnapshot.id,
        );
        if (now.isBefore(firstSession.expiresAt)) {
          throw Exception(
            'First QR session must expire before generating the second QR.',
          );
        }
        type = AttendanceType.checkOut;
        sessionRef = checkOutRef;
      }

      final session = AttendanceSession(
        id: sessionRef.id,
        eventId: eventId,
        type: type,
        manualCode: _generateManualCode(),
        createdAt: now,
        expiresAt: now.add(Duration(minutes: durationMinutes)),
        generatedByUserId: requester.uuid,
        generatedByName: requester.fullName,
        durationMinutes: durationMinutes,
      );

      transaction.set(sessionRef, session.toMap());
      transaction.update(eventRef, {
        'attendanceSessionGenerationCount': generatedCount + 1,
        'activeAttendanceSessionId': session.id,
        'activeAttendanceSessionExpiresAt': Timestamp.fromDate(
          session.expiresAt,
        ),
      });

      return session;
    });
  }

  Future<AttendanceRecord> submitAttendance({
    required String eventId,
    required UserModel student,
    required String sessionId,
    required String code,
    required AttendanceMethod method,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    final eventRef = _firestore.collection('events').doc(eventId);
    final participantRef = eventRef
        .collection('participants')
        .doc(student.uuid);
    final sessionRef = _attendanceSessionsCollection(eventId).doc(sessionId);
    final recordRef = _attendanceRecordsCollection(
      eventId,
    ).doc(AttendanceRecord.documentId(sessionId, student.uuid));

    developer.log(
      'Submitting attendance: eventId=$eventId, sessionId=$sessionId, '
      'userId=${student.uuid}, recordId=${recordRef.id}, '
      'method=${method.value}, path=${recordRef.path}',
      name: 'EventRepository.attendance',
    );

    try {
      return await _firestore.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);
        final participantSnapshot = await transaction.get(participantRef);
        final sessionSnapshot = await transaction.get(sessionRef);
        final recordSnapshot = await transaction.get(recordRef);

        if (!eventSnapshot.exists) {
          throw Exception('The selected event no longer exists.');
        }
        if (!participantSnapshot.exists) {
          throw Exception('Please register for this event before attendance.');
        }
        if (!sessionSnapshot.exists || sessionSnapshot.data() == null) {
          throw Exception('Attendance session is not active.');
        }

        final session = AttendanceSession.fromMap(
          sessionSnapshot.data()!,
          sessionSnapshot.id,
        );
        developer.log(
          'Validated attendance session: eventId=${session.eventId}, '
          'sessionId=${session.id}, type=${session.type.value}, '
          'expiresAt=${session.expiresAt.toIso8601String()}',
          name: 'EventRepository.attendance',
        );

        if (session.eventId != eventId) {
          throw Exception('This attendance QR belongs to another event.');
        }
        if (session.manualCode.toUpperCase() != normalizedCode) {
          throw Exception('Invalid attendance code.');
        }
        if (session.isExpired) {
          throw Exception('Attendance QR has expired.');
        }
        if (recordSnapshot.exists) {
          throw Exception(
            'You have already submitted attendance for this session.',
          );
        }

        final record = AttendanceRecord(
          id: recordRef.id,
          eventId: eventId,
          sessionId: session.id,
          userId: student.uuid,
          studentName: student.fullName,
          matricNumber: student.matricNumber ?? '',
          type: session.type,
          submittedAt: DateTime.now(),
          method: method,
        );
        developer.log(
          'Writing attendance record: eventId=${record.eventId}, '
          'sessionId=${record.sessionId}, userId=${record.userId}, '
          'recordId=${record.id}, type=${record.type.value}, '
          'method=${record.method.value}, path=${recordRef.path}',
          name: 'EventRepository.attendance',
        );
        transaction.set(recordRef, record.toMap());
        return record;
      });
    } on FirebaseException catch (error, stackTrace) {
      developer.log(
        'Attendance submission failed: code=${error.code}, '
        'message=${error.message}, eventId=$eventId, sessionId=$sessionId, '
        'userId=${student.uuid}, recordId=${recordRef.id}, '
        'method=${method.value}, path=${recordRef.path}',
        name: 'EventRepository.attendance',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_attendanceFirebaseErrorMessage(error));
    }
  }

  Future<AttendanceRecord> submitAttendanceCode({
    required String eventId,
    required UserModel student,
    required String code,
    required AttendanceMethod method,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw Exception('Please enter an attendance code.');
    }

    developer.log(
      'Looking up manual attendance code: eventId=$eventId, '
      'userId=${student.uuid}, method=${method.value}, '
      'path=events/$eventId/attendanceSessions',
      name: 'EventRepository.attendance',
    );

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _attendanceSessionsCollection(
        eventId,
      ).where('manualCode', isEqualTo: normalizedCode).limit(1).get();
    } on FirebaseException catch (error, stackTrace) {
      developer.log(
        'Attendance code lookup failed: code=${error.code}, '
        'message=${error.message}, eventId=$eventId, '
        'userId=${student.uuid}, method=${method.value}',
        name: 'EventRepository.attendance',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(_attendanceFirebaseErrorMessage(error));
    }

    if (snapshot.docs.isEmpty) {
      throw Exception('Invalid attendance code.');
    }

    return submitAttendance(
      eventId: eventId,
      student: student,
      sessionId: snapshot.docs.first.id,
      code: normalizedCode,
      method: method,
    );
  }

  Future<void> upsertAttendanceRecord({
    required String eventId,
    required UserModel requester,
    required String studentUserId,
    required AttendanceType type,
    DateTime? submittedAt,
  }) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final requesterRef = _firestore.collection('users').doc(requester.uuid);
    final participantRef = eventRef
        .collection('participants')
        .doc(studentUserId);
    final sessionRef = _attendanceSessionsCollection(eventId).doc(type.value);
    final recordRef = _attendanceRecordsCollection(
      eventId,
    ).doc(AttendanceRecord.documentId(type.value, studentUserId));

    await _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      final requesterSnapshot = await transaction.get(requesterRef);
      final participantSnapshot = await transaction.get(participantRef);
      final sessionSnapshot = await transaction.get(sessionRef);

      if (!eventSnapshot.exists || eventSnapshot.data() == null) {
        throw Exception('Event not found.');
      }
      _assertCanManageAttendance(
        eventData: eventSnapshot.data()!,
        requesterId: requester.uuid,
        requesterData: requesterSnapshot.data(),
      );
      if (!participantSnapshot.exists || participantSnapshot.data() == null) {
        throw Exception('The student is not registered for this event.');
      }
      if (!sessionSnapshot.exists) {
        throw Exception('${type.label} session has not been generated yet.');
      }

      final participant = participantSnapshot.data()!;
      final record = AttendanceRecord(
        id: recordRef.id,
        eventId: eventId,
        sessionId: sessionRef.id,
        userId: studentUserId,
        studentName: participant['fullName']?.toString() ?? 'Unknown Student',
        matricNumber: participant['matricNumber']?.toString() ?? '',
        type: type,
        submittedAt: submittedAt ?? DateTime.now(),
        method: AttendanceMethod.admin,
      );
      transaction.set(recordRef, record.toMap());
    });
  }

  Future<void> deleteAttendanceRecord({
    required String eventId,
    required UserModel requester,
    required String recordId,
  }) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final requesterRef = _firestore.collection('users').doc(requester.uuid);
    final recordRef = _attendanceRecordsCollection(eventId).doc(recordId);

    await _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);
      final requesterSnapshot = await transaction.get(requesterRef);
      if (!eventSnapshot.exists || eventSnapshot.data() == null) {
        throw Exception('Event not found.');
      }
      _assertCanManageAttendance(
        eventData: eventSnapshot.data()!,
        requesterId: requester.uuid,
        requesterData: requesterSnapshot.data(),
      );
      transaction.delete(recordRef);
    });
  }

  void _assertCanManageAttendance({
    required Map<String, dynamic> eventData,
    required String requesterId,
    required Map<String, dynamic>? requesterData,
  }) {
    final roleName = requesterData?['role']?.toString() ?? '';
    final isManager = roleName == Role.admin.name || roleName == Role.exco.name;
    final isCreator = eventData['createdByUserId'] == requesterId;
    if (!isManager && !isCreator) {
      throw Exception(
        'Only Admin, EXCO, or the event creator can manage attendance.',
      );
    }
  }

  String _generateManualCode() {
    final number = 1000 + _secureRandom.nextInt(9000);
    return 'MASSA-$number';
  }

  String _attendanceFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Attendance could not be submitted. Confirm that you are '
            'registered for this event and that the latest Firestore rules '
            'have been deployed.';
      case 'unavailable':
        return 'Attendance service is temporarily unavailable. Check your '
            'internet connection and try again.';
      case 'deadline-exceeded':
        return 'Attendance validation took too long. Please try again.';
      case 'not-found':
        return 'The attendance session is no longer available.';
      default:
        return 'Attendance could not be submitted. Please try again.';
    }
  }

  Stream<List<String>> streamRegisteredEventIds(String userId) {
    late StreamController<List<String>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? eventsSubscription;
    final participantSubscriptions =
        <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
    final registeredEventIds = <String>{};
    var activeEventIds = <String>{};

    void emitRegisteredIds() {
      if (!controller.isClosed) {
        controller.add(registeredEventIds.toList());
      }
    }

    void syncParticipantSubscriptions(
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      final nextEventIds = snapshot.docs.map((doc) => doc.id).toSet();

      for (final removedEventId in activeEventIds.difference(nextEventIds)) {
        participantSubscriptions.remove(removedEventId)?.cancel();
        registeredEventIds.remove(removedEventId);
      }

      for (final eventId in nextEventIds.difference(activeEventIds)) {
        participantSubscriptions[eventId] = _firestore
            .collection('events')
            .doc(eventId)
            .collection('participants')
            .doc(userId)
            .snapshots()
            .listen(
              (participantDoc) {
                if (participantDoc.exists) {
                  registeredEventIds.add(eventId);
                } else {
                  registeredEventIds.remove(eventId);
                }
                emitRegisteredIds();
              },
              onError: (error, stackTrace) {
                developer.log(
                  'Registered event participant stream failed',
                  error: error,
                  stackTrace: stackTrace,
                );
                registeredEventIds.remove(eventId);
                emitRegisteredIds();
              },
            );
      }

      activeEventIds = nextEventIds;
      emitRegisteredIds();
    }

    controller = StreamController<List<String>>(
      onListen: () {
        eventsSubscription = _firestore
            .collection('events')
            .snapshots()
            .listen(syncParticipantSubscriptions, onError: controller.addError);
      },
      onCancel: () async {
        await eventsSubscription?.cancel();
        for (final subscription in participantSubscriptions.values) {
          await subscription.cancel();
        }
        participantSubscriptions.clear();
      },
    );

    return controller.stream;
  }

  Future<List<String>> getRegisteredEventIds(String userId) async {
    try {
      return _getParticipantEventIds(userId);
    } catch (e) {
      throw Exception("Failed to fetch registered events: $e");
    }
  }

  Future<List<String>> _getParticipantEventIds(String userId) async {
    // This query looks for the user's ID within the participants subcollection
    // across all events using a Group Query.
    try {
      final snapshot = await _firestore
          .collectionGroup('participants')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        // The parent of the participant document is the 'participants'
        // collection, and the parent of that is the specific event document.
        return doc.reference.parent.parent!.id;
      }).toList();
    } catch (e, stack) {
      developer.log(
        'Registered events collection group query failed',
        error: e,
        stackTrace: stack,
      );
      return _getParticipantEventIdsByScanningEvents(userId);
    }
  }

  Future<List<String>> _getParticipantEventIdsByScanningEvents(
    String userId,
  ) async {
    final eventsSnapshot = await _firestore.collection('events').get();
    final eventIds = <String>[];

    for (final eventDoc in eventsSnapshot.docs) {
      final participantDoc = await eventDoc.reference
          .collection('participants')
          .doc(userId)
          .get();

      if (participantDoc.exists) {
        eventIds.add(eventDoc.id);
      }
    }

    return eventIds;
  }
}
