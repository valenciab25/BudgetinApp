// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// // Colors
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
//   bool _isSaving = false;
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
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
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
//   // SAVE WISH TO FIRESTORE ONLY
//   Future<void> _saveWish() async {
//     if (_nameController.text.isEmpty ||
//         _amountController.text.isEmpty ||
//         _selectedDate == null ||
//         _selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please complete all fields!')),
//       );
//       return;
//     }
//
//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Amount must be valid')),
//       );
//       return;
//     }
//
//     setState(() => _isSaving = true);
//
//     try {
//       final colorHex =
//           '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
//
//       await FirebaseFirestore.instance.collection("wishes").add({
//         "name": _nameController.text,
//         "amount": amount,
//         "dateTarget":
//         "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
//         "color": colorHex,
//         "imagePath": _selectedImage!.path, // local path only
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//
//       Navigator.pop(context, true);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Wish saved successfully!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => _isSaving = false);
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
//   Widget _buildTextField(TextEditingController controller, String hintText,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         hintText: hintText,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _fieldBorderColor),
//         ),
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       ),
//     );
//   }
//
//   Widget _buildDateTargetField() {
//     String dateText = _selectedDate == null
//         ? "dd/mm/yyyy"
//         : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
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
//               style: const TextStyle(fontSize: 16, color: _accentColor),
//             ),
//             const Icon(Icons.calendar_today_outlined, color: _accentColor),
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
//           children: [
//             Expanded(
//               child: _selectedImage != null
//                   ? Image.file(_selectedImage!, fit: BoxFit.cover)
//                   : const Text("Choose image",
//                   style: TextStyle(color: _accentColor)),
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
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("Add Wishes", style: TextStyle(color: Colors.white)),
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
//
//               const SizedBox(height: 20),
//               _buildFieldLabel("Amount"),
//               const SizedBox(height: 8),
//               _buildTextField(_amountController, "Amount",
//                   keyboardType: TextInputType.number),
//
//               const SizedBox(height: 20),
//               _buildFieldLabel("Target Date"),
//               const SizedBox(height: 8),
//               _buildDateTargetField(),
//
//               const SizedBox(height: 20),
//               _buildFieldLabel("Color"),
//               const SizedBox(height: 8),
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: _selectedColor,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               _buildFieldLabel("Image"),
//               const SizedBox(height: 8),
//               _buildImageField(),
//
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isSaving ? null : _saveWish,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                   ),
//                   child: _isSaving
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Save Wishes",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

// Colors
const Color _primaryColor = Color(0xFF4256BB);
const Color _accentColor = Color(0xFF4A4A4A);
const Color _fieldBorderColor = Color(0xFFD3D3D3);
const Color _greenColor = Color(0xFF3BBE47);

class AddWishesScreen extends StatefulWidget {
  const AddWishesScreen({super.key});

  @override
  State<AddWishesScreen> createState() => _AddWishesScreen();
}

class _AddWishesScreen extends State<AddWishesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  Color _selectedColor = _greenColor;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  /// SAVE WISH TO FIRESTORE (LOCAL IMAGE ONLY)
  Future<void> _saveWish() async {
    if (_nameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedDate == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please complete all fields!')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Amount must be valid')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final colorHex =
          '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

      await FirebaseFirestore.instance.collection("wishes").add({
        "name": _nameController.text,
        "amount": amount,
        "dateTarget":
        "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
        "color": colorHex,
        "imagePath": _selectedImage!.path, // LOCAL PATH
        "isLocalImage": true, // FLAG BIAR NANTI DI UI KITA TAU INI IMAGE FILE
        "createdAt": FieldValue.serverTimestamp(),
        "savedAmount": 0,

      });

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Wish saved successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _accentColor,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _fieldBorderColor),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildDateTargetField() {
    final dateText = _selectedDate == null
        ? "dd/mm/yyyy"
        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _fieldBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateText, style: const TextStyle(fontSize: 16, color: _accentColor)),
            const Icon(Icons.calendar_today_outlined, color: _accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildImageField() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _fieldBorderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : const Text("Choose image", style: TextStyle(color: _accentColor)),
            ),
            const Icon(Icons.image, color: _accentColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add Wishes", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Name"),
              const SizedBox(height: 8),
              _buildTextField(_nameController, "Wishes Name"),

              const SizedBox(height: 20),
              _buildFieldLabel("Amount"),
              const SizedBox(height: 8),
              _buildTextField(_amountController, "Amount",
                  keyboardType: TextInputType.number),

              const SizedBox(height: 20),
              _buildFieldLabel("Target Date"),
              const SizedBox(height: 8),
              _buildDateTargetField(),

              const SizedBox(height: 20),
              _buildFieldLabel("Color"),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 20),
              _buildFieldLabel("Image"),
              const SizedBox(height: 8),
              _buildImageField(),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Wishes",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
