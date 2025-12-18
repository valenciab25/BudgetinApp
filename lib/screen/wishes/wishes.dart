import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgetin_app/screen/wishes/add_wishes.dart';
import 'package:budgetin_app/screen/wishes/detailWishes.dart';

class WishesScreen extends StatefulWidget {
  const WishesScreen({super.key});

  @override
  State<WishesScreen> createState() => _WishesScreenState();
}

class _WishesScreenState extends State<WishesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "WISHES",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('wishes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No wishes yet. Add one!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  final wishes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: wishes.length,
                    itemBuilder: (context, index) {
                      final wishDoc = wishes[index];
                      final data = wishDoc.data() as Map<String, dynamic>;

                      final title = (data['name'] ?? 'No Name').toString();
                      final imagePath = (data['imagePath'] ?? '').toString();
                      final colorHex = (data['color'] ?? '#FFFFFFFF').toString();

                      final targetAmount = (data['amount'] as num? ?? 0).toDouble();
                      final savedAmount = (data['savedAmount'] as num? ?? 0).toDouble();

                      final progress = targetAmount <= 0 ? 0.0 : (savedAmount / targetAmount);
                      final percentage = (progress * 100).clamp(0, 100).round();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailWishesScreen(wishId: wishDoc.id),
                            ),
                          );
                        },
                        child: _buildWishCard(
                          title: title,
                          imagePathOrUrl: imagePath,
                          saved: savedAmount.toInt(),
                          percentage: percentage,
                          cardColor: _parseHexColor(colorHex, fallback: const Color(0xFFFFFFFF)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWishesScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Wish",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI CARD ----------
  Widget _buildWishCard({
    required String title,
    required String imagePathOrUrl,
    required int saved,
    required int percentage,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 128, 128, 128),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // IMAGE (FIXED)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: _buildWishImage(imagePathOrUrl),
          ),

          const SizedBox(height: 15),

          // INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Terkumpul : Rp ${_formatNumber(saved)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$percentage%",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // PROGRESS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------- IMAGE BUILDER (FIX UTAMA) ----------
  Widget _buildWishImage(String pathOrUrl) {
    const double h = 150;

    if (pathOrUrl.trim().isEmpty) {
      return _placeholderImage(h);
    }

    // URL (kalau nanti kamu pakai Firebase Storage downloadURL)
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        width: double.infinity,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(h),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: h,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    // LOCAL FILE PATH
    final file = File(pathOrUrl);

    // Penting: cek dulu file benar2 ada (karena kamu simpan path cache)
    if (!file.existsSync()) {
      return _placeholderImage(h, label: "Gambar tidak ditemukan (cache terhapus)");
    }

    return Image.file(
      file,
      width: double.infinity,
      height: h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholderImage(h),
    );
  }

  Widget _placeholderImage(double height, {String? label}) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey.shade300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported, size: 40),
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ]
          ],
        ),
      ),
    );
  }

  // ---------- HELPERS ----------
  Color _parseHexColor(String hex, {required Color fallback}) {
    try {
      var value = hex.trim();

      if (value.startsWith('#')) value = value.substring(1);

      // kalau formatnya RRGGBB, tambah alpha FF
      if (value.length == 6) value = 'FF$value';

      // harus 8 char AARRGGBB
      if (value.length != 8) return fallback;

      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => "${m[1]}.",
    );
  }
}