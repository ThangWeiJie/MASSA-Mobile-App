import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:massa/firebase_options.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/event_documentation_repository.dart';
import 'package:massa/repository/event_repository.dart';
import 'package:massa/repository/user_repository.dart';
import 'package:massa/routes/app_router.dart';
import 'package:massa/service/features/auth/auth_notifier.dart';
import 'package:massa/service/features/auth/auth_service.dart';
import 'package:massa/service/features/events/event_service.dart';
// Merged: Import for EventViewModel
import 'package:massa/view_models/features/events/event_viewmodel.dart'; 
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Repositories (Data Layer)
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<EventRepository>(create: (_) => EventRepository()),
        Provider<EventDocumentationRepository>(
          create: (_) => EventDocumentationRepository(),
        ),

        // 2. Services (Logic Layer)
        ProxyProvider<UserRepository, AuthService>(
          update: (context, userRepository, previousAuthService) =>
              AuthService(userRepository),
        ),
        ProxyProvider<EventRepository, EventService>(
          update: (context, eventRepository, previousEventService) =>
              EventService(eventRepository: eventRepository),
        ),

        // 3. ViewModels (State Layer)
        // Merged: Added Global EventViewModel
        ChangeNotifierProvider<EventViewModel>(
          create: (context) => EventViewModel(context.read<EventService>()),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(context.read<AuthService>()),
        ),

        // 4. Router and Streams
        ProxyProvider<AuthNotifier, AppRouter>(
          update: (context, authNotifier, previous) => AppRouter(authNotifier),
        ),
        StreamProvider<UserModel?>(
          initialData: null,
          create: (context) => context.read<UserRepository>().userStream,
        ),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = context.watch<AppRouter>();

          return MaterialApp.router(
            title: 'Massa Demo',
            debugShowCheckedModeBanner: false, // Recommended for a cleaner UI
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
