import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';
import 'package:massa/tab_list.dart';
import 'package:massa/view_models/features/events/event_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text("Error: ${viewModel.errorMessage}"));
    }

    if (viewModel.events.isEmpty) {
      return const Center(child: Text("No events found."));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchEvents(),
      child: ListView.builder(
          itemCount: viewModel.events.length,
          itemBuilder: (context, index) {
            final event = viewModel.events[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2, // Subtler elevation looks more modern
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => {
                  context.push("$eventPath/details/${event.id}")
                }, // Navigate to details
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: 110, // Matching the height of the content
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A3780), // Your primary brand color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMM').format(event.startDateTime).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            event.startDateTime.day.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 20,
                            color: const Color(0xFFE5D9F2), // Light purple accent line
                          )
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              event.eventName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1B20),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Time Chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F4F4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Color(0xFF4A3780)),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('jm').format(event.startDateTime),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                // Join Button
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "JOIN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A3780),
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}


class EventHomePage extends StatelessWidget {
  final UserRepository userRepository;

  const EventHomePage({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EventList(),
      floatingActionButton: StreamBuilder<UserModel?>(
          stream: userRepository.userStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();

            final user = snapshot.data;

            if (user?.role == Role.exco || user?.role == Role.admin) {
              return FloatingActionButton(
                onPressed: () async {
                  final result = await context.push("$eventPath/create");

                  if (result == "success" && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Event created successfully"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      )
                    );
                  }
                },
                child: Icon(Icons.add)
              );
            }

            return SizedBox.shrink();
          }
      )
    );
  }
}
