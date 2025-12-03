// import 'package:flutter/material.dart';
// import 'package:budgetin_app/services/auth_service.dart';
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final auth = AuthService();
//
//   Future<void> register() async {
//     try {
//       await auth.registerEmail(_emailController.text, _passwordController.text);
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Register gagal: $e")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("Register", style: TextStyle(fontSize: 26)),
//             TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
//             TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
//             const SizedBox(height: 20),
//
//             ElevatedButton(onPressed: register, child: const Text("Register")),
//
//             TextButton(
//               onPressed: () => Navigator.pushNamed(context, '/login'),
//               child: const Text("Already have an account? Login"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
