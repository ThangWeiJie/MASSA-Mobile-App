import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  String eventName;
  String description;
  DateTime startDateTime;
  DateTime endDateTime;
  String location; // <-- Added
  int capacity; // <-- Added
  int registeredCount; // <-- Added
  List<String> imageUrls;
  List<String> imageStoragePaths;
  int mainImageIndex;
  bool isCrewRegistrationOpen;
  String crewRegistrationDescription;
  List<String> crewUnits;
  String crewRequirements;
  DateTime? crewRegistrationDeadline;
  String crewContactInfo;
  int crewCapacity;
  String crewApplicantInstructions;
  String crewWhatsappGroupLink;
  String createdByUserId;
  String createdByName;

  Event({
    this.id,
    required this.eventName,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.location, // <-- Added
    required this.capacity, // <-- Added
    required this.registeredCount, // <-- Added
    this.imageUrls = const [],
    this.imageStoragePaths = const [],
    this.mainImageIndex = 0,
    this.isCrewRegistrationOpen = false,
    this.crewRegistrationDescription = '',
    this.crewUnits = const [],
    this.crewRequirements = '',
    this.crewRegistrationDeadline,
    this.crewContactInfo = '',
    this.crewCapacity = 0,
    this.crewApplicantInstructions = '',
    this.crewWhatsappGroupLink = '',
    this.createdByUserId = '',
    this.createdByName = '',
  });

  String? get mainImageUrl {
    if (imageUrls.isEmpty) return null;
    final safeIndex = _safeMainImageIndex(imageUrls, mainImageIndex);
    return imageUrls[safeIndex];
  }

  List<String> get displayImageUrls {
    if (imageUrls.isEmpty) return const [];

    final images = List<String>.from(imageUrls);
    final safeIndex = _safeMainImageIndex(images, mainImageIndex);
    final mainImage = images.removeAt(safeIndex);
    return [mainImage, ...images];
  }

  bool get isCrewRegistrationAvailable {
    if (!isCrewRegistrationOpen) return false;
    if (crewRegistrationDeadline == null) return true;

    final deadline = crewRegistrationDeadline!;
    final deadlineEnd = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      23,
      59,
      59,
    );

    return !DateTime.now().isAfter(deadlineEnd);
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'description': description,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'location': location, // <-- Added
      'capacity': capacity, // <-- Added
      'registeredCount': registeredCount, // <-- Added
      'imageUrls': imageUrls,
      'imageStoragePaths': imageStoragePaths,
      'mainImageIndex': mainImageIndex,
      'isCrewRegistrationOpen': isCrewRegistrationOpen,
      'crewRegistrationDescription': crewRegistrationDescription,
      'crewUnits': crewUnits,
      'crewRequirements': crewRequirements,
      'crewRegistrationDeadline': crewRegistrationDeadline,
      'crewContactInfo': crewContactInfo,
      'crewCapacity': crewCapacity,
      'crewApplicantInstructions': crewApplicantInstructions,
      'crewWhatsappGroupLink': crewWhatsappGroupLink,
      'createdByUserId': createdByUserId,
      'createdByName': createdByName,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, String documentId) {
    final imageUrls =
        (map['imageUrls'] as List<dynamic>?)?.whereType<String>().toList() ??
        <String>[];
    final imageStoragePaths =
        (map['imageStoragePaths'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        <String>[];
    final mainImageIndex = _safeMainImageIndex(
      imageUrls,
      (map['mainImageIndex'] as num?)?.toInt() ?? 0,
    );
    final crewUnits =
        (map['crewUnits'] as List<dynamic>?)?.whereType<String>().toList() ??
        <String>[];
    final crewRegistrationDeadline =
        map['crewRegistrationDeadline'] is Timestamp
        ? (map['crewRegistrationDeadline'] as Timestamp).toDate()
        : null;

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
      imageUrls: imageUrls,
      imageStoragePaths: imageStoragePaths,
      mainImageIndex: mainImageIndex,
      isCrewRegistrationOpen: map['isCrewRegistrationOpen'] ?? false,
      crewRegistrationDescription: map['crewRegistrationDescription'] ?? '',
      crewUnits: crewUnits,
      crewRequirements: map['crewRequirements'] ?? '',
      crewRegistrationDeadline: crewRegistrationDeadline,
      crewContactInfo: map['crewContactInfo'] ?? '',
      crewCapacity: (map['crewCapacity'] as num?)?.toInt() ?? 0,
      crewApplicantInstructions: map['crewApplicantInstructions'] ?? '',
      crewWhatsappGroupLink: map['crewWhatsappGroupLink'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      createdByName: map['createdByName'] ?? '',
    );
  }

  static int _safeMainImageIndex(List<String> images, int index) {
    if (images.isEmpty) return 0;
    return index.clamp(0, images.length - 1);
  }
}
