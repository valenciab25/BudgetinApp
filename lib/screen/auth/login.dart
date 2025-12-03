import 'package:flutter/material.dart';
import 'package:budgetin_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Controllers untuk input Email dan Password - DIKOSONGKAN ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final auth = AuthService();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi untuk Login Google ---
  Future<void> loginGoogle() async {
    try {
      User? user = await auth.signInWithGoogle();

      if (user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Google Sign-in dibatalkan atau gagal.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-in gagal: ${e.toString()}")),
        );
      }
    }
  }

  // --- Fungsi untuk Login Email/Password ---
  void loginEmailPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login dengan Email sedang diproses...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4285F4);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Spacer dari atas layar
            SizedBox(height: MediaQuery.of(context).padding.top + 50),

            // 1. Logo Aplikasi - UKURAN DIPERBESAR
            Center(
              child: Image.asset(
                'assets/images/logo-kuning.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12), // DIKURANGI dari 20 ke 12

            // 2. Judul Login - UKURAN DIPERKECIL
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 24, // DIKURANGI dari 32 ke 24
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Text "Don't have an account? Sign Up"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 3. Input Email - DIGANTI JADI USERNAME
            const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // 4. Input Password - DIKOSONGKAN
            const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            // 5. Remember me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (val) {}),
                    const Text('Remember me'),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 6. Tombol Log In
            ElevatedButton(
              onPressed: loginEmailPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Log In',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // 7. Divider 'Or'
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Or', style: TextStyle(color: Colors.grey[600])),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            // 8. Tombol Continue with Google
            OutlinedButton(
              onPressed: loginGoogle,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google-icon.png',
                    height: 24.0,
                    width: 24.0,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                          Icons.g_mobiledata, color: Colors.red, size: 28);
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}