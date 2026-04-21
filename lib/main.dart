import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:massa/firebase_options.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';

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
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<UserModel?>(
          initialData: null,
          create: (context) {
            final authService = context.read<AuthService>();

            return authService.authStateChanges.map((firebaseUser) {
              if (firebaseUser == null) return null;

              return authService.userFromFirebaseUser(firebaseUser);
            });
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Massa Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        routerConfig: AppRouter().router,
      ),
    );
  }
}
