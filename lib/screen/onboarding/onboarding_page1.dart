import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback? onNext;

  const OnboardingPage1({super.key, this.onNext});

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
              // Gambar Ilustrasi
              SizedBox(
                height: 250,
                child: Image.asset(
                  'assets/images/onboarding1.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Judul
              const Text(
                "Fund your budget",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              const Text(
                "Simply by allocating your budget, you can start maximizing your income. "
                    "Budgetin helps you manage all your sources of income, whether single or multiple.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Next
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF2962FF), // Warna biru seperti gambar
                  ),
                  child: const Text(
                    "Next",
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
