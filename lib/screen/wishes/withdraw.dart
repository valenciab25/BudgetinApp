import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _withdrawAmountController = TextEditingController();
  // Contoh saldo saat ini, sama seperti di halaman Deposit
  double _currentSaveAmount = 12000000.0;

  @override
  void dispose() {
    _withdrawAmountController.dispose();
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
      appBar: AppBar(
        // Menggunakan warna biru tua yang sama
        backgroundColor: Colors.deepPurple,
        title: Text(
          // Judul diubah menjadi Withdraw
          'Withdraw',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // Warna ikon diubah menjadi oranye/kuning
                      color: Colors.orange[400],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      // Ikon diubah menjadi arah ke atas (Withdraw)
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Withdraw',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Save',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        _formatCurrency(_currentSaveAmount),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple), // Warna border bisa disesuaikan
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _withdrawAmountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bagian keyboard numerik
          _buildNumericKeyboard(),
        ],
      ),
    );
  }

  // Struktur keyboard numerik sama dengan Deposit
  Widget _buildNumericKeyboard() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          _buildKeyboardRow(['1', '2', '3', '⌫']), // Mengganti '-' dengan '⌫' (Backspace) atau biarkan sesuai gambar
          _buildKeyboardRow(['4', '5', '6', '⌤']), // Mengganti '←' dengan '⌤' (Enter/Confirm) atau biarkan sesuai gambar
          _buildKeyboardRow(['7', '8', '9', '×']),
          _buildKeyboardRow(['*#', '0', '.', '→']),
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
    bool isSpecialKey = ['⌫', '⌤', '×', '*#', '.', '→'].contains(key);
    Color buttonColor = isSpecialKey ? Colors.grey[300]! : Colors.white;
    Color textColor = Colors.black;

    // Tombol submit berwarna biru
    if (key == '→') {
      buttonColor = Colors.blue;
      textColor = Colors.white;
    }
    // Tombol backspace/hapus di gambar memiliki latar belakang berbeda
    else if (key == '×' || key == '⌫' || key == '⌤') {
      buttonColor = Colors.grey[300]!;
      textColor = Colors.black;
    }

    // Mengganti tampilan ikon khusus
    Widget keyContent;
    if (key == '⌫') {
      keyContent = Icon(Icons.backspace_outlined, size: 22, color: textColor); // Backspace
    } else if (key == '⌤') {
      keyContent = Icon(Icons.keyboard_return, size: 22, color: textColor); // Simbol enter
    } else if (key == '×') {
      keyContent = Icon(Icons.close, size: 22, color: textColor); // Simbol hapus
    } else {
      keyContent = Text(
        key,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
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
        ),
        child: Center(child: keyContent),
      ),
    );
  }

  void _handleKeyPress(String key) {
    String currentText = _withdrawAmountController.text;
    if (key == '→') {
      // Tombol untuk submit withdraw
      double? amount = double.tryParse(currentText);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jumlah withdraw tidak valid.')),
        );
        return;
      }

      if (amount > _currentSaveAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saldo tidak mencukupi untuk withdraw ${_formatCurrency(amount)}.')),
        );
      } else {
        // Logika withdraw berhasil
        setState(() {
          _currentSaveAmount -= amount;
          _withdrawAmountController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdraw ${_formatCurrency(amount)} berhasil.')),
        );
      }

    } else if (key == '⌫' || key == '×' || key == '⌤') {
      // Tombol backspace (⌫) atau clear (× / ⌤ - di gambar tombol ini berbeda)
      if (key == '⌫' && currentText.isNotEmpty) {
        // Backspace
        _withdrawAmountController.text = currentText.substring(0, currentText.length - 1);
      } else if (key == '×' || key == '⌤') {
        // Clear all (as per typical app behavior for the clear button)
        _withdrawAmountController.clear();
      }
    } else if (key == '-' || key == '*#') {
      // Abaikan atau tambahkan fungsi khusus jika diperlukan
    } else if (key == '.') {
      // Hanya izinkan satu titik desimal
      if (!currentText.contains('.')) {
        _withdrawAmountController.text = currentText + key;
      }
    } else {
      // Angka
      _withdrawAmountController.text = currentText + key;
    }
  }
}