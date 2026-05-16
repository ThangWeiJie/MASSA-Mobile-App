import 'dart:developer' as developer;

import 'package:massa/models/crew_application.dart';
import 'package:massa/models/event.dart';
import 'package:massa/models/event_image_upload.dart';
import 'package:massa/models/user.dart';
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
    try {
      await eventRepository.createEvent(
        eventName: eventName,
        eventDescription: eventDescription,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: location,
        capacity: capacity,
        registeredCount: registeredCount,
        images: images,
        mainImageIndex: mainImageIndex,
        isCrewRegistrationOpen: isCrewRegistrationOpen,
        crewRegistrationDescription: crewRegistrationDescription,
        crewUnits: crewUnits,
        crewRequirements: crewRequirements,
        crewRegistrationDeadline: crewRegistrationDeadline,
        crewContactInfo: crewContactInfo,
        crewCapacity: crewCapacity,
        crewApplicantInstructions: crewApplicantInstructions,
        crewWhatsappGroupLink: crewWhatsappGroupLink,
        createdByUserId: createdByUserId,
        createdByName: createdByName,
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
    try {
      await eventRepository.toggleRegistrationTransaction(
        eventId: eventId,
        userId: userId,
        isRegistering: isJoining,
      );
    } catch (e, stack) {
      developer.log(
        'Event registration action failed',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
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

  Stream<CrewApplication?> streamUserCrewApplication({
    required String eventId,
    required String userId,
  }) {
    return eventRepository.streamUserCrewApplication(
      eventId: eventId,
      userId: userId,
    );
  }

  Stream<List<CrewApplication>> streamCrewApplications(String eventId) {
    return eventRepository.streamCrewApplications(eventId);
  }

  Future<void> applyForCrew({
    required String eventId,
    required UserModel applicant,
    required String firstChoiceUnit,
    required String secondChoiceUnit,
    required String pitch,
    required bool commitmentAccepted,
  }) async {
    await eventRepository.applyForCrew(
      eventId: eventId,
      applicant: applicant,
      firstChoiceUnit: firstChoiceUnit,
      secondChoiceUnit: secondChoiceUnit,
      pitch: pitch,
      commitmentAccepted: commitmentAccepted,
    );
  }

  Future<void> decideCrewApplication({
    required String eventId,
    required String applicationId,
    required CrewApplicationStatus status,
    required String assignedUnit,
    required UserModel reviewer,
  }) async {
    await eventRepository.decideCrewApplication(
      eventId: eventId,
      applicationId: applicationId,
      status: status,
      assignedUnit: assignedUnit,
      reviewer: reviewer,
    );
  }

  Stream<List<Map<String, dynamic>>> getEventParticipants(String eventId) {
    return eventRepository.getParticipantsStream(eventId);
  }

  Stream<List<String>> streamRegisteredEventIds(String userId) {
    return eventRepository.streamRegisteredEventIds(userId);
  }
}
