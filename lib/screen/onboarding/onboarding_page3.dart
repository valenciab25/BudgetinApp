import 'package:flutter/material.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback? onLogin;

  const OnboardingPage3({super.key, this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar ilustrasi
              SizedBox(
                height: 250,
                child: Image.asset(
                  'assets/images/onboarding3.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Judul
              const Text(
                "Organize your Spending",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E), // Warna biru gelap
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              const Text(
                "Create spending categories to organize your expenses.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF2962FF),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
