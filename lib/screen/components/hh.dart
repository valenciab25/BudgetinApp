
// import 'package:flutter/material.dart';
//
// Widget MenuList({
//   required String title,
//   required String image,
// }) => Container(
//   width: 372,
//   height: 58,
//   padding: EdgeInsets.symmetric(horizontal: 22),
//   decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//             offset: Offset(0, 4),
//             blurRadius: 4,
//             color: Colors.black.withOpacity(.24)
//         )
//       ]
//   ),
//   child: Row(
//     children: [
//       Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//             color: const Color(0xff3A87EB).withOpacity(.1),
//             borderRadius: BorderRadius.circular(12)
//         ),
//         child: Image.asset(image),
//       ),
//       const SizedBox(width: 10,),
//       Expanded(
//         child: Text(
//           title,
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500
//           ),
//         ),
//       ),
//       Icon(Icons.keyboard_arrow_right_rounded)
//     ],
//   ),
// );