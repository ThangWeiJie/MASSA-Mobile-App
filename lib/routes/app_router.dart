import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:massa/screens/HomePage.dart';
import 'package:massa/service/auth_notifier.dart';
import 'package:massa/service/auth_service.dart';
import '../screens/sign_in/signin_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';

class AppRouter {
  AppRouter._internal();

  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;

  final authService = AuthService();
  late final authNotifier = AuthNotifier(authService);

  late final GoRouter router = GoRouter(
    initialLocation: "/signin",
    refreshListenable: authNotifier,
    redirect: (context, state) => _handleRedirect(state),
    routes: [
      GoRoute(
        path: "/signin",
        name: "signin",
        builder: (context, state) => const LogInScreen(),
      ),
      GoRoute(
        path: "/forgot-password",
        name: "forgot-password",
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: "/",
        name: "Home",
        builder: (context, state) => const Homepage(),
      )
    ],
  );

  String? _handleRedirect(GoRouterState state) {
    final isAuthenticated = authNotifier.isAuthenticated;
    final currentPath = state.matchedLocation;

    final publicRoutes = ['/signin', 'signup', '/forgot-password'];
    final isPublicRoute = publicRoutes.contains(currentPath);

    if (!isAuthenticated && !isPublicRoute) {
      return '/signin';
    }

    if (isAuthenticated && isPublicRoute) {
      return '/';
    }

    return null;
  }
}