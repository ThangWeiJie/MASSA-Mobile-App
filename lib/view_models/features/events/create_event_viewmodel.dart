import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:massa/models/event_image_upload.dart';
import 'package:massa/service/features/events/event_service.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventService eventService;
  final String createdByUserId;
  final String createdByName;

  // 1. Data Objects (The "Source of Truth")
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  // 2. Controllers (For UI display only)
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endDateController = TextEditingController();
  final endTimeController = TextEditingController();
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  final crewRegistrationDescriptionController = TextEditingController();
  final crewUnitController = TextEditingController();
  final crewRequirementsController = TextEditingController();
  final crewRegistrationDeadlineController = TextEditingController();
  final crewContactInfoController = TextEditingController();
  final crewCapacityController = TextEditingController();
  final crewApplicantInstructionsController = TextEditingController();
  final crewWhatsappGroupLinkController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<PlatformFile> _selectedImages = [];
  List<PlatformFile> get selectedImages => List.unmodifiable(_selectedImages);

  int _mainImageIndex = 0;
  int get mainImageIndex => _mainImageIndex;

  bool _isCrewRegistrationOpen = false;
  bool get isCrewRegistrationOpen => _isCrewRegistrationOpen;

  final List<String> _crewUnits = [];
  List<String> get crewUnits => List.unmodifiable(_crewUnits);

  DateTime? _crewRegistrationDeadline;
  DateTime? get crewRegistrationDeadline => _crewRegistrationDeadline;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreateEventViewModel({
    required this.eventService,
    this.createdByUserId = '',
    this.createdByName = '',
  }) {
    _updateTextFields();
  }

  // 3. Computed Getters (To send to Service)
  DateTime get startDateTime => DateTime(
    _startDate.year,
    _startDate.month,
    _startDate.day,
    _startTime.hour,
    _startTime.minute,
  );

  DateTime get endDateTime => DateTime(
    _endDate.year,
    _endDate.month,
    _endDate.day,
    _endTime.hour,
    _endTime.minute,
  );

  // 4. Picker Methods
  Future<void> selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
      _updateTextFields();
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
      _updateTextFields();
      notifyListeners();
    }
  }

  void _updateTextFields() {
    // Format Date: DD/MM/YYYY
    startDateController.text =
        "${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}";
    endDateController.text =
        "${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}";

    // Format Time: HH:MM AM/PM
    startTimeController.text = _formatTimeOfDay(_startTime);
    endTimeController.text = _formatTimeOfDay(_endTime);
  }

  // Helper to turn TimeOfDay into a pretty string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    final minute = time.minute.toString().padLeft(2, '0');

    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  Future<void> pickImages() async {
    _errorMessage = null;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    final imageFiles = result.files
        .where((file) => file.bytes != null && file.bytes!.isNotEmpty)
        .toList();

    if (imageFiles.isEmpty) {
      _errorMessage = 'Could not read the selected images.';
      notifyListeners();
      return;
    }

    _selectedImages.addAll(imageFiles);
    _mainImageIndex = _mainImageIndex.clamp(0, _selectedImages.length - 1);
    notifyListeners();
  }

  void setMainImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;

    _mainImageIndex = index;
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;

    _selectedImages.removeAt(index);

    if (_selectedImages.isEmpty) {
      _mainImageIndex = 0;
    } else if (_mainImageIndex == index) {
      _mainImageIndex = 0;
    } else if (_mainImageIndex > index) {
      _mainImageIndex--;
    }

    notifyListeners();
  }

  void toggleCrewRegistration(bool isOpen) {
    _isCrewRegistrationOpen = isOpen;
    notifyListeners();
  }

  void addCrewUnit() {
    final unit = crewUnitController.text.trim();

    if (unit.isEmpty) return;
    if (_crewUnits.any(
      (existingUnit) => existingUnit.toLowerCase() == unit.toLowerCase(),
    )) {
      crewUnitController.clear();
      return;
    }

    _crewUnits.add(unit);
    crewUnitController.clear();
    notifyListeners();
  }

  void removeCrewUnit(int index) {
    if (index < 0 || index >= _crewUnits.length) return;

    _crewUnits.removeAt(index);
    notifyListeners();
  }

  Future<void> selectCrewRegistrationDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _crewRegistrationDeadline ?? _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    _crewRegistrationDeadline = picked;
    crewRegistrationDeadlineController.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    notifyListeners();
  }

  // Save
  Future<bool> saveEvent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await eventService.createEvent(
        eventName: nameController.text,
        eventDescription: descriptionController.text,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        location: locationController.text,
        capacity: int.tryParse(capacityController.text) ?? 50,
        registeredCount: 0,
        images: _selectedImages.map((file) {
          return EventImageUpload(
            fileName: file.name,
            bytes: file.bytes!,
            contentType: _contentTypeForFileName(file.name),
          );
        }).toList(),
        mainImageIndex: _mainImageIndex,
        isCrewRegistrationOpen: _isCrewRegistrationOpen,
        crewRegistrationDescription: crewRegistrationDescriptionController.text,
        crewUnits: _crewUnits,
        crewRequirements: crewRequirementsController.text,
        crewRegistrationDeadline: _crewRegistrationDeadline,
        crewContactInfo: crewContactInfoController.text,
        crewCapacity: int.tryParse(crewCapacityController.text) ?? 0,
        crewApplicantInstructions: crewApplicantInstructionsController.text,
        crewWhatsappGroupLink: crewWhatsappGroupLinkController.text,
        createdByUserId: createdByUserId,
        createdByName: createdByName,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _contentTypeForFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    capacityController.dispose();
    crewRegistrationDescriptionController.dispose();
    crewUnitController.dispose();
    crewRequirementsController.dispose();
    crewRegistrationDeadlineController.dispose();
    crewContactInfoController.dispose();
    crewCapacityController.dispose();
    crewApplicantInstructionsController.dispose();
    crewWhatsappGroupLinkController.dispose();
    super.dispose();
  }
}
