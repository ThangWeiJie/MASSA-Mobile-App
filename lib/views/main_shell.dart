import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/service/auth_service.dart';
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
          SnackBar(content: Text("Sign out failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Massa"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              child: CircleAvatar(
                radius: 24,
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
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('View Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ];
              },
            ),
          )
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculatedSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: Colors.blue,       // Color when the tab IS active
        unselectedItemColor: Colors.grey,     // Color when the tab IS NOT active
        showUnselectedLabels: true,           // Ensures labels are always visible
        items: tabs.map((tab) => BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label)).toList(),
      ),
    );
  }

  int _calculatedSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    final index = tabs.indexWhere((tab) => location == tab.path);

    return index < 0 ? 0 : index;
  }

  void _onItemTapped(int index, BuildContext context) {
    final path = tabs[index].path;

    context.go(path);
  }
  
  
}
