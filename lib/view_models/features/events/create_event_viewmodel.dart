import 'package:flutter/material.dart';
import 'package:massa/service/features/events/event_service.dart';

class CreateEventViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final startDateController = TextEditingController(text: "17/08/2025");
  final startTimeController = TextEditingController(text: "09:00 AM");
  final endDateController = TextEditingController(text: "17/08/2025");
  final endTimeController = TextEditingController(text: "09:00 AM");
  final descriptionController = TextEditingController();

  final EventService eventService;
  CreateEventViewModel({required this.eventService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
      notifyListeners();
    }
  }

  Future<void> saveEvent() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Here you would call your repository. For example:
      // await eventRepository.addEvent(nameController.text, ...);

      print("Saving event: ${nameController.text}");
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
    } catch (e) {
      rethrow;
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
    super.dispose();
  }
}
