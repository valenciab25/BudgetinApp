import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgetin_app/screen/profile/menu_list.dart';
import 'package:budgetin_app/screen/partials/color.dart';
import 'package:budgetin_app/screen/auth/item_list.dart';
import 'package:budgetin_app/screen/profile/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        user?.displayName ??
            user?.email?.split('@')[0] ??
            'User';

    final String email = user?.email ?? 'Tidak ada email';
    final String? photoURL = user?.photoURL;

    return Scaffold(
      backgroundColor: primary, // ⬅️ ganti supaya putih
      extendBody: true,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // ================= KARTU PUTIH =================
            Container(
              margin: const EdgeInsets.only(top: 200),
              width: double.infinity,
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 70),

                      // ===== USERNAME & EMAIL =====
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // ================= MENU =================
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );

                          if (result == true) {
                            await _reloadUser();
                          }
                        },
                        child: const MenuList(
                          title: 'Edit Profile',
                          iconData: Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ===== LOGOUT (DITAMBAHKAN onTap) =====
                      InkWell(
                        onTap: () {
                          showLogoutDialog(context);
                        },
                        child: const MenuList(
                          title: 'Logout',
                          iconData: Icons.logout,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ================= FOTO PROFILE =================
            Positioned(
              top: 145,
              child: Container(
                width: 110,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: photoURL != null
                        ? NetworkImage(photoURL)
                        : const AssetImage(
                      'assets/images/john_smith.png',
                    ) as ImageProvider,
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ================= DIALOG LOGOUT =================
//
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'End Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                          (route) => false,
                    );
                  },
                  child: const Text('Yes, End Session'),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}