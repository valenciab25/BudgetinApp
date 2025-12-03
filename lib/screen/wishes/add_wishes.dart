// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:budgetin_app/db/db_helper.dart'; // Import DatabaseHelper
// import 'package:budgetin_app/models/wish_model.dart'; // Import WishModel
//
// // Definisi Warna yang digunakan di gambar
// const Color _primaryColor = Color(0xFF4256BB);
// const Color _accentColor = Color(0xFF4A4A4A);
// const Color _fieldBorderColor = Color(0xFFD3D3D3);
// const Color _greenColor = Color(0xFF3BBE47);
//
// class AddWishesScreen extends StatefulWidget {
//   const AddWishesScreen({super.key});
//
//   @override
//   State<AddWishesScreen> createState() => _AddWishesScreen();
// }
//
// class _AddWishesScreen extends State<AddWishesScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   DateTime? _selectedDate;
//   Color _selectedColor = _greenColor;
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   void _showColorPicker() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Color'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   height: 100,
//                   color: _selectedColor,
//                   alignment: Alignment.center,
//                   child: const Text('Selected Color', style: TextStyle(color: Colors.white)),
//                 ),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 10,
//                   children: [
//                     for (var color in [
//                       Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.cyan, Colors.blue, Colors.purple,
//                       Colors.brown, Colors.pink, Colors.grey, Colors.teal, Colors.indigo,
//                     ])
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selectedColor = color;
//                           });
//                           Navigator.of(context).pop();
//                         },
//                         child: CircleAvatar(
//                           radius: 15,
//                           backgroundColor: color,
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//       });
//     }
//   }
//
//   // Fungsi untuk save wish ke database
//   Future<void> _saveWish() async {
//     // Validasi: Pastikan semua field diisi
//     if (_nameController.text.isEmpty ||
//         _amountController.text.isEmpty ||
//         _selectedDate == null ||
//         _selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields and select an image')),
//       );
//       return;
//     }
//
//     // Parse amount
//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid amount')),
//       );
//       return;
//     }
//
//     // Konversi color ke hex string
//     final colorHex = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
//
//     // Buat WishModel
//     final newWish = WishModel(
//       id: DateTime.now().millisecondsSinceEpoch, // ID unik berdasarkan timestamp
//       name: _nameController.text,
//       amount: amount,
//       dateTarget: _selectedDate!.toIso8601String().split('T')[0], // Format YYYY-MM-DD
//       color: colorHex,
//       imagePath: _selectedImage!.path, // Path file gambar
//     );
//
//     try {
//       // Insert ke database
//       await DatabaseHelper.instance.insertWish(newWish);
//       // Pop dengan true untuk reload di wishes.dart
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save wish: $e')),
//       );
//     }
//   }
//
//   Widget _buildFieldLabel(String label) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontSize: 15,
//         fontWeight: FontWeight.w600,
//         color: _accentColor,
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text}) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       textCapitalization: TextCapitalization.words,
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: const TextStyle(color: _accentColor),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _fieldBorderColor),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _fieldBorderColor),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _primaryColor, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       ),
//     );
//   }
//
//   Widget _buildDateTargetField() {
//     String dateText = _selectedDate == null
//         ? "dd/mm/yyyy"
//         : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
//
//     return GestureDetector(
//       onTap: _selectDate,
//       child: Container(
//         height: 50,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: _fieldBorderColor),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               dateText,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: _selectedDate == null ? _accentColor.withOpacity(0.6) : _accentColor,
//               ),
//             ),
//             const Icon(Icons.calendar_today_outlined, color: _accentColor),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildColorField() {
//     return GestureDetector(
//       onTap: _showColorPicker,
//       child: Container(
//         height: 50,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: _fieldBorderColor),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Container(
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: _selectedColor,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//             const Icon(Icons.keyboard_arrow_down, color: _accentColor),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageField() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         height: 100,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: _fieldBorderColor),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: _selectedImage != null
//                   ? ClipRRect(
//                 borderRadius: BorderRadius.circular(4),
//                 child: Image.file(
//                   _selectedImage!,
//                   fit: BoxFit.cover,
//                   height: 80,
//                   width: double.infinity,
//                 ),
//               )
//                   : const Text(
//                 "Select image from gallery",
//                 style: TextStyle(color: _accentColor),
//               ),
//             ),
//             const Icon(Icons.image, color: _accentColor),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: _primaryColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           "Add Wishes",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: false,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildFieldLabel("Name"),
//               const SizedBox(height: 8),
//               _buildTextField(_nameController, "Wishes Name"),
//               const SizedBox(height: 20),
//               _buildFieldLabel("Amount"),
//               const SizedBox(height: 8),
//               _buildTextField(_amountController, "Wishes Amount", keyboardType: TextInputType.number),
//               const SizedBox(height: 20),
//               _buildFieldLabel("Date Target"),
//               const SizedBox(height: 8),
//               _buildDateTargetField(),
//               const SizedBox(height: 20),
//               _buildFieldLabel("Color"),
//               const SizedBox(height: 8),
//               _buildColorField(),
//               const SizedBox(height: 20),
//               _buildFieldLabel("Image"),
//               const SizedBox(height: 8),
//               _buildImageField(),
//               const SizedBox(height: 4),
//               const Text(
//                 "Select an image from your gallery.",
//                 style: TextStyle(fontSize: 12, color: _accentColor),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveWish, // Panggil fungsi save
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "Save Wishes",
//                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }