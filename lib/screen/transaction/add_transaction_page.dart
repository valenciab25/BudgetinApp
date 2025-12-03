// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:budgetin_app/db/db_helper.dart';
// import '/db/db_helper.dart';
//
// class AddTransactionPage extends StatefulWidget {
//   final String category;
//   final String type; // 'income' or 'spend'
//
//   const AddTransactionPage({super.key, required this.category, required this.type});
//
//   @override
//   State<AddTransactionPage> createState() => _AddTransactionPageState();
// }
//
// class _AddTransactionPageState extends State<AddTransactionPage> {
//   String display = '0';
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay selectedTime = TimeOfDay.now();
//   final TextEditingController noteCtrl = TextEditingController();
//
//   void _append(String s) {
//     setState(() {
//       if (display == '0') display = s;
//       else display += s;
//     });
//   }
//
//   void _clear() {
//     setState(() {
//       display = '0';
//     });
//   }
//
//   Future<void> _pickDate() async {
//     final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2035));
//     if (d != null) setState(() => selectedDate = d);
//   }
//
//   Future<void> _pickTime() async {
//     final t = await showTimePicker(context: context, initialTime: selectedTime);
//     if (t != null) setState(() => selectedTime = t);
//   }
//
//   double _parseDisplayToDouble() {
//     // replace separators and parse safely
//     final s = display.replaceAll('.', '').replaceAll(',', '.');
//     return double.tryParse(s) ?? 0.0;
//   }
//
//   Future<void> _saveTransaction() async {
//     final amount = _parseDisplayToDouble();
//     if (amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
//       return;
//     }
//
//     final data = {
//       'type': widget.type,
//       'category': widget.category,
//       'amount': amount,
//       'date': DateFormat('yyyy-MM-dd').format(selectedDate),
//       'note': noteCtrl.text,
//     };
//
//     await DatabaseHelper.instance.insertTransaction(data);
//
//     // return success
//     Navigator.pop(context, true);
//   }
//
//   Widget _numButton(String s) {
//     return GestureDetector(
//       onTap: () {
//         if (s == ',') {
//           // prevent multiple commas
//           if (!display.contains(',')) _append(',');
//         } else {
//           _append(s);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.all(6),
//         decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
//         child: Center(child: Text(s, style: const TextStyle(fontSize: 24))),
//       ),
//     );
//   }
//
//   Widget _opButton(String s, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.all(6),
//         decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
//         child: Center(child: Text(s, style: const TextStyle(fontSize: 20, color: Colors.white))),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final amountDisplay = display; // you can format here if wanted
//     return Scaffold(
//       backgroundColor: const Color(0xFF392DD2),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // header row
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               child: Row(
//                 children: [
//                   IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
//                   const SizedBox(width: 8),
//                   CircleAvatar(radius: 22, backgroundColor: Colors.blue.shade50, child: const Icon(Icons.shopping_cart, color: Colors.blue)),
//                   const Spacer(),
//                   Text(amountDisplay, style: const TextStyle(color: Colors.white, fontSize: 28)),
//                   const SizedBox(width: 12),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // white card with date/time/note
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 18),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.calendar_today),
//                     title: const Text('Date'),
//                     trailing: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
//                     onTap: _pickDate,
//                   ),
//                   const Divider(),
//                   ListTile(
//                     leading: const Icon(Icons.access_time),
//                     title: const Text('Time'),
//                     trailing: Text(selectedTime.format(context)),
//                     onTap: _pickTime,
//                   ),
//                   const Divider(),
//                   TextField(
//                     controller: noteCtrl,
//                     decoration: const InputDecoration(prefixIcon: Icon(Icons.edit), hintText: 'Input Notes'),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 14),
//
//             // check FAB aligned right
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 24.0),
//                 child: FloatingActionButton(
//                   backgroundColor: Colors.blue,
//                   onPressed: _saveTransaction,
//                   child: const Icon(Icons.check, size: 30),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             // calculator grid
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: GridView.count(
//                   crossAxisCount: 4,
//                   childAspectRatio: 1.2,
//                   children: [
//                     _numButton('7'),
//                     _numButton('8'),
//                     _numButton('9'),
//                     _opButton('÷', () {}),
//                     _numButton('4'),
//                     _numButton('5'),
//                     _numButton('6'),
//                     _opButton('×', () {}),
//                     _numButton('1'),
//                     _numButton('2'),
//                     _numButton('3'),
//                     _opButton('-', () {}),
//                     _numButton(','),
//                     _numButton('0'),
//                     _opButton('C', _clear),
//                     _opButton('+', () {}),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
