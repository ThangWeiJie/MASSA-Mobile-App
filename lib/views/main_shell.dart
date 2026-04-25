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
        actions: [
          IconButton(
              onPressed: () => _handleSignOut(context),
              icon: Icon(Icons.logout)
          )
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculatedSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: tabs.map((tab) => BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label)).toList(),
      ),
    );
  }

  int _calculatedSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    return tabs.indexWhere((tab) => location.startsWith(tab.path));
  }

  void _onItemTapped(int index, BuildContext context) {
    final path = tabs[index].path;

    context.go(path);
  }
  
  
}
