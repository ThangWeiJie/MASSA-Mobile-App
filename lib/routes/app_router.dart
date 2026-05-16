import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/event_documentation_repository.dart';
import 'package:massa/repository/user_repository.dart';
import 'package:massa/service/features/auth/auth_notifier.dart';
import 'package:massa/service/features/auth/auth_service.dart';
import 'package:massa/service/features/events/event_service.dart';
import 'package:massa/tab_list.dart';
import 'package:massa/view_models/features/authentication/forgot_password_viewmodel.dart';
import 'package:massa/view_models/features/authentication/login_viewmodel.dart';
import 'package:massa/view_models/features/authentication/profile_viewmodel.dart';
import 'package:massa/view_models/features/authentication/signup_viewmodel.dart';
import 'package:massa/view_models/features/events/create_event_viewmodel.dart';
import 'package:massa/view_models/features/events/event_documentation_viewmodel.dart';
import 'package:massa/view_models/features/events/event_details_viewmodel.dart';
import 'package:massa/view_models/features/events/event_registration_viewmodel.dart';
import 'package:massa/view_models/features/events/attendee_list_viewmodel.dart';
import 'package:massa/views/exco_guard.dart';
import 'package:massa/views/features/authentication/forgot_password_screen.dart';
import 'package:massa/views/features/authentication/signin_screen.dart';
import 'package:massa/views/features/authentication/signup_screen.dart';
import 'package:massa/views/features/authentication/verify_email.dart';
import 'package:massa/views/features/events/create_event_page.dart';
import 'package:massa/views/features/events/event_documentation_screen.dart';
import 'package:massa/views/features/events/event_details_page.dart';
import 'package:massa/views/features/events/event_home_page.dart';
import 'package:massa/views/features/events/event_registration_page.dart';
import 'package:massa/views/features/events/attendee_list_page.dart';
import 'package:massa/views/home_page_content.dart';
import 'package:massa/views/main_shell.dart';
import 'package:massa/views/features/profile/profile_page.dart';
import 'package:provider/provider.dart';

class AppRouter {
  final AuthNotifier authNotifier;

  AppRouter(this.authNotifier);

  late final GoRouter router = GoRouter(
    initialLocation: "/signin",
    refreshListenable: authNotifier,
    redirect: (context, state) => _handleRedirect(state),
    routes: [
      // --- Public Routes ---
      GoRoute(
        path: "/signin",
        name: "signin",
        builder: (routeContext, state) {
          return ChangeNotifierProvider(
            create: (providerContext) =>
                LoginViewModel(authService: routeContext.read<AuthService>()),
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: "/signup",
        name: "signup",
        builder: (routeContext, state) {
          return ChangeNotifierProvider(
            create: (providerContext) =>
                SignupViewModel(authService: routeContext.read<AuthService>()),
            child: const SignUpScreen(),
          );
        },
      ),
      GoRoute(
        path: "/verify-email",
        name: "verify-email",
        builder: (routeContext, state) => const VerifyEmail(),
      ),
      GoRoute(
        path: "/forgot-password",
        name: "forgot-password",
        builder: (routeContext, state) {
          return ChangeNotifierProvider(
            create: (providerContext) => ForgotPasswordViewmodel(
              authService: routeContext.read<AuthService>(),
            ),
            child: const ForgotPasswordScreen(),
          );
        },
      ),

      // --- Create Event (Floating Overlay with Fade Transition) ---
      GoRoute(
        path: "$eventPath/create",
        name: "Create Event Page",
        pageBuilder: (context, state) => CustomTransitionPage(
          opaque: false,
          barrierColor: Colors.black54,
          child: ExcoGuard(
            child: ChangeNotifierProvider(
              create: (providerContext) => CreateEventViewModel(
                eventService: context.read<EventService>(),
              ),
              child: const CreateEventPage(),
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // --- Main Application Shell ---
      ShellRoute(
        builder: (routerContext, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: homePath,
            name: "Home",
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: eventPath,
            name: "Events Home Page",
            pageBuilder: (context, state) => NoTransitionPage(
              child: EventHomePage(
                userRepository: context.read<UserRepository>(),
              ),
            ),
          ),
          GoRoute(
            path: '$eventPath/details/:eventId',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              final currentUser = context.read<UserModel?>();

              return ChangeNotifierProvider(
                create: (_) => EventDetailsViewModel(
                  eventService: context.read<EventService>(),
                  eventId: eventId,
                  currentUserId: currentUser?.uuid,
                ),
                child: const EventDetailsPage(),
              );
            },
          ),
          // --- Documentation Route ---
          GoRoute(
            path: '$eventPath/details/:eventId/documentation',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              final currentUser = context.read<UserModel?>();
              return ExcoGuard(
                child: ChangeNotifierProvider(
                  create: (_) => EventDocumentationViewModel(
                    repository: context.read<EventDocumentationRepository>(),
                    eventId: eventId,
                    userName: currentUser?.fullName,
                  ),
                  child: const EventDocumentationScreen(),
                ),
              );
            },
          ),
          // --- Attendee List Route ---
          GoRoute(
            path: '$eventPath/details/:eventId/attendees',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return ExcoGuard(
                child: ChangeNotifierProvider(
                  create: (_) => AttendeeListViewModel(
                    eventService: context.read<EventService>(),
                    eventId: eventId,
                  ),
                  child: const AttendeeListPage(),
                ),
              );
            },
          ),
          // --- Registration Route ---
          GoRoute(
            path: '$eventPath/details/:eventId/register',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return ChangeNotifierProvider(
                create: (_) => EventRegistrationViewModel(
                  eventService: context.read<EventService>(),
                  eventId: eventId,
                ),
                child: const EventRegistrationPage(),
              );
            },
          ),
          GoRoute(
            path: profilePath,
            name: "Profile",
            pageBuilder: (context, state) {
              final currentUser = context.read<UserModel?>();
              return NoTransitionPage(
                child: ChangeNotifierProvider(
                  create: (context) => ProfileViewModel(
                    userRepo: context.read<UserRepository>(),
                    userId: currentUser?.uuid ?? '',
                  ),
                  child: const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );

  String? _handleRedirect(GoRouterState state) {
    final isAuthenticated = authNotifier.isAuthenticated;
    final isVerified = authNotifier.isEmailVerified;
    final currentPath = state.matchedLocation;

    final publicRoutes = ['/signin', '/signup', '/forgot-password'];
    final isOnPublicRoute = publicRoutes.contains(currentPath);

    if (!isAuthenticated && !isOnPublicRoute) {
      return '/signin';
    }

    if (isAuthenticated && !isVerified && currentPath != "/verify-email") {
      return "/verify-email";
    }

    if (isAuthenticated && isVerified && currentPath == "/verify-email") {
      return "/";
    }

    if (isAuthenticated && isOnPublicRoute) {
      return '/';
    }

    return null;
  }
}
