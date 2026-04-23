import 'package:flutter/material.dart';
import 'package:massa/service/auth_notifier.dart';
import 'package:provider/provider.dart';

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                Icon(Icons.email_outlined, size: 48),
                Text(
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  "Verify your email",
                ),
                Text(
                  "We have sent a verification email to the following email address: xxx@gmail.com. Verify your email to continue.",
                ),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthNotifier>().refreshUser();
                  },
                  child: Text("I have verified my email."),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
