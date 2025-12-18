import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailWishesScreen extends StatefulWidget {
  final String wishId;

  const DetailWishesScreen({super.key, required this.wishId});

  @override
  State<DetailWishesScreen> createState() => _DetailWishesScreenState();
}

class _DetailWishesScreenState extends State<DetailWishesScreen> {
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isProcessing = false;

  DocumentReference<Map<String, dynamic>> get _wishRef =>
      FirebaseFirestore.instance.collection('wishes').doc(widget.wishId);

  // ===================== Deposit / Withdraw (transaction) =====================
  Future<void> _changeSavedAmount({required bool isDeposit}) async {
    final controller = TextEditingController();
    final type = isDeposit ? 'deposit' : 'withdraw';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isDeposit ? 'Deposit' : 'Withdraw'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Masukkan nominal (contoh: 50000)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final value = double.tryParse(controller.text.trim());
    if (value == null || value <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak valid')),
      );
      return;
    }

    final inc = isDeposit ? value : -value;

    setState(() => _isProcessing = true);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(_wishRef);
        final data = snap.data() ?? {};
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final saved = (data['savedAmount'] as num?)?.toDouble() ?? 0;

        double newSaved = saved + inc;

        // batas aman
        if (newSaved < 0) newSaved = 0;
        if (amount > 0 && newSaved > amount) newSaved = amount;

        tx.update(_wishRef, {
          'savedAmount': newSaved,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // simpan history
        final histRef = _wishRef.collection('history').doc();
        tx.set(histRef, {
          'type': type,
          'amount': value,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ===================== Helpers =====================
  DateTime? _parseDateTarget(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Color _parseHexColor(dynamic raw, {Color fallback = const Color(0xFF5B63FF)}) {
    if (raw == null) return fallback;
    String s = raw.toString().replaceAll('#', '').trim();

    if (s.length == 6) {
      s = 'FF$s';
    }

    if (s.length == 8) {
      final v = int.tryParse(s, radix: 16);
      if (v != null) return Color(v);
    }
    return fallback;
  }

  Widget _buildWishImage({
    required String imageUrl,
    required String imagePath,
  }) {
    final hasNetwork = imageUrl.trim().isNotEmpty;
    final hasLocal = imagePath.trim().isNotEmpty;

    Widget child;

    if (hasNetwork) {
      child = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Center(child: Text('Gambar tidak tersedia')),
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else if (hasLocal) {
      child = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Center(child: Text('Gambar tidak tersedia')),
        ),
      );
    } else {
      child = Container(
        color: Colors.grey.shade300,
        child: const Center(child: Text('Belum ada gambar')),
      );
    }

    return SizedBox(height: 170, width: double.infinity, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _wishRef.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Wish tidak ditemukan')),
          );
        }

        final data = snap.data!.data() ?? {};
        final name = (data['name'] ?? 'Wishes').toString();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final saved = (data['savedAmount'] as num?)?.toDouble() ?? 0;
        final remain = (amount - saved) < 0 ? 0 : (amount - saved);

        final imageUrl = (data['imageUrl'] ?? '').toString();
        final imagePath = (data['imagePath'] ?? '').toString();
        final targetDate = _parseDateTarget(data['dateTarget']);

        // Warna tema utama dari Firestore
        final primaryColor = _parseHexColor(data['color']);

        final percent = (amount <= 0)
            ? 0.0
            : (saved / amount * 100).clamp(0.0, 100.0);

        return Scaffold(
          backgroundColor: primaryColor, // Background mengikuti warna tema
          body: SafeArea(
            child: Column(
              children: [
                // ===== HEADER =====
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          child: Text(
                            name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== IMAGE AREA =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildWishImage(
                      imageUrl: imageUrl,
                      imagePath: imagePath,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ===== WHITE PANEL =====
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress circle
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: CircularProgressIndicator(
                                      value: 1,
                                      strokeWidth: 14,
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: CircularProgressIndicator(
                                      value: percent / 100,
                                      strokeWidth: 14,
                                      backgroundColor: Colors.transparent,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${percent.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Saved',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Save',
                                      style: TextStyle(color: Colors.black54)),
                                  Text(_currency.format(saved),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: primaryColor)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Remain',
                                      style: TextStyle(color: Colors.black54)),
                                  Text(_currency.format(remain),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(),

                          Row(
                            children: [
                              const Text('Target',
                                  style: TextStyle(color: Colors.black54)),
                              const Spacer(),
                              Text(_currency.format(amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),

                          if (targetDate != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text('Tanggal',
                                    style: TextStyle(color: Colors.black54)),
                                const Spacer(),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(targetDate),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _changeSavedAmount(isDeposit: true),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Deposit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    foregroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _changeSavedAmount(isDeposit: false),
                                  icon: const Icon(Icons.remove),
                                  label: const Text('Withdraw'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade50,
                                    foregroundColor: Colors.orange.shade700,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'History',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: _wishRef
                                  .collection('history')
                                  .orderBy('createdAt', descending: true)
                                  .limit(30)
                                  .snapshots(),
                              builder: (context, hs) {
                                if (hs.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final docs = hs.data?.docs ?? [];
                                if (docs.isEmpty) {
                                  return const Center(
                                      child: Text('Belum ada history'));
                                }

                                return ListView.separated(
                                  itemCount: docs.length,
                                  separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final h = docs[i].data();
                                    final type = (h['type'] ?? '').toString();
                                    final amt =
                                        (h['amount'] as num?)?.toDouble() ??
                                            0;
                                    final ts = h['createdAt'];
                                    final dt =
                                    ts is Timestamp ? ts.toDate() : null;

                                    final isDep = type == 'deposit';
                                    return ListTile(
                                      leading: Icon(
                                        isDep
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color:
                                        isDep ? primaryColor : Colors.red,
                                      ),
                                      title: Text(
                                        '${isDep ? 'Deposit' : 'Withdraw'} ${_currency.format(amt)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(dt == null
                                          ? '-'
                                          : DateFormat('EEE, dd/MM/yyyy')
                                          .format(dt)),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}