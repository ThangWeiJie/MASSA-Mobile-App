import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../view_models/features/events/event_details_viewmodel.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventDetailsViewModel>();

    if (viewModel.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final event = viewModel.event;
    if (event == null) return const Scaffold(body: Center(child: Text("Event not found")));

    return Scaffold(
      appBar: AppBar(title: Text(event.eventName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Big Date Header
            Container(
              width: double.infinity,
              color: const Color(0xFF4A3780),
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMMM d, y').format(event.startDateTime),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('jm').format(event.startDateTime),
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),

            // Description & Details
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About this event", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(event.description, style: const TextStyle(fontSize: 16, height: 1.5)),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {}, // Join Logic
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A3780)),
                      child: const Text("I'M GOING", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}