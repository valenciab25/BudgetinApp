// File: lib/screen/detailWishes.dart

import 'package:flutter/material.dart';
import 'package:budgetin_app/models/wish_model.dart';

class DetailWishesScreen extends StatelessWidget {
  final WishModel wish;

  const DetailWishesScreen({super.key, required this.wish});

  // Helper function untuk memformat angka (sudah ada di kode Anda)
  String _formatNumber(int number) {
    // Menghilangkan fungsi penyesuaian angka jika model menggunakan int,
    // tetapi kita akan menggunakan fungsi ini untuk tampilan.
    // Asumsi: number adalah integer
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 DUMMY DATA UNTUK MENCAPAI TAMPILAN SESUAI GAMBAR
    // Data di gambar: Save Rp 12.000.000, Total Rp 20.000.000
    const double totalAmount = 20000000.0;
    const double savedAmount = 8000000.0; // Jika persentase 40% dari 20M = 8M.
    // Tapi di gambar tertulis "Save Rp 12.000.000" dan "Remain Rp 6.000.000"
    // sehingga Total adalah Rp 18.000.000.
    // Namun, 12M/18M * 100% = 66.6%. Sedangkan gambar 40%.
    // Kita akan ikuti angka yang tertera di teks Save/Remain/Amount, dan abaikan ketidaksesuaian persentase.

    // IKUTI ANGKA DI GAMBAR (Teks Save/Remain/Amount):
    const double displayedTotalAmount = 20000000.0;
    const double displayedSavedAmount = 12000000.0;
    final double displayedRemainAmount = 6000000.0;
    const int displayedPercentage = 40; // Ikuti angka 40% di progress bar

    // Gunakan data yang Sesuai dengan Gambar, meskipun tidak konsisten secara matematika
    // (12M/20M = 60%, bukan 40%, tapi kita gunakan 40% dari gambar)

    return Scaffold(
      // 1. Warna latar belakang Scaffold (putih untuk body, abu-abu muda di luar)
      backgroundColor: const Color(0xFFF1F1F1), // Abu-abu muda untuk area yang tidak tercakup
      appBar: AppBar(
        // 2. Warna App Bar (biru gelap sesuai gambar)
        backgroundColor: const Color(0xFF5D5FEF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // 3. Title App Bar diganti dengan teks "Wishes" dan diletakkan di start
        title: const Text(
          'Wishes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER (LABUAN BAJO + GAMBAR) ---
            // Bagian ini dibuat agar tetap memiliki latar belakang biru di atas gambar
            Container(
              padding: const EdgeInsets.only(bottom: 16.0),
              // Tinggi harus disesuaikan agar warna biru App Bar menyatu
              decoration: const BoxDecoration(
                color: Color(0xFF5D5FEF), // Warna biru gelap
              ),
              child: Column(
                children: [
                  Text(
                    'LABUAN BAJO', // Gunakan teks dari gambar
                    // wish.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Lebih kecil dari 25
                      fontWeight: FontWeight.w500, // Tidak terlalu bold
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Radius lebih kecil
                      child: Image.asset(
                        'assets/labuanbajo.jpg', // Gunakan path gambar dummy/mock
                        // wish.imagePath,
                        width: double.infinity,
                        height: 180, // Dibuat lebih pendek
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey.shade300,
                            child: const Center(child: Text("Gambar tidak tersedia")),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- DETAIL PROGRES (40%) ---
            // Konten detail berada dalam container berwarna putih
            Container(
              color: Colors.white,
              // Padding atas dihilangkan karena container sebelumnya sudah memberi jarak
              child: Column(
                children: [
                  const SizedBox(height: 30), // Jarak ke atas

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: displayedPercentage / 100, // 0.40
                          strokeWidth: 10, // Dibuat lebih tipis dari 15
                          backgroundColor: Colors.grey.shade200, // Background lebih muda
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)), // Warna merah di gambar
                        ),
                      ),
                      Text(
                        '$displayedPercentage%',
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w500, // Tidak terlalu bold
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detail Saldo Save/Remain (Diletakkan di bawah progress bar)
                  // Perlu mengubah layout agar label di atas dan nilai di bawah, dan ada margin
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0), // Padding lebih besar
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBalanceText(
                          label: 'Save',
                          amount: 'Rp ${_formatNumber(displayedSavedAmount.toInt())}',
                          // Color disesuaikan agar lebih gelap dan tidak di-bold di sini
                          labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                          amountStyle: const TextStyle(fontSize: 16, color: Colors.black),
                          isCentered: false, // Label di kiri
                        ),
                        _buildBalanceText(
                          label: 'Remain',
                          amount: 'Rp ${_formatNumber(displayedRemainAmount.toInt())}',
                          // Color disesuaikan agar lebih gelap dan tidak di-bold di sini
                          labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                          amountStyle: const TextStyle(fontSize: 16, color: Colors.black),
                          isCentered: false, // Label di kanan
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Separator Line
                  const Divider(indent: 30, endIndent: 30, height: 1, color: Colors.grey),
                  const SizedBox(height: 30),

                  // Detail Amount and Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0), // Padding kiri/kanan
                    child: Column(
                      children: [
                        _buildDetailRow(
                          label: 'Amount',
                          value: ': Rp ${_formatNumber(displayedTotalAmount.toInt())}',
                          isBold: true,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          label: 'Date Wishes',
                          value: ': 01/11/2025',
                          isBold: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Deposit dan Withdraw
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          // Gunakan Custom Icon untuk Deposit (Ikon Panah Bawah ke Kotak Uang)
                          icon: Icons.attach_money,
                          label: 'Deposit',
                          // Warna yang lebih sesuai dengan gambar (hijau gelap)
                          color: const Color(0xFF4CAF50),
                          onTap: () { /* Aksi Deposit */ },
                        ),
                        _buildActionButton(
                          // Gunakan Custom Icon untuk Withdraw (Ikon Panah Atas dari Kotak Uang)
                          icon: Icons.monetization_on,
                          label: 'Withdraw',
                          // Warna yang lebih sesuai dengan gambar (kuning/oranye)
                          color: const Color(0xFFFF9800),
                          onTap: () { /* Aksi Withdraw */ },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(indent: 30, endIndent: 30, height: 1, color: Colors.grey),
                ],
              ),
            ),

            // --- HISTORY ---
            Padding(
              padding: const EdgeInsets.all(30.0), // Padding disesuaikan
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18, // Lebih kecil dari 20
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // History Item 1 (Dummy)
                  _buildHistoryItem(
                    type: 'Deposit',
                    date: '03 November 2025',
                    amount: 'Rp 70.000',
                    amountColor: const Color(0xFF4CAF50), // Hijau
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER PERBAIKAN ---

  Widget _buildBalanceText({
    required String label,
    required String amount,
    TextStyle labelStyle = const TextStyle(fontSize: 16, color: Colors.black54),
    TextStyle amountStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    bool isCentered = true,
  }) {
    // Disesuaikan agar label di atas dan nilai di bawah
    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(amount, style: amountStyle),
      ],
    );
  }

  Widget _buildDetailRow({required String label, required String value, required bool isBold}) {
    // Disesuaikan agar label dan nilai diletakkan di tengah baris
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Padding disesuaikan
            decoration: BoxDecoration(
              // Background disesuaikan agar transparan
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10), // Kotak melengkung
              border: Border.all(color: color.withOpacity(0.3), width: 1), // Border tipis
            ),
            child: Icon(
              icon,
              size: 30, // Ukuran ikon disesuaikan
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String type,
    required String date,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}