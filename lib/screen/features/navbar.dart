import 'package:budgetin_app/screen/home/home.dart';
import 'package:budgetin_app/screen/statistic/statistic.dart';
import 'package:budgetin_app/screen/transaction/transaction.dart';
import 'package:budgetin_app/screen/profile/profile.dart';
import 'package:budgetin_app/screen/wishes/wishes.dart';

import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  // Indeks untuk screen yang aktif:
  // 0: Home, 1: Statistik, 2: Transaksi(FAB), 3: Wishes, 4: Profile
  int _currentIndex = 0;

  // List of screens sesuai urutan indeks
  final List<Widget> _screens = const [
    HomeScreen(),      // 0: Home
    StatisticScreen(), // 1: Statistik
    // TransactionScreen(), // 2: Transaksi (FAB)
    // WishesScreen(),    // 3: Love/Wishes
    ProfileScreen(),   // 4: Profile
  ];

  // Map untuk memetakan navIndex BottomAppBar ke Screen Index yang sebenarnya
  // NavIndex: [0 (Home), 1 (Statistik), 2 (Love), 3 (Profile)]
  // ScreenIndex: [0, 1, 3, 4]
  final List<int> _navToScreenMap = [0, 1, 3, 4];

  void _onItemTapped(int navIndex) {
    setState(() {
      // Menggunakan map untuk mendapatkan screen index yang benar
      _currentIndex = _navToScreenMap[navIndex];
    });
  }

  void _onAddTapped() {
    // FAB/Tombol Tengah selalu mengarah ke TransactionScreen (indeks 2)
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Konstanta Warna Disesuaikan
    const Color navbarColor = Color(0xFF5338FF); // Warna Background BottomAppBar
    const Color selectedIconColor = Colors.white; // Warna Ikon Aktif (Putih)
    const Color unselectedIconColor = Color(0xFFAFAFAF); // Warna Ikon Non-Aktif (Abu-abu)
    const Color fabColor = Color(0xFF5338FF); // Mengubah FAB agar lebih menonjol (Contoh Orange)

    // Cek apakah FAB (TransactionScreen/Index 2) sedang aktif
    bool isFabActive = _currentIndex == 2;

    return Scaffold(
      body: _screens[_currentIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTapped,
        tooltip: 'Transaction',
        elevation: isFabActive ? 10.0 : 2.0,
        // FAB selalu menggunakan warna yang lebih cerah
        backgroundColor: fabColor,
        shape: const CircleBorder(),
        // Warna ikon FAB diatur berdasarkan status aktif
        child: Icon(
            Icons.add_box,
            color: isFabActive ? selectedIconColor : unselectedIconColor,
            size: 28
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: navbarColor,
        // Mengubah shape agar lebih mulus (optional)
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // LEFT SIDE ITEMS: Home & Statistik
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.show_chart, 'Statistik', 1),

              // Placeholder untuk FAB di tengah
              const SizedBox(width: 40),

              // RIGHT SIDE ITEMS: Love (Wishes) & Profile
              // navIndex 2 mengarah ke Wishes (screen index 3)
              _buildNavItem(Icons.favorite, 'Love', 2),
              // navIndex 3 mengarah ke Profile (screen index 4)
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int navIndex) {
    // Menghitung screenIndex yang sebenarnya berdasarkan _navToScreenMap
    final screenIndex = _navToScreenMap[navIndex];
    bool isSelected = _currentIndex == screenIndex;

    // Konstanta Warna yang Diperlukan di sini
    const Color selectedColor = Colors.white;
    const Color unselectedColor = Color(0xFFAFAFAF);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(navIndex),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                // Menggunakan Putih jika Selected, Abu-abu jika Unselected
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  // Menggunakan Putih jika Selected, Abu-abu jika Unselected
                    color: isSelected ? selectedColor : unselectedColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}