import 'package:go_router/go_router.dart';
import 'package:massa/service/auth_notifier.dart';
import 'package:massa/service/auth_service.dart';
import 'package:massa/view_models/forgot_password_viewmodel.dart';
import 'package:massa/view_models/login_viewmodel.dart';
import 'package:massa/view_models/signup_viewmodel.dart';
import 'package:massa/views/home_page.dart';
import 'package:massa/views/forgot_password/forgot_password_screen.dart';
import 'package:massa/views/sign_in/signin_screen.dart';
import 'package:massa/views/sign_in/signup_screen.dart';
import 'package:massa/views/verify-email.dart';
import 'package:provider/provider.dart';

class AppRouter {
  final AuthNotifier authNotifier;

  AppRouter(this.authNotifier);

  late final GoRouter router = GoRouter(
    initialLocation: "/signin",
    refreshListenable: authNotifier,
    redirect: (context, state) => _handleRedirect(state),
    routes: [
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
        }
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
                  ForgotPasswordViewmodel(authService: routeContext.read<AuthService>()),
            child: const ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: "/",
        name: "Home",
        builder: (routeContext, state) => Homepage(authService: routeContext.read<AuthService>()),
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

    if(isAuthenticated && !isVerified && currentPath != "/verify-email") {
      return "/verify-email";
    }

    if(isAuthenticated && isVerified && currentPath == "/verify-email") {
      return "/";
    }

    if (isAuthenticated && isOnPublicRoute) {
      return '/';
    }

    return null;
  }
}
