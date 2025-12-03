import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Atur timer untuk navigasi setelah 3 detik
    // Durasi 3 detik lebih umum untuk SplashScreen daripada 10 detik
    Timer(const Duration(seconds: 3), () {
      // Penting: Pastikan widget masih ada di pohon sebelum mencoba navigasi
      if (!mounted) return;

      // Pilih salah satu rute yang benar, misalnya '/home' atau '/login'
      // Saya memilih '/home' berdasarkan salah satu cabang konflik sebelumnya
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan warna tema atau warna yang konsisten
      backgroundColor: const Color(0xFF3629B7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gunakan salah satu deklarasi Image.asset, yang lebih besar (120)
            // dan sisanya (SizedBox dan CircularProgressIndicator)
            Image.asset(
              'assets/logo/logo.png',
              height: 120, // Menggunakan height 120
            ),
            // Hapus CircularProgressIndicator agar tidak menampilkan icon loading
            // const SizedBox(height: 20), // Jika tidak diperlukan, bisa dihapus juga
          ],
        ),
      ),
    );
  }
}