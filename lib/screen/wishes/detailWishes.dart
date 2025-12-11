import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailWishesScreen extends StatelessWidget {
  final String wishId;

  const DetailWishesScreen({
    super.key,
    required this.wishId,
  });

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D5FEF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Wishes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wishes')
            .doc(wishId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final String name = data['name'] ?? 'Unknown';
          final String imageUrl = data['imagePath'] ?? '';
          final int amount = (data['amount'] as num?)?.toInt() ?? 0;
          final int saved = (data['savedAmount'] as num?)?.toInt() ?? 0;

          final int remain = amount - saved;
          final int percentage = amount == 0 ? 0 : ((saved / amount) * 100).round();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// HEADER
                Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  decoration: const BoxDecoration(color: Color(0xFF5D5FEF)),
                  child: Column(
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.isNotEmpty
                              ? Image.file(
                            File(imageUrl),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            height: 180,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Text("Gambar tidak tersedia"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// DETAIL
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      /// CIRCLE PROGRESS
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF5252),
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// SAVE | REMAIN
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceText(
                              label: 'Save',
                              amount: 'Rp ${_formatNumber(saved)}',
                            ),
                            _buildBalanceText(
                              label: 'Remain',
                              amount: 'Rp ${_formatNumber(remain)}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Divider(indent: 30, endIndent: 30, height: 1),
                      const SizedBox(height: 30),

                      /// AMOUNT
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              label: 'Amount',
                              value: ': Rp ${_formatNumber(amount)}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// BUTTONS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(
                              icon: Icons.attach_money,
                              label: 'Deposit',
                              color: const Color(0xFF4CAF50),
                              onTap: () => _showAddMoney(context, true),
                            ),
                            _buildActionButton(
                              icon: Icons.monetization_on,
                              label: 'Withdraw',
                              color: const Color(0xFFFF9800),
                              onTap: () => _showAddMoney(context, false),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ====================================================
  //                      ADD MONEY
  // ====================================================

  void _showAddMoney(BuildContext context, bool isDeposit) {
    final TextEditingController ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isDeposit ? "Tambah Tabungan" : "Kurangi Tabungan"),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Masukkan nominal",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final int value = int.tryParse(ctrl.text) ?? 0;

                await FirebaseFirestore.instance
                    .collection('wishes')
                    .doc(wishId)
                    .update({
                  "savedAmount":
                  FieldValue.increment(isDeposit ? value : -value),
                });

                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ====================================================
  //                     HELPERS UI
  // ====================================================

  Widget _buildBalanceText({
    required String label,
    required String amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isBold,
  }) {
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, size: 30, color: color),
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
}
