// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:budgetin_app/models/transaction_model.dart';
// import 'package:budgetin_app/db/db_helper.dart'; // Import DatabaseHelper
// import 'package:budgetin_app/screen/transaction/category.dart';
// // Jika CategoryPage adalah 'CategoryPage' dari folder 'screen/transaction',
// // maka path ini sudah benar.
//
// class TransactionScreen extends StatefulWidget {
//   const TransactionScreen({super.key});
//
//   @override
//   State<TransactionScreen> createState() => _TransactionScreenState();
// }
//
// class _TransactionScreenState extends State<TransactionScreen> {
//   // Tetap List<Map<String, dynamic>> agar sesuai dengan pemrosesan data di bawah
//   List<Map<String, dynamic>> transactions = [];
//
//   // --- PERBAIKAN: Menambahkan indikator loading ---
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadTransactions();
//   }
//
//   Future<void> loadTransactions() async {
//     // 1. Set loading menjadi true
//     setState(() {
//       isLoading = true;
//     });
//
//     // 2. Mengubah panggilan fungsi dari getTransactions() ke getTransactionsMap()
//     // agar tipe kembalian (List<Map<String, dynamic>>) sesuai dengan 'transactions'.
//     final data = await DatabaseHelper.instance.getTransactionsMap();
//
//     // 3. Set data dan loading menjadi false
//     setState(() {
//       transactions = data;
//       isLoading = false;
//     });
//   }
//
//   /// group transactions by date (yyyy-MM-dd) in descending order
//   Map<String, List<Map<String, dynamic>>> groupedByDate() {
//     final Map<String, List<Map<String, dynamic>>> map = {};
//     for (var t in transactions) {
//       final key = t['date'] ?? '';
//       map.putIfAbsent(key, () => []).add(t);
//     }
//     // keep descending by date
//     final sortedKeys = map.keys.toList()
//       ..sort((a, b) => b.compareTo(a));
//     final ordered = <String, List<Map<String, dynamic>>>{};
//     for (var k in sortedKeys) ordered[k] = map[k]!;
//     return ordered;
//   }
//
//   String fmt(int n) => NumberFormat('#,###', 'id').format(n);
//
//   String fmtAmount(dynamic amt) {
//     if (amt == null) return '0';
//     if (amt is num) return NumberFormat('#,###', 'id').format(amt.round());
//     final parsed = double.tryParse(amt.toString());
//     if (parsed == null) return amt.toString();
//     return NumberFormat('#,###', 'id').format(parsed.round());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final grouped = groupedByDate();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF392DD2),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // HEADER (Tidak Berubah)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.maybePop(context),
//                     child: const Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Transaction',
//                     style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const Spacer(),
//                   const Icon(Icons.notifications_none, color: Colors.white),
//                 ],
//               ),
//             ),
//
//             // SUMMARY (Tidak Berubah)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // compute totals
//                   Builder(builder: (ctx) {
//                     double totalIncome = transactions.where((e) => e['type'] == 'income').fold(0.0, (p, e) => p + (e['amount'] is num ? (e['amount'] as num).toDouble() : double.tryParse(e['amount'].toString()) ?? 0));
//                     double totalSpending = transactions.where((e) => e['type'] == 'spend' || e['type'] == 'spending').fold(0.0, (p, e) => p + (e['amount'] is num ? (e['amount'] as num).toDouble() : double.tryParse(e['amount'].toString()) ?? 0));
//                     final balance = totalIncome - totalSpending;
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           NumberFormat('#,###', 'id').format(balance.round()),
//                           style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 6),
//                         Text('Spending : -' + NumberFormat('#,###', 'id').format(totalSpending.round()), style: const TextStyle(color: Colors.white70)),
//                         Text('Income : +' + NumberFormat('#,###', 'id').format(totalIncome.round()), style: const TextStyle(color: Colors.white70)),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             // Buttons Add Spending / Add Income (Tidak Berubah)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () async {
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => CategoryPage(type: 'spend')),
//                         );
//                         // Reload data jika ada hasil yang kembali (artinya transaksi baru telah dibuat)
//                         if (result == true) await loadTransactions();
//                       },
//                       icon: const Icon(Icons.add, color: Colors.black),
//                       label: const Text('Add Spending', style: TextStyle(color: Colors.black)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () async {
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => CategoryPage(type: 'income')),
//                         );
//                         // Reload data jika ada hasil yang kembali (artinya transaksi baru telah dibuat)
//                         if (result == true) await loadTransactions();
//                       },
//                       icon: const Icon(Icons.add, color: Colors.black),
//                       label: const Text('Add Income', style: TextStyle(color: Colors.black)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFDFF6E9),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 18),
//
//             // WHITE ROUNDED AREA WITH HISTORY
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(14.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Recent History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 10),
//                       Expanded(
//                         // --- PERBAIKAN: Menambahkan penanganan loading ---
//                         child: isLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : grouped.isEmpty
//                             ? const Center(child: Text('No transactions yet'))
//                             : ListView(
//                           children: grouped.entries.map((entry) {
//                             final dateKey = entry.key;
//                             final items = entry.value;
//                             // compute day total
//                             double dayTotal = items.fold(0.0, (p, e) => p + (e['amount'] is num ? (e['amount'] as num).toDouble() : double.tryParse(e['amount'].toString()) ?? 0) * (e['type'] == 'income' ? 1 : -1));
//                             return Column(
//                               children: [
//                                 // date header card
//                                 Container(
//                                   margin: const EdgeInsets.only(bottom: 8),
//                                   decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
//                                   child: ListTile(
//                                     // Memastikan dateKey bukan string kosong sebelum parsing
//                                     leading: Text(
//                                         dateKey.isNotEmpty
//                                             ? DateFormat('MMM dd, yyyy').format(DateTime.parse(dateKey))
//                                             : 'Unknown Date',
//                                         style: const TextStyle(fontWeight: FontWeight.bold)
//                                     ),
//                                     trailing: Text(
//                                       (dayTotal < 0 ? '-' : '+') + fmt(dayTotal.abs().round()),
//                                       style: TextStyle(fontWeight: FontWeight.bold, color: dayTotal < 0 ? Colors.red : Colors.green),
//                                     ),
//                                   ),
//                                 ),
//                                 // items
//                                 ...items.map((t) {
//                                   // Mengambil icon berdasarkan kategori.
//                                   // (Perlu penyesuaian lebih lanjut jika ada mapping icon yang spesifik)
//                                   IconData icon = t['type'] == 'income' ? Icons.attach_money : Icons.shopping_cart;
//                                   if (t['category'] == 'Salary') icon = Icons.payments;
//
//                                   return Column(
//                                     children: [
//                                       ListTile(
//                                         leading: CircleAvatar(
//                                           backgroundColor: Colors.blue.shade50,
//                                           // Mengganti icon statis
//                                           child: Icon(icon, color: Colors.blue),
//                                         ),
//                                         title: Text(t['category'] ?? 'No Category'),
//                                         subtitle: Text(t['note'] ?? ''), // Menambahkan Note sebagai subtitle
//                                         trailing: Text(
//                                           (t['type'] == 'income' ? '+' : '-') + fmtAmount(t['amount']),
//                                           style: TextStyle(color: t['type'] == 'income' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                       const Divider(height: 1),
//                                     ],
//                                   );
//                                 }).toList(),
//                                 const SizedBox(height: 12),
//                               ],
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }