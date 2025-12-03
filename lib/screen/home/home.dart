import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===========================
            //     HEADER / TOP SECTION
            // ===========================
            SafeArea( // <- tambahan agar tidak mepet status bar
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5338FF), Color(0xFF3C1DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // --- Profile + Welcome Text + Notification Icon ---
                    Row(
                      children: [
                        const CircleAvatar(radius: 22, backgroundColor: Colors.white),

                        const SizedBox(width: 15),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, Welcome Back',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Good Morning, Ester!',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.notifications_none,
                            color: Colors.white, size: 28),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Total Expense & Total Balance ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Expense', style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 5),
                            Text(
                              'Rp1.515.000',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total Balance', style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 5),
                            Text(
                              'Rp4.485.000',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Progress Bar ---
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white24,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.38,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Center(
                      child: Text(
                        '38% Of Your Monthly Budget Used',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===========================
            //     RECENT TRANSACTIONS
            // ===========================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            _buildTransactionDate('Nov 05, 2025', '-1.270.000'),
            _buildTransactionItem(Icons.shopping_cart, 'Groceries', '-200.000'),
            _buildTransactionItem(Icons.directions_bus, 'Transport', '-50.000'),
            _buildTransactionItem(Icons.home, 'Rent', '-1.000.000'),
            _buildTransactionItem(Icons.restaurant, 'Food', '-20.000'),

            const SizedBox(height: 15),

            _buildTransactionDate('Nov 04, 2025', '+6.000.000   -245.000'),
            _buildTransactionItem(Icons.school, 'Education', '-100.000'),
            _buildTransactionItem(Icons.directions_bus, 'Transport', '-50.000'),
            _buildTransactionItem(Icons.local_hospital, 'Medicine', '-35.000'),
          ],
        ),
      ),
    );
  }

  // ================================
  //       TRANSACTION DATE ITEM
  // ================================
  Widget _buildTransactionDate(String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ================================
  //       TRANSACTION ITEM CARD
  // ================================
  Widget _buildTransactionItem(IconData icon, String title, String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:budgetin_app/db/db_helper.dart'; // Import DatabaseHelper
// import 'package:intl/intl.dart'; // Untuk format tanggal dan angka
//
// void main() {
//   // Penting: Set locale default ke 'id' agar NumberFormat bekerja dengan benar
//   Intl.defaultLocale = 'id';
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   List<Map<String, dynamic>> transactions = [];
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   Future<void> loadData() async {
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = '';
//       });
//       // Pastikan DatabaseHelper sudah diinisialisasi dengan benar di file db_helper.dart
//       final data = await DatabaseHelper.instance.getTransactionsMap();
//       setState(() {
//         transactions = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         // Logging error yang lebih spesifik
//         print('Error loading data: $e');
//         errorMessage = 'Gagal memuat data: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   // Hitung total expense, balance, dll dari transactions
//   double get totalExpense {
//     return transactions
//         .where((t) => t['type'] == 'spend' || t['type'] == 'spending')
//         .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
//   }
//
//   double get totalBalance {
//     double income = transactions
//         .where((t) => t['type'] == 'income')
//         .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
//     return income - totalExpense;
//   }
//
//   double get budgetUsedPercentage {
//     // Asumsikan budget bulanan hardcoded 5jt untuk demo; bisa diubah
//     const double monthlyBudget = 5000000.0;
//     // Menggunakan .clamp() untuk memastikan nilai antara 0.0 dan 1.0
//     return (totalExpense / monthlyBudget).clamp(0.0, 1.0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     if (errorMessage.isNotEmpty) {
//       return Scaffold(body: Center(child: Text(errorMessage)));
//     }
//
//     // Inisialisasi format mata uang
//     final currencyFormat = NumberFormat('#,###', 'id');
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // HEADER / TOP SECTION (ubah data dinamis)
//             SafeArea(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF5338FF), Color(0xFF3C1DFF)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Profile + Welcome (tetap statis)
//                     Row(
//                       children: [
//                         const CircleAvatar(radius: 22, backgroundColor: Colors.white),
//                         const SizedBox(width: 15),
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Hi, Welcome Back',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 'Good Morning, Ester!',
//                                 style: TextStyle(
//                                     color: Colors.white70, fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Icon(Icons.notifications_none,
//                             color: Colors.white, size: 28),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     // Total Expense & Balance (dinamis)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Total Expense', style: TextStyle(color: Colors.white70)),
//                             const SizedBox(height: 5),
//                             Text(
//                               'Rp${currencyFormat.format(totalExpense.round())}',
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             const Text('Total Balance', style: TextStyle(color: Colors.white70)),
//                             const SizedBox(height: 5),
//                             Text(
//                               'Rp${currencyFormat.format(totalBalance.round())}',
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     // Progress Bar (dinamis)
//                     Container(
//                       width: double.infinity,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Colors.white24,
//                       ),
//                       child: FractionallySizedBox(
//                         alignment: Alignment.centerLeft,
//                         widthFactor: budgetUsedPercentage,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.greenAccent,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Center(
//                       child: Text(
//                         '${(budgetUsedPercentage * 100).round()}% Of Your Monthly Budget Used',
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // RECENT TRANSACTIONS (dinamis dari database)
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 'Recent Transactions',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 10),
//             // Tampilkan beberapa transaksi terbaru
//             ...transactions.take(5).map((t) => _buildTransactionItem(
//               icon: t['type'] == 'income' ? Icons.attach_money : Icons.shopping_cart,
//               title: t['category'] ?? 'Unknown',
//               amount: '${t['type'] == 'income' ? '+' : '-'}Rp${currencyFormat.format((t['amount'] as num).round())}',
//             )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Peringatan: Fungsi ini (_buildTransactionDate) saat ini tidak dipanggil/digunakan
//   Widget _buildTransactionDate(String date, String amount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   // PERBAIKAN UTAMA: Mengubah argumen menjadi named arguments ({})
//   Widget _buildTransactionItem({
//     required IconData icon,
//     required String title,
//     required String amount
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blue.shade100,
//             child: Icon(icon, color: Colors.blue),
//           ),
//           const SizedBox(width: 15),
//           Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
//           Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }