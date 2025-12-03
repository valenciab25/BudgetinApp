import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==== IMPORT SCREEN ====
import 'screen/features/splash.dart';
import 'screen/features/navbar.dart';
import 'screen/auth/login.dart';
import 'screen/auth/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BudgetIn App',

      // Routing
      initialRoute: '/login',

      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        // '/register': (_) => const SignUpScreen(),
        '/home': (_) => const Navbar(),
      },
    );
  }
}
