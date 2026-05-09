import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventService eventService;

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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreateEventViewModel({required this.eventService}) {
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
    super.dispose();
  }
}
