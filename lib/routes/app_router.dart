import 'package:go_router/go_router.dart';
import 'package:massa/models/user.dart';
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
import 'package:massa/view_models/features/events/event_details_viewmodel.dart';
import 'package:massa/view_models/features/events/event_viewmodel.dart';
import 'package:massa/views/exco_guard.dart';
import 'package:massa/views/features/events/create_event_page.dart';
import 'package:massa/views/features/events/event_details_page.dart';
import 'package:massa/views/features/events/event_home_page.dart';
import 'package:massa/views/home_page_content.dart';
import 'package:massa/views/main_shell.dart';
import 'package:massa/views/features/authentication/forgot_password_screen.dart';
import 'package:massa/views/features/profile/profile_page.dart';
import 'package:massa/views/features/authentication/signin_screen.dart';
import 'package:massa/views/features/authentication/signup_screen.dart';
import 'package:massa/views/features/authentication/verify_email.dart';
import 'package:provider/provider.dart';

class AppRouter {
  final AuthNotifier authNotifier;

  AppRouter(this.authNotifier);

  late final GoRouter router = GoRouter(
    initialLocation: "/signin",
    refreshListenable: authNotifier,
    redirect: (context, state) => _handleRedirect(state),
    routes: [
      // Public routes
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
            create: (providerContext) =>
                ForgotPasswordViewmodel(
                  authService: routeContext.read<AuthService>(),
                ),
            child: const ForgotPasswordScreen(),
          );
        },
      ),

      ShellRoute(
        builder: (routerContext, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: homePath,
            name: "Home",
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const HomePage()),
          ),
          GoRoute(
            path: eventPath,
            name: "Events Home Page",
            pageBuilder: (context, state) =>
                NoTransitionPage(
                  child: ChangeNotifierProvider(
                    create: (_) => EventViewModel(context.read<EventService>()),
                    child: EventHomePage(
                      userRepository: context.read<UserRepository>(),
                    ),
                  ),
                ),
          ),
          GoRoute(
              path: '$eventPath/details/:eventId',
              builder: (context, state) {
                final eventId = state.pathParameters['eventId']!;

                return ChangeNotifierProvider(
                  create: (_) =>
                      EventDetailsViewModel(
                          eventService: context.read<EventService>(),
                          eventId: eventId
                      ),
                  child: const EventDetailsPage(),
                );
              }
          ),
          GoRoute(
            path: "$eventPath/create",
            name: "Create Event Page",
            pageBuilder: (context, state) =>
                NoTransitionPage(
                  child: ExcoGuard(
                    child: ChangeNotifierProvider(
                      create: (providerContext) =>
                          CreateEventViewModel(
                            eventService: context.read<EventService>(),
                          ),
                      child: const CreateEventPage(),
                    ),
                  ),
                ),
          ),
          GoRoute(
            path: profilePath,
            name: "Profile",
            pageBuilder: (context, state) {
              final currentUser = context.read<UserModel?>();

              return NoTransitionPage(
                child: ChangeNotifierProvider(
                  create: (context) =>
                      ProfileViewModel(
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
