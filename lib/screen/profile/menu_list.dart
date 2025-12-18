import 'package:flutter/material.dart';
import 'package:budgetin_app/screen/partials/color.dart';

// Nama Widget harus diawali huruf besar (standar Dart)
class MenuList extends StatelessWidget {
  final String title;
  final IconData iconData;

  const MenuList({
    super.key,
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Hapus 'width: 372' agar lebarnya fleksibel mengikuti parent (Column di profile.dart)
      padding: const EdgeInsets.all(8), // Padding di semua sisi agar lebih rapi
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Tingkatkan radius agar lebih modern
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.08), // Bayangan lebih soft
          ),
        ],
      ),
      child: Row(
        children: [
          // =======================================================
          // INI CARA YANG BENAR UNTUK MENAMPILKAN GAMBAR IKON
          // =======================================================
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8), // Beri padding agar ikon tidak menempel
            decoration: BoxDecoration(
              color: const Color(0xFF3299FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData, // Path gambar diambil dari parameter
              color: Colors.white,
              size: 24,
              // errorBuilder akan menampilkan ikon jika gambar gagal dimuat

            ),
          ),
          // =======================================================

          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}