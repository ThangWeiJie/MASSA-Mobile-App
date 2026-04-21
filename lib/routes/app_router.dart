import 'package:go_router/go_router.dart';
import 'package:massa/service/auth_notifier.dart';
import 'package:massa/service/auth_service.dart';
import 'package:massa/view_models/forgot_password_viewmodel.dart';
import 'package:massa/view_models/login_viewmodel.dart';
import 'package:massa/views/home_page.dart';
import 'package:massa/views/forgot_password/forgot_password_screen.dart';
import 'package:massa/views/sign_in/signin_screen.dart';
import 'package:provider/provider.dart';

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
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (context) =>
                LoginViewModel(authService: context.read<AuthService>()),
            child: const SignUpScreen(),
          );
        },
      ),
      GoRoute(
        path: "/forgot-password",
        name: "forgot-password",
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (context) => ForgotPasswordViewmodel(
              authService: context.read<AuthService>(),
            ),
            child: const ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: "/",
        name: "Home",
        builder: (context, state) => Homepage(authService: authService),
      ),
    ],
  );

  String? _handleRedirect(GoRouterState state) {
    final isAuthenticated = authNotifier.isAuthenticated;
    final currentPath = state.matchedLocation;

    final publicRoutes = ['/signin', 'signup', '/forgot-password'];
    final isOnPublicRoute = publicRoutes.contains(currentPath);

    if (!isAuthenticated && !isOnPublicRoute) {
      return '/signin';
    }

    if (isAuthenticated && isOnPublicRoute) {
      return '/';
    }

    return null;
  }
}
