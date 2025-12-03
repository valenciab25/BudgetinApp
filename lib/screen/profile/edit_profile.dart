import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F0), // warna background abu di luar card
      body: Center(
        child: Container(
          width: 390, // ukuran mirip mockup
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              // ===================== HEADER =====================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B22B3), // ungu header
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Edit My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===================== FOTO PROFIL =====================
              Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/profile.jpg"),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "John Smith",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F2E2E),
                      ),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===================== TITLE =====================
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ===================== USERNAME =====================
                      const Text("Username",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      _inputField(hint: "John Smith"),

                      const SizedBox(height: 15),

                      // ===================== PHONE =====================
                      const Text("Phone",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      _inputField(hint: "+44 555 5555 55"),

                      const SizedBox(height: 15),

                      // ===================== EMAIL =====================
                      const Text("Email Address",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      _inputField(hint: "example@example.com"),

                      const SizedBox(height: 25),

                      // ===================== SWITCH 1 =====================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Push Notifications",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          Switch(value: true, onChanged: null),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ===================== SWITCH 2 =====================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Turn Dark Theme",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          Switch(value: false, onChanged: null),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ===================== BUTTON =====================
                      Center(
                        child: Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B22B3),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "Update Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ===================== TEXTFIELD CUSTOM =====================
  Widget _inputField({required String hint}) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: const Color(0xFFE1F4FF), // biru muda sama seperti gambar
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          hint,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}