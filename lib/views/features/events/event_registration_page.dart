import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:massa/view_models/features/events/event_registration_viewmodel.dart';
import 'package:provider/provider.dart';

class EventRegistrationPage extends StatelessWidget {
  const EventRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventRegistrationViewModel>();

    if (viewModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Register for Event')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Register for Event')),
        body: Center(child: Text(viewModel.errorMessage!)),
      );
    }

    final event = viewModel.event!;

    return Scaffold(
      appBar: AppBar(title: const Text('Register for Event')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.eventName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, y • jm').format(event.startDateTime),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'You are about to register for this event. Confirm your attendance below to secure your spot.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: Color(0xFF4A3780),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('jm').format(event.startDateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Color(0xFF4A3780),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM d, y').format(event.startDateTime),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (viewModel.isRegistered) ...[
              const Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Registration confirmed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are now registered for this event. You can go back to the event details or home screen.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3780),
                  ),
                  child: const Text(
                    'Back to Event',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isRegistering
                      ? null
                      : () async {
                          await viewModel.registerForEvent();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You are now registered for the event.',
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3780),
                  ),
                  child: viewModel.isRegistering
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'CONFIRM REGISTRATION',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
