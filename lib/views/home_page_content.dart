import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/models/user.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/view_models/features/events/event_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    final eventViewModel = context.watch<EventViewModel>();

    eventViewModel.updateCurrentUserId(user?.uuid);

    // EXCO manages event operations; Admin has that plus app-level control.
    final bool isStaff = user?.role.canManageEvents ?? false;
    final allEvents = eventViewModel.events;

    // Logic: Admins/Exco see every event; Students see only their joined events
    final displayEvents = isStaff
        ? allEvents
        : eventViewModel.getRegisteredEvents();

    // Determine user name for header
    String userName = 'Guest';
    if (user?.fullName != null) {
      userName = user!.fullName;
    } else if (user?.email != null) {
      userName = user!.email.split('@').first;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[50]!, Colors.orange[50]!, Colors.yellow[50]!],
          ),
        ),
        child: Stack(
          children: [
            // --- Background Motifs ---
            Positioned(
              top: 40,
              right: -20,
              child: Icon(
                Icons.wb_sunny_outlined,
                size: 150,
                color: Colors.amber[200]!.withValues(alpha: 0.3),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(userName),
                    const SizedBox(height: 24),

                    // Calendar uses role-based displayEvents
                    _buildCalendarCard(displayEvents),

                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      Icons.calendar_month,
                      isStaff ? "All Organized Events" : "My Registered Events",
                    ),
                    const SizedBox(height: 16),

                    // List also uses role-based displayEvents
                    _buildUpcomingEventsList(displayEvents),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTribalBars(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome back, $name!",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
            _buildTribalBars(),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 32.0, top: 4),
          child: Text(
            "Your events at a glance",
            style: TextStyle(color: Colors.brown, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(List displayEvents) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildNavButton(Icons.chevron_left, () {
                      setState(
                        () => _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    _buildNavButton(Icons.chevron_right, () {
                      setState(
                        () => _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCalendarGrid(displayEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List events) {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth + firstWeekday,
      itemBuilder: (context, index) {
        if (index < firstWeekday) return const SizedBox.shrink();

        final day = index - firstWeekday + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        final dailyEvents = events
            .where((e) => DateUtils.isSameDay(e.startDateTime, date))
            .toList();
        final hasEvents = dailyEvents.isNotEmpty;

        return InkWell(
          onTap: hasEvents
              ? () => context.push('/events/details/${dailyEvents.first.id}')
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // FIX: Solid color fallback and high-contrast border for Today
              color: isToday
                  ? Colors.orange[800]
                  : (hasEvents ? Colors.amber[100] : Colors.transparent),
              gradient: isToday
                  ? const LinearGradient(
                      colors: [Colors.amber, Colors.orange, Colors.red],
                    )
                  : null,
              border: Border.all(
                color: isToday
                    ? Colors.orange[900]!
                    : (hasEvents ? Colors.amber[300]! : Colors.grey[200]!),
                width: isToday ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black87,
                      fontWeight: isToday || hasEvents
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: isToday ? 16 : 14,
                    ),
                  ),
                ),
                if (hasEvents && !isToday)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingEventsList(List events) {
    final upcoming =
        events
            .where(
              (e) => e.startDateTime.isAfter(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
            )
            .toList()
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    if (upcoming.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_busy, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text("No events found", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: upcoming
          .take(3)
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => context.push('/events/details/${event.id}'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(
                      left: BorderSide(color: Colors.amber, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildIconLabel(
                            Icons.access_time,
                            DateFormat('MMM dd').format(event.startDateTime),
                          ),
                          const SizedBox(width: 16),
                          _buildIconLabel(
                            Icons.location_on_outlined,
                            event.location,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTribalBars() {
    return Row(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.amber[900], size: 20),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange[800]),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.orange[700]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
