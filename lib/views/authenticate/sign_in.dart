import 'package:flutter/material.dart';
import 'package:massa/service/auth_service.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Sign in Anonymously'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
        child: ElevatedButton(
            onPressed: () async {
              var result = await _authService.signIn();

              if (result == null) {
                print('Error signing in');
              } else {
                print('Signed in');
                print(result);
              }
            },
            child: Text("Sign in anonymously")),
      ),
    );
  }
}
