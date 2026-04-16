import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '../screens/sign_in/signin_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';

class AppRouter {
  // Define your central router here
  static final GoRouter router = GoRouter(
    initialLocation: '/signin', // The app will start on this route
    routes: [
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const LogInScreen(),
      ),
      // Example of how to add a new screen later:
      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (context, state) => const HomeScreen(),
      // ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );
}