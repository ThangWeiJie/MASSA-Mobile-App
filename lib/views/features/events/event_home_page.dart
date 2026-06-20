import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/event.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';
import 'package:massa/tab_list.dart';
import 'package:massa/view_models/features/events/event_viewmodel.dart';
import 'package:massa/views/features/events/widgets/event_image_gallery.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventHomePage extends StatelessWidget {
  final UserRepository userRepository;

  const EventHomePage({super.key, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    final canManageEvents = user?.role.canManageEvents ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<EventViewModel>().updateCurrentUserId(user?.uuid);
    });

    return Scaffold(
      body: Container(
        // Orange/Amber/Yellow Gradient Background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.amber[50]!, Colors.yellow[50]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  _buildHeader(context, canManageEvents),
                  _buildSearchBar(context, canManageEvents),
                  const Expanded(child: EventList()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool canManageEvents) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 4,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange[600]!, Colors.amber[700]!],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.orange[800]!,
                          Colors.amber[700]!,
                          Colors.yellow[800]!,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Programs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber[600]!, Colors.transparent],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Discover upcoming events',
                      style: TextStyle(
                        color: Colors.amber[900]!.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (canManageEvents)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[600]!,
                    Colors.amber[600]!,
                    Colors.yellow[700]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.amber[200]!.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final result = await context.push("$eventPath/create");
                    if (result == "success" && context.mounted) {
                      context.read<EventViewModel>().fetchEvents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Event created successfully",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.green[700],
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool canManageEvents) {
    final viewModel = context.watch<EventViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _EventSearchField(
              hintText: "Search events...",
              onChanged: viewModel.updateSearchQuery,
            ),
          ),
          const SizedBox(width: 10),
          _PastEventsButton(onTap: () => context.push('$eventPath/past')),
        ],
      ),
    );
  }
}

class PastEventsPage extends StatelessWidget {
  const PastEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventViewModel>();
    final user = context.watch<UserModel?>();
    final isStaff = user?.role.canManageEvents ?? false;
    final count = isStaff ? viewModel.pastEventCount : viewModel.getRegisteredPastEventCount();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.amber[50]!, Colors.yellow[50]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.amber[900],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Past Events',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '$count archived programs',
                                style: TextStyle(
                                  color: Colors.amber[900]!.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _EventSearchField(
                      hintText: "Search past events...",
                      onChanged: viewModel.updateSearchQuery,
                    ),
                  ),
                  const Expanded(child: PastEventsList()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventSearchField extends StatelessWidget {
  const _EventSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _PastEventsButton extends StatelessWidget {
  const _PastEventsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber[800],
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const SizedBox(
          height: 56,
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Past Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Event List Component
// ---------------------------------------------------------

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventViewModel>();

    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          "Error: ${viewModel.errorMessage}",
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }

    if (viewModel.events.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.amber[300]!,
              width: 2,
            ), // Fixed uniform border
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 64,
                color: Colors.amber[300],
              ),
              const SizedBox(height: 16),
              Text(
                "No events found",
                style: TextStyle(
                  color: Colors.amber[900]!.withValues(alpha: 0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.amber[700],
      onRefresh: () => viewModel.fetchEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: viewModel.events.length,
        itemBuilder: (context, index) {
          final event = viewModel.events[index];

          return EventCard(event: event);
        },
      ),
    );
  }
}

class PastEventsList extends StatelessWidget {
  const PastEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventViewModel>();
    final user = context.watch<UserModel?>();
    final isStaff = user?.role.canManageEvents ?? false;
    final groupedEvents = isStaff
        ? viewModel.pastEventsByYear
        : viewModel.getRegisteredPastEventsByYear();

    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          "Error: ${viewModel.errorMessage}",
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }

    if (groupedEvents.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber[300]!, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 64, color: Colors.amber[300]),
              const SizedBox(height: 16),
              Text(
                "No past events found",
                style: TextStyle(
                  color: Colors.amber[900]!.withValues(alpha: 0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final years = groupedEvents.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      color: Colors.amber[700],
      onRefresh: () => viewModel.fetchEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final events = groupedEvents[year] ?? const <Event>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                child: Row(
                  children: [
                    Text(
                      year.toString(),
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Divider(color: Colors.amber[300], thickness: 2),
                    ),
                  ],
                ),
              ),
              ...events.map((event) => EventCard(event: event)),
            ],
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    // Safe parsing in case 'toMap()' isn't fully set up yet
    String capacity = "50";
    String registered = "0";
    String location = "Location TBA";

    try {
      final map = event.toMap();
      capacity = (map['capacity'] ?? 50).toString();
      registered = (map['registeredCount'] ?? 0).toString();
      location = map['location'] ?? 'Location TBA';
    } catch (e) {
      // Failsafe if toMap() throws an error
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber[300]!, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push("$eventPath/details/${event.id}"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.displayImageUrls.isNotEmpty)
                EventImageCarousel(
                  imageUrls: event.displayImageUrls,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  4,
                                  (i) => Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i % 2 == 0
                                          ? Colors.amber[500]
                                          : Colors.orange[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.eventName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber[100]!,
                                Colors.orange[100]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber[300]!,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_alt,
                                size: 16,
                                color: Colors.amber[900],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$registered/$capacity",
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.isCrewRegistrationOpen) ...[
                      const SizedBox(height: 12),
                      _buildCrewOpenChip(event.crewUnits.length),
                    ],
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.calendar_month,
                      DateFormat(
                        'EEEE, MMMM dd, yyyy',
                      ).format(event.startDateTime),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.access_time_filled,
                      DateFormat('jm').format(event.startDateTime),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.location_on, location),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.amber[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCrewOpenChip(int unitCount) {
    final label = unitCount > 0
        ? 'Crew Registration Open - $unitCount units'
        : 'Crew Registration Open';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_2_outlined, size: 16, color: Colors.green[700]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
