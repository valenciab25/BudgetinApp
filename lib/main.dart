// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// // ==== IMPORT SCREEN ====
// import 'screen/features/splash.dart';
// import 'screen/features/navbar.dart';
// import 'screen/auth/login.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'BudgetIn App',
//
//       // 🔥 INITIAL ROUTING
//       initialRoute: '/splash',
//       routes: {
//         '/': (context) => const AuthGate(),
//         '/splash': (context) => const SplashScreen(),
//         '/login': (context) => const LoginScreen(),
//         '/home': (context) => const Navbar(),
//       },
//     );
//   }
// }
//
// /// 🔐 AUTH GATE (SATU SUMBER KEBENARAN)
// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // loading
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SplashScreen();
//         }
//
//         // sudah login
//         if (snapshot.hasData) {
//           return const Navbar();
//         }
//
//         // belum login
//         return const LoginScreen();
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==== IMPORT SCREEN ====
import 'screen/features/splash.dart';
import 'screen/features/navbar.dart';
import 'screen/auth/login.dart';

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

      // ✅ AUTH GATE JADI ENTRY POINT
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Navbar(),
      },
    );
  }
}

/// 🔐 AUTH GATE (SUMBER KEBENARAN LOGIN)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // ✅ SUDAH LOGIN
        if (snapshot.hasData) {
          return const Navbar();
        }

        // ❌ BELUM LOGIN / LOGOUT
        return const LoginScreen();
      },
    );
  }
}

