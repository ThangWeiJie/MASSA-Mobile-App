import 'package:flutter/material.dart';
import 'package:massa/view_models/features/events/mark_attendance_viewmodel.dart';
import 'package:provider/provider.dart';

class ManualAttendanceCodePage extends StatefulWidget {
  const ManualAttendanceCodePage({super.key});

  @override
  State<ManualAttendanceCodePage> createState() =>
      _ManualAttendanceCodePageState();
}

class _ManualAttendanceCodePageState extends State<ManualAttendanceCodePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MarkAttendanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Attendance Code'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.password_rounded, size: 72, color: Colors.orange[800]),
          const SizedBox(height: 20),
          const Text(
            'Enter the code displayed by EXCO',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Attendance code',
              hintText: 'MASSA-4821',
              prefixIcon: const Icon(Icons.key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (_) => viewModel.clearError(),
            onSubmitted: (_) => _submit(context, viewModel),
          ),
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: viewModel.isSubmitting
                  ? null
                  : () => _submit(context, viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: viewModel.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Attendance'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    MarkAttendanceViewModel viewModel,
  ) async {
    FocusScope.of(context).unfocus();
    final success = await viewModel.submitCode(_controller.text);
    if (!context.mounted || !success) return;
    await _showSuccess(context, viewModel);
  }

  Future<void> _showSuccess(
    BuildContext context,
    MarkAttendanceViewModel viewModel,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 54),
        title: const Text('Attendance submitted'),
        content: Text(
          '${viewModel.lastRecord?.type.label ?? 'Event'} attendance was marked successfully.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
