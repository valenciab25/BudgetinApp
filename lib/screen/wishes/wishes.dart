// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'add_wishes.dart';
// import 'detailWishes.dart';
// import 'package:budgetin_app/models/wish_model.dart';
//
// class WishesScreen extends StatefulWidget {
//   const WishesScreen({super.key});
//
//   @override
//   State<WishesScreen> createState() => _WishesScreenState();
// }
//
// class _WishesScreenState extends State<WishesScreen> {
//   late String userId;
//
//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser!.uid; // Ambil userId
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           "WISHES",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 25,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('artifacts')
//                     .doc('__app_id') // Ganti dengan app ID yang sesuai
//                     .collection('users')
//                     .doc(userId)
//                     .collection('wishes')
//                     .snapshots(), // Real-time listener
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         'No wishes yet. Add one!',
//                         style: TextStyle(fontSize: 18, color: Colors.grey),
//                       ),
//                     );
//                   }
//
//                   final wishes = snapshot.data!.docs.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     return WishModel.fromMap(data);
//                   }).toList();
//
//                   return ListView.builder(
//                     itemCount: wishes.length,
//                     itemBuilder: (context, index) {
//                       final wish = wishes[index];
//                       double progress = 0.5; // Placeholder; ganti dengan logika nyata
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => DetailWishesScreen(wish: wish),
//                             ),
//                           );
//                         },
//                         child: _buildWishCard(
//                           title: wish.name,
//                           imageAsset: wish.imagePath,
//                           saved: (wish.amount * progress).round(),
//                           percentage: (progress * 100).round(),
//                           cardColor: Color(int.parse(wish.color.replaceFirst('#', '0xFF'))),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AddWishesScreen()),
//                 );
//                 // Reload otomatis via StreamBuilder
//               },
//               icon: const Icon(Icons.add, color: Colors.white),
//               label: const Text(
//                 "add",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWishCard({
//     required String title,
//     required String imageAsset,
//     required int saved,
//     required int percentage,
//     required Color cardColor,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromARGB(25, 128, 128, 128),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 Icon(
//                   Icons.more_horiz,
//                   color: Colors.grey.shade700,
//                   size: 30,
//                 ),
//               ],
//             ),
//           ),
//           Center(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: Image.network(
//                   imageAsset, // Asumsi imagePath adalah URL; ganti jika local
//                   width: double.infinity,
//                   height: 150,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.image_not_supported,
//                               size: 40,
//                               color: Colors.grey,
//                             ),
//                             Text("Gambar tidak ditemukan", style: TextStyle(color: Colors.grey)),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Terkumpul : Rp ${_formatNumber(saved)}",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade800,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     "$percentage %",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: percentage / 100,
//                 backgroundColor: Colors.grey.shade300,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
//                 minHeight: 12,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
//
//   String _formatNumber(int number) {
//     return number.toString().replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//     );
//   }
// }