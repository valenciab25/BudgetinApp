// import 'package:flutter/material.dart';
// import 'add_transaction_page.dart';
//
// class CategoryPage extends StatelessWidget {
//   final String type; // "spend" atau "income"
//
//   const CategoryPage({super.key, required this.type});
//
//   // Map kategori -> icon
//   List<Map<String, dynamic>> getCategoriesList() {
//     if (type == "income") {
//       return [
//         {'name': 'Salary', 'icon': Icons.payments},
//         {'name': 'Donation', 'icon': Icons.volunteer_activism},
//         {'name': 'Saving', 'icon': Icons.savings},
//         {'name': 'Dividen', 'icon': Icons.show_chart},
//         {'name': 'Refund', 'icon': Icons.reply},
//         {'name': 'Sales', 'icon': Icons.sell},
//         {'name': 'Bonus', 'icon': Icons.workspace_premium},
//         {'name': 'Voucher', 'icon': Icons.card_giftcard},
//         {'name': 'Other', 'icon': Icons.more_horiz},
//       ];
//     } else {
//       return [
//         {'name': 'Groceries', 'icon': Icons.shopping_cart},
//         {'name': 'Transport', 'icon': Icons.directions_bus},
//         {'name': 'Rent', 'icon': Icons.home},
//         {'name': 'Food', 'icon': Icons.restaurant},
//         {'name': 'Medicine', 'icon': Icons.local_hospital},
//         {'name': 'Cosmetic', 'icon': Icons.brush},
//         {'name': 'Utilities', 'icon': Icons.lightbulb},
//         {'name': 'Hobbies', 'icon': Icons.videogame_asset},
//         {'name': 'Sport', 'icon': Icons.sports_soccer},
//       ];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final list = getCategoriesList();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF392DD2),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
//                   const SizedBox(width: 12),
//                   Text(type == 'spend' ? 'Add Spending' : 'Add Income', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: list.length + 1,
//                   itemBuilder: (context, i) {
//                     if (i == 0) {
//                       // Add Category button area
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Center(
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               // placeholder: add category (not implemented)
//                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Category (not implemented)')));
//                             },
//                             icon: const Icon(Icons.add),
//                             label: const Text('Add Category'),
//                             style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                           ),
//                         ),
//                       );
//                     }
//
//                     final item = list[i - 1];
//                     return Column(
//                       children: [
//                         ListTile(
//                           leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(item['icon'], color: Colors.blue)),
//                           title: Text(item['name']),
//                           onTap: () async {
//                             final result = await Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (_) => AddTransactionPage(category: item['name'], type: type)),
//                             );
//                             if (result == true) {
//                               Navigator.pop(context, true);
//                             }
//                           },
//                         ),
//                         const Divider(height: 1),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
