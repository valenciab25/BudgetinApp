import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawPage extends StatefulWidget {
  final String wishId;
  const WithdrawPage({super.key, required this.wishId});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _withdrawAmountController = TextEditingController();

  @override
  void dispose() {
    _withdrawAmountController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    final s = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return 'Rp $s';
  }

  Future<void> _submitWithdraw(int amount) async {
    final wishRef = FirebaseFirestore.instance.collection('wishes').doc(widget.wishId);
    final txRef = wishRef.collection('transactions').doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(wishRef);
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) throw Exception('Wish tidak ditemukan');

      final saved = (data['savedAmount'] as num? ?? 0).toInt();
      if (amount > saved) throw Exception('Saldo tidak cukup');

      final newSaved = saved - amount;

      tx.update(wishRef, {'savedAmount': newSaved});
      tx.set(txRef, {
        'type': 'withdraw',
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishRef = FirebaseFirestore.instance.collection('wishes').doc(widget.wishId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Withdraw", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: wishRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!.data() as Map<String, dynamic>?;
          final saved = (data?['savedAmount'] as num? ?? 0).toInt();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 8),
                      const Text("Withdraw", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Save", style: TextStyle(fontSize: 16)),
                          Text(
                            _formatCurrency(saved),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          readOnly: true,
                          controller: _withdrawAmountController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24),
                          decoration: const InputDecoration(hintText: '0', border: InputBorder.none),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              _buildNumericKeyboard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNumericKeyboard() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          _buildKeyboardRow(['1', '2', '3', '⌫']),
          _buildKeyboardRow(['4', '5', '6', 'C']),
          _buildKeyboardRow(['7', '8', '9', '']),
          _buildKeyboardRow(['', '0', '', '→']),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) => Expanded(child: _buildKeyboardButton(key))).toList(),
    );
  }

  Widget _buildKeyboardButton(String key) {
    if (key.isEmpty) {
      return Container(height: 60, margin: const EdgeInsets.all(1), color: Colors.grey[200]);
    }

    bool isSpecial = ['⌫', 'C', '→'].contains(key);
    Color color = isSpecial ? Colors.grey[300]! : Colors.white;
    Color textColor = Colors.black;

    if (key == '→') {
      color = Colors.blue;
      textColor = Colors.white;
    }

    Widget content;
    if (key == '⌫') {
      content = Icon(Icons.backspace_outlined, color: textColor);
    } else {
      content = Text(key, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: textColor));
    }

    return InkWell(
      onTap: () => _handleKeyPress(key),
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Center(child: content),
      ),
    );
  }

  void _handleKeyPress(String key) async {
    final text = _withdrawAmountController.text;

    if (key == '→') {
      final amount = int.tryParse(text) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jumlah withdraw tidak valid")));
        return;
      }

      try {
        await _submitWithdraw(amount);
        _withdrawAmountController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Withdraw ${_formatCurrency(amount)} berhasil")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
          );
        }
      }
      return;
    }

    if (key == '⌫') {
      if (text.isNotEmpty) {
        _withdrawAmountController.text = text.substring(0, text.length - 1);
      }
      return;
    }

    if (key == 'C') {
      _withdrawAmountController.clear();
      return;
    }

    if (RegExp(r'^\d$').hasMatch(key)) {
      _withdrawAmountController.text = text + key;
    }
  }
}