import 'package:flutter/material.dart';
import 'package:massa/views/authenticate/authenticate.dart';
import 'package:massa/views/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  // Either show Authenticate or Home
  @override
  Widget build(BuildContext context) {
    return Authenticate();
  }
}
