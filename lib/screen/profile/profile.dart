
import 'package:flutter/material.dart';
import 'package:budgetin_app/screen/auth/item_list.dart';
import 'package:budgetin_app/screen/components/menu_list.dart';
import 'package:budgetin_app/screen/partials/color.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TIPS: Beri warna latar belakang yang sama dengan ornamen atas
      // agar transisi terlihat lebih mulus. Jika ornamen atas tidak ada,
      // biarkan default.
      // backgroundColor: primary,

        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              // =================== HEADER ===================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Beri sedikit padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Beri fungsi untuk kembali
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                      // Warna icon header sebaiknya jangan putih jika background Scaffold putih
                      color: Colors.black,
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      color: primary, // Warna ini sudah benar
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 19,
              ),
              // =================== KONTEN UTAMA ===================
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 7,
                      ),
                      // --- Bagian Info Profil ---
                      Container(
                        width: 97,
                        height: 99,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset('assets/images/john_smith.png'),
                      ),
                      const Text(
                        'John Smith',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),


                      const SizedBox(
                        height: 25,
                      ),
                      // =================== SOLUSI DI SINI ===================
                      // Gunakan Expanded + SingleChildScrollView untuk area daftar menu
                      Expanded(
                        child: SingleChildScrollView( // <-- GANTI DARI LISTVIEW
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding untuk menu
                            child: Column(
                              children: [
                                MenuList(
                                    title: 'Edit Profile',
                                    image: 'assets/images/edit_profile.png'),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const ItemListScreen()
                                        ))
                                  },
                                  child: MenuList(
                                      title: 'Security',
                                      image: 'assets/images/security.png'),
                                ),
                                const SizedBox(height: 10),
                                MenuList(
                                    title: 'Setting',
                                    image: 'assets/images/settings.png'),
                                const SizedBox(height: 10),
                                MenuList(
                                    title: 'help', // Typo diperbaiki
                                    image: 'assets/images/help.png'),
                                const SizedBox(height: 10),
                                MenuList(
                                    title: 'logout',
                                    image: 'assets/images/logout.png'),
                                const SizedBox(height: 10),
                                // Anda bisa menambahkan menu Logout di sini jika perlu
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}