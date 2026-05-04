import 'package:flutter/material.dart';
import 'package:massa/mock_data_dir/event_mock_data/event_mock_data.dart';

class EventHomePage extends StatelessWidget {
  const EventHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: mockEventsList.length,
        itemBuilder: (context, index) {
          final event = mockEventsList[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.eventName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Starts: ${event.startDateTime.day}/${event.startDateTime.month}"),
                              TextButton(onPressed: () {}, child: const Text("JOIN")),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }
}
