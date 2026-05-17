import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/navtab.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/features/auth/auth_service.dart';
import 'package:massa/tab_list.dart';
import 'package:provider/provider.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  void _handleSignOut(BuildContext context) async {
    try {
      await context.read<AuthService>().signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sign out failed: $e"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableTabs = _availableTabs(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: ShaderMask(
                  // 👇 THIS IS THE FIX: Forces the gradient to paint over the text
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      LinearGradient(
                        colors: [
                          Colors.amber[700]!,
                          Colors.orange[700]!,
                          Colors.red[800]!,
                        ],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: const Text(
                    "MASSA",
                    style: TextStyle(
                      // Text color must be white for the srcIn blend mode to work
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                actions: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: _NotificationBell(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      elevation: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber[400]!,
                              Colors.orange[500]!,
                              Colors.red[600]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            context.go("/profile");
                            break;
                          case 'logout':
                            _handleSignOut(context);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                              ),
                              title: const Text(
                                'View Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap: 12,
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red[700],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap: 12,
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: child,

      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _calculatedSelectedIndex(context, availableTabs),
                onTap: (index) => _onItemTapped(index, context, availableTabs),
                selectedItemColor: Colors.orange[700],
                unselectedItemColor: Colors.grey[600],
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: availableTabs
                    .map(
                      (tab) => BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Icon(tab.icon),
                        ),
                        activeIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[500]!.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tab.icon, color: Colors.orange[700]),
                          ),
                        ),
                        label: tab.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _calculatedSelectedIndex(
    BuildContext context,
    List<NavTab> availableTabs,
  ) {
    final String location = GoRouterState.of(context).uri.path;

    final index = availableTabs.indexWhere((tab) {
      if (tab.path == '/') {
        return location == '/';
      }
      return location.startsWith(tab.path);
    });

    return index < 0 ? 0 : index;
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    List<NavTab> availableTabs,
  ) {
    final path = availableTabs[index].path;
    context.go(path);
  }

  List<NavTab> _availableTabs(BuildContext context) {
    final user = context.watch<UserModel?>();
    final canManageEvents = user?.role.canManageEvents ?? false;

    if (!canManageEvents) return tabs;

    return [
      const NavTab(path: homePath, icon: Icons.home, label: "Home"),
      const NavTab(path: eventPath, icon: Icons.event, label: "Programs"),
      const NavTab(
        path: excoMembersPath,
        icon: Icons.groups_2_outlined,
        label: 'EXCO',
      ),
      const NavTab(
        path: profilePath,
        icon: Icons.account_box,
        label: "Profile",
      ),
    ];
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uuid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.docs.length ?? 0;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.go('/notifications'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
