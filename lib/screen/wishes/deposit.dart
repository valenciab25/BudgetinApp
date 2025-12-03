import 'package:flutter/material.dart';
// Hapus: import 'package:flutter/services.dart'; karena tidak digunakan.

class AddDepositScreen extends StatefulWidget {
  @override
  // Perbaiki: Nama State class harus mengikuti konvensi penamaan
  _AddDepositScreenState createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  final TextEditingController _depositAmountController = TextEditingController();
  double _currentSaveAmount = 12000000.0; // Contoh saldo saat ini

  @override
  void dispose() {
    _depositAmountController.dispose();
    super.dispose();
  }

  // Fungsi untuk memformat mata uang
  String _formatCurrency(double amount) {
    return 'RP ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: Text(
          'Deposit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Bagian Ikon Deposit ---
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Deposit',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 24),
                  // --- Saldo Save ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Save',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      Text(
                        _formatCurrency(_currentSaveAmount),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // --- Input Jumlah Deposit ---
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      // Memastikan keyboard bawaan tidak muncul
                      readOnly: true,
                      controller: _depositAmountController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // --- Bagian Keyboard Numerik Kustom ---
          _buildNumericKeyboard(),
        ],
      ),
    );
  }

  // --- Keyboard Kustom ---
  Widget _buildNumericKeyboard() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          // Menggunakan string unik untuk tombol khusus agar mudah diproses di _handleKeyPress
          _buildKeyboardRow(['1', '2', '3', 'minus']),
          _buildKeyboardRow(['4', '5', '6', 'backspace']),
          _buildKeyboardRow(['7', '8', '9', 'clear']),
          _buildKeyboardRow(['*#', '0', '.', 'submit']),
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
    Color buttonColor = Colors.white;
    Color textColor = Colors.black;
    Widget keyContent;
    double fontSize = 28;

    if (key == 'submit') {
      buttonColor = Colors.blue;
      textColor = Colors.white;
      keyContent = Icon(Icons.arrow_right_alt, color: textColor, size: 30);
    } else if (key == 'backspace') {
      buttonColor = Colors.grey[300]!;
      keyContent = Icon(Icons.backspace_outlined, color: Colors.black87, size: 24);
    } else if (key == 'clear' || key == 'minus' || key == '*#') {
      buttonColor = Colors.grey[300]!;
      // Tampilkan teks sesuai kebutuhan (C untuk clear, - untuk minus)
      keyContent = Text(key == 'clear' ? 'C' : (key == 'minus' ? '-' : key), style: TextStyle(fontSize: fontSize, color: Colors.black));
    } else {
      keyContent = Text(key, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400, color: textColor));
    }

    return InkWell(
      onTap: () {
        _handleKeyPress(key);
      },
      child: Container(
        margin: EdgeInsets.all(1),
        height: 60,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 1,
              offset: Offset(0, 0.5),
            ),
          ],
        ),
        child: Center(child: keyContent),
      ),
    );
  }

  void _handleKeyPress(String key) {
    String currentText = _depositAmountController.text;
    if (key == 'submit') {
      // Tombol untuk submit deposit
      // Hanya mengizinkan angka di input, dan parsing sebagai double
      String cleanText = currentText.replaceAll('.', '');
      double? amount = double.tryParse(cleanText);

      if (amount != null && amount > 0) {
        setState(() {
          _currentSaveAmount += amount;
          _depositAmountController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deposit ${_formatCurrency(amount)} berhasil ditambahkan!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jumlah deposit tidak valid.')),
        );
      }
    } else if (key == 'backspace') {
      // Tombol backspace
      if (currentText.isNotEmpty) {
        _depositAmountController.text = currentText.substring(0, currentText.length - 1);
      }
    } else if (key == 'clear') {
      // Tombol untuk menghapus semua input
      _depositAmountController.clear();
    } else if (key == 'minus' || key == '*#' || key == '.') {
      // Abaikan tombol-tombol yang tidak relevan (minus, *#, dan titik/koma)
      // Karena kita berasumsi deposit adalah bilangan bulat Rupiah tanpa desimal.
    } else {
      // Angka (1-9, 0)
      _depositAmountController.text = currentText + key;
    }
  }
}