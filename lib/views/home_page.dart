import 'package:flutter/material.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/auth_service.dart';
import 'package:provider/provider.dart';

class Homepage extends StatelessWidget {
  final AuthService _authService;

  const Homepage({super.key, required AuthService authService}): _authService = authService;

  void _handleSignOut(BuildContext context) async {
    try {
      await _authService.signOut();
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign out failed: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MaterialApp(
      title: "Some title",
      home: Scaffold(
        appBar: AppBar(title: const Text("Hi world")),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: () => _handleSignOut(context), child: const Text("Sign out")),
              Text(user.email),
            ],
          )
        ),
      ),
    );
  }
}
