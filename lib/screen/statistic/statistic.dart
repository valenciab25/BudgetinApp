// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// class StatisticPage extends StatefulWidget {
//   const StatisticPage({super.key});
//
//   @override
//   State<StatisticPage> createState() => _StatisticPageState();
// }
//
// class _StatisticPageState extends State<StatisticPage> {
//   String filter = "Weekly"; // Daily | Weekly | Monthly | Year
//   int tabIndex = 0; // 0 = Net, 1 = Spend
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
//     return FirebaseFirestore.instance
//         .collection("transactions")
//         .orderBy("createdAt", descending: false)
//         .snapshots();
//   }
//
//   double _amount(dynamic raw) {
//     if (raw == null) return 0;
//     if (raw is num) return raw.toDouble();
//     return double.tryParse(raw.toString()) ?? 0;
//   }
//
//   bool _isIncome(String type) => type.toLowerCase() == "income";
//   bool _isExpense(String type) =>
//       type.toLowerCase() == "spend" || type.toLowerCase() == "expense";
//
//   DateTime? _dt(Map<String, dynamic> r) {
//     final raw = r["createdAt"];
//     if (raw is Timestamp) return raw.toDate();
//     return null;
//   }
//
//   DateTime _refDate(List<Map<String, dynamic>> rows) {
//     DateTime best = DateTime(2000);
//     for (final r in rows) {
//       final d = _dt(r);
//       if (d != null && d.isAfter(best)) best = d;
//     }
//     return best.year == 2000 ? DateTime.now() : best;
//   }
//
//   Map<String, double> _totals(List<Map<String, dynamic>> rows) {
//     double income = 0, expense = 0;
//     for (final r in rows) {
//       final type = (r["type"] ?? "").toString();
//       final amt = _amount(r["amount"]);
//       if (_isIncome(type)) income += amt;
//       if (_isExpense(type)) expense += amt;
//     }
//     return {
//       "income": income,
//       "expense": expense,
//       "balance": income - expense,
//     };
//   }
//
//   // ===== Buckets =====
//   late List<double> netBuckets;   // income - spend
//   late List<double> spendBuckets; // spend only
//
//   void _buildBuckets(List<Map<String, dynamic>> rows) {
//     final now = _refDate(rows);
//
//     void addToBucket(int idx, Map<String, dynamic> r) {
//       final amt = _amount(r["amount"]);
//       final type = (r["type"] ?? "").toString();
//
//       if (_isIncome(type)) netBuckets[idx] += amt;
//       if (_isExpense(type)) {
//         netBuckets[idx] -= amt;
//         spendBuckets[idx] += amt;
//       }
//     }
//
//     if (filter == "Daily") {
//       netBuckets = List.filled(24, 0);
//       spendBuckets = List.filled(24, 0);
//
//       for (final r in rows) {
//         final dt = _dt(r);
//         if (dt == null) continue;
//         if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
//           addToBucket(dt.hour, r);
//         }
//       }
//       return;
//     }
//
//     if (filter == "Weekly") {
//       netBuckets = List.filled(7, 0);
//       spendBuckets = List.filled(7, 0);
//
//       final baseDay = DateTime(now.year, now.month, now.day);
//       final startOfWeek = baseDay.subtract(Duration(days: baseDay.weekday - 1)); // Mon
//       final end = startOfWeek.add(const Duration(days: 7));
//
//       for (final r in rows) {
//         final dt = _dt(r);
//         if (dt == null) continue;
//         if (!dt.isBefore(startOfWeek) && dt.isBefore(end)) {
//           final idx = dt.weekday - 1;
//           addToBucket(idx, r);
//         }
//       }
//       return;
//     }
//
//     if (filter == "Monthly") {
//       netBuckets = List.filled(30, 0);
//       spendBuckets = List.filled(30, 0);
//
//       final start = DateTime(now.year, now.month, 1);
//       final end = DateTime(now.year, now.month + 1, 1);
//
//       for (final r in rows) {
//         final dt = _dt(r);
//         if (dt == null) continue;
//         if (!dt.isBefore(start) && dt.isBefore(end)) {
//           final day = dt.day;
//           if (day >= 1 && day <= 30) {
//             addToBucket(day - 1, r);
//           }
//         }
//       }
//       return;
//     }
//
//     netBuckets = List.filled(12, 0);
//     spendBuckets = List.filled(12, 0);
//
//     final start = DateTime(now.year, 1, 1);
//     final end = DateTime(now.year + 1, 1, 1);
//
//     for (final r in rows) {
//       final dt = _dt(r);
//       if (dt == null) continue;
//       if (!dt.isBefore(start) && dt.isBefore(end)) {
//         addToBucket(dt.month - 1, r);
//       }
//     }
//   }
//
//   // ===== Chart helpers =====
//   double _absMax(List<double> arr) {
//     double mx = 0;
//     for (final v in arr) {
//       if (v.abs() > mx) mx = v.abs();
//     }
//     return mx <= 0 ? 10 : mx * 1.2;
//   }
//
//   double _minYNet() {
//     double mn = 0;
//     for (final v in netBuckets) {
//       if (v < mn) mn = v;
//     }
//     if (mn >= 0) return 0;
//     return mn * 1.2;
//   }
//
//   double _maxYNet() => _absMax(netBuckets);
//   double _maxYSpend() {
//     double mx = 0;
//     for (final v in spendBuckets) {
//       if (v > mx) mx = v;
//     }
//     return mx <= 0 ? 10 : mx * 1.2;
//   }
//
//   // PERBAIKAN: Lebar chart disesuaikan layar agar Weekly tidak kecil
//   double _chartWidth(double screenWidth) {
//     if (filter == "Daily") return 24 * 30;
//     if (filter == "Weekly") return screenWidth - 60; // Mengisi layar
//     if (filter == "Monthly") return 30 * 20;
//     return screenWidth - 60; // Year juga pas layar
//   }
//
//   List<BarChartGroupData> _groups(List<double> data) {
//     // Batang diperlebar untuk Weekly/Year agar proporsional
//     double bWidth = (filter == "Weekly" || filter == "Year") ? 25 : 14;
//
//     return List.generate(data.length, (i) {
//       return BarChartGroupData(
//         x: i,
//         barRods: [
//           BarChartRodData(
//             toY: data[i],
//             width: bWidth,
//             color: const Color(0xFF5338FF),
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ],
//       );
//     });
//   }
//
//   Widget _bottomTitle(double value, TitleMeta meta) {
//     final i = value.toInt();
//
//     if (filter == "Daily") {
//       if (i % 3 != 0) return const SizedBox.shrink();
//       return Text("${i}h", style: const TextStyle(fontSize: 10));
//     }
//
//     if (filter == "Weekly") {
//       const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
//       if (i < 0 || i > 6) return const SizedBox.shrink();
//       return Text(days[i], style: const TextStyle(fontSize: 10));
//     }
//
//     if (filter == "Monthly") {
//       if ((i + 1) % 5 != 0) return const SizedBox.shrink();
//       return Text("${i + 1}", style: const TextStyle(fontSize: 10));
//     }
//
//     const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
//     if (i < 0 || i > 11) return const SizedBox.shrink();
//     return Text(months[i], style: const TextStyle(fontSize: 10));
//   }
//
//   Widget _chip(String name) {
//     final active = filter == name;
//     return InkWell(
//       onTap: () => setState(() => filter = name),
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: active ? const Color(0xFF5338FF) : const Color(0xFFF2F3F7),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           name,
//           style: TextStyle(
//             color: active ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _tab(String text, int idx) {
//     final active = tabIndex == idx;
//     return Expanded(
//       child: InkWell(
//         onTap: () => setState(() => tabIndex = idx),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: active ? const Color(0xFF5338FF) : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: active ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _metricCard({required String title, required double value, required IconData icon}) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x12000000)),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF2F3F7),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: const Color(0xFF5338FF)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
//                 const SizedBox(height: 6),
//                 Text(
//                   "Rp${value.toStringAsFixed(0)}",
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _chartCard({
//     required String title,
//     required List<double> data,
//     required double maxY,
//     required double screenWidth,
//     double? minY,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x12000000)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 260,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SizedBox(
//                 width: _chartWidth(screenWidth),
//                 child: BarChart(
//                   BarChartData(
//                     minY: minY,
//                     maxY: maxY,
//                     barGroups: _groups(data),
//                     borderData: FlBorderData(show: false),
//                     gridData: const FlGridData(show: true, drawVerticalLine: false),
//                     titlesData: FlTitlesData(
//                       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 44,
//                           getTitlesWidget: (v, meta) =>
//                               Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
//                         ),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 28,
//                           getTitlesWidget: _bottomTitle,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Ambil lebar layar sekali di sini
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: const Color(0xffF5F6FA),
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: getTransactions(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             final rows = (snapshot.data?.docs ?? []).map((d) => d.data()).toList();
//             final totals = _totals(rows);
//             _buildBuckets(rows);
//
//             return SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 520),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Analysis",
//                           style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 14),
//
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _metricCard(
//                               title: "Balance",
//                               value: totals["balance"] ?? 0,
//                               icon: Icons.account_balance_wallet,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _metricCard(
//                               title: "Spend",
//                               value: totals["expense"] ?? 0,
//                               icon: Icons.trending_down,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 14),
//
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _chip("Daily"),
//                             _chip("Weekly"),
//                             _chip("Monthly"),
//                             _chip("Year"),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 14),
//
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Row(
//                           children: [
//                             _tab("Balance (Net)", 0),
//                             _tab("Spend", 1),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       if (tabIndex == 0)
//                         _chartCard(
//                           title: "Balance (Net)",
//                           data: netBuckets,
//                           minY: _minYNet(),
//                           maxY: _maxYNet(),
//                           screenWidth: screenWidth, // Oper lebar layar
//                         )
//                       else
//                         _chartCard(
//                           title: "Spend (Expense)",
//                           data: spendBuckets,
//                           maxY: _maxYSpend(),
//                           screenWidth: screenWidth, // Oper lebar layar
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();


}

class _StatisticPageState extends State<StatisticPage> {
  final NumberFormat _rupiahFormat =
  NumberFormat.decimalPattern('id');

  String filter = "Weekly"; // Daily | Weekly | Monthly | Year
  int tabIndex = 0; // 0 = Net, 1 = Spend

  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions() {
    return FirebaseFirestore.instance
        .collection("transactions")
        .orderBy("createdAt", descending: false)
        .snapshots();
  }

  double _amount(dynamic raw) {
    if (raw == null) return 0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 0;
  }

  bool _isIncome(String type) => type.toLowerCase() == "income";
  bool _isExpense(String type) =>
      type.toLowerCase() == "spend" || type.toLowerCase() == "expense";

  DateTime? _dt(Map<String, dynamic> r) {
    final raw = r["createdAt"];
    if (raw is Timestamp) return raw.toDate();
    return null;
  }

  DateTime _refDate(List<Map<String, dynamic>> rows) {
    DateTime best = DateTime(2000);
    for (final r in rows) {
      final d = _dt(r);
      if (d != null && d.isAfter(best)) best = d;
    }
    return best.year == 2000 ? DateTime.now() : best;
  }

  Map<String, double> _totals(List<Map<String, dynamic>> rows) {
    double income = 0, expense = 0;
    for (final r in rows) {
      final type = (r["type"] ?? "").toString();
      final amt = _amount(r["amount"]);
      if (_isIncome(type)) income += amt;
      if (_isExpense(type)) expense += amt;
    }
    return {
      "income": income,
      "expense": expense,
      "balance": income - expense,
    };
  }

  // ===== Buckets =====
  late List<double> netBuckets;   // income - spend
  late List<double> spendBuckets; // spend only

  void _buildBuckets(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();

    void addToBucket(int idx, Map<String, dynamic> r) {
      final amt = _amount(r["amount"]);
      final type = (r["type"] ?? "").toString();

      if (_isIncome(type)) netBuckets[idx] += amt;
      if (_isExpense(type)) {
        netBuckets[idx] -= amt;
        spendBuckets[idx] += amt;
      }
    }

    if (filter == "Daily") {
      netBuckets = List.filled(24, 0);
      spendBuckets = List.filled(24, 0);

      for (final r in rows) {
        final dt = _dt(r);
        if (dt == null) continue;
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          addToBucket(dt.hour, r);
        }
      }
      return;
    }

    if (filter == "Weekly") {
      netBuckets = List.filled(7, 0);
      spendBuckets = List.filled(7, 0);

      final baseDay = DateTime(now.year, now.month, now.day);
      final startOfWeek = baseDay.subtract(Duration(days: baseDay.weekday - 1)); // Mon
      final end = startOfWeek.add(const Duration(days: 7));

      for (final r in rows) {
        final dt = _dt(r);
        if (dt == null) continue;
        if (!dt.isBefore(startOfWeek) && dt.isBefore(end)) {
          final idx = dt.weekday - 1;
          addToBucket(idx, r);
        }
      }
      return;
    }

    if (filter == "Monthly") {
      // fixed 30 bar (1..30)
      netBuckets = List.filled(30, 0);
      spendBuckets = List.filled(30, 0);

      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);

      for (final r in rows) {
        final dt = _dt(r);
        if (dt == null) continue;
        if (!dt.isBefore(start) && dt.isBefore(end)) {
          final day = dt.day;
          if (day >= 1 && day <= 30) {
            addToBucket(day - 1, r);
          }
        }
      }
      return;
    }

    // Year
    netBuckets = List.filled(12, 0);
    spendBuckets = List.filled(12, 0);

    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);

    for (final r in rows) {
      final dt = _dt(r);
      if (dt == null) continue;
      if (!dt.isBefore(start) && dt.isBefore(end)) {
        addToBucket(dt.month - 1, r);
      }
    }
  }

  // ===== Chart helpers =====
  double _absMax(List<double> arr) {
    double mx = 0;
    for (final v in arr) {
      if (v.abs() > mx) mx = v.abs();
    }
    return mx <= 0 ? 10 : mx * 1.2;
  }

  double _minYNet() {
    double mn = 0;
    for (final v in netBuckets) {
      if (v < mn) mn = v;
    }
    if (mn >= 0) return 0;
    return mn * 1.2;
  }

  double _maxYNet() => _absMax(netBuckets);
  double _maxYSpend() {
    double mx = 0;
    for (final v in spendBuckets) {
      if (v > mx) mx = v;
    }
    return mx <= 0 ? 10 : mx * 1.2;
  }

  double _chartWidth() {
    if (filter == "Daily") return 24 * 22;
    if (filter == "Weekly") return 7 * 44;
    if (filter == "Monthly") return 30 * 10;
    return 12 * 5;
  }

  List<BarChartGroupData> _groups(List<double> data) {
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i],
            width: 14,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  Widget _bottomTitle(double value, TitleMeta meta) {
    final i = value.toInt();

    if (filter == "Daily") {
      if (i % 2 != 0) return const SizedBox.shrink();
      return Text("${i}h", style: const TextStyle(fontSize: 10));
    }

    if (filter == "Weekly") {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      if (i < 0 || i > 6) return const SizedBox.shrink();
      return Text(days[i], style: const TextStyle(fontSize: 10));
    }

    if (filter == "Monthly") {
      if ((i + 1) % 5 != 0) return const SizedBox.shrink();
      return Text("${i + 1}", style: const TextStyle(fontSize: 10));
    }

    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    if (i < 0 || i > 11) return const SizedBox.shrink();
    return Text(months[i], style: const TextStyle(fontSize: 10));
  }

  Widget _chip(String name) {
    final active = filter == name;
    return InkWell(
      onTap: () => setState(() => filter = name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5338FF) : const Color(0xFFF2F3F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, int idx) {
    final active = tabIndex == idx;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => tabIndex = idx),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF5338FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard({required String title, required double value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x12000000)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF5338FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Text(
                  "Rp${value.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required List<double> data,
    required double maxY,
    double? minY,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x12000000)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: SizedBox(
                  width: _chartWidth(),
                  child: BarChart(
                    BarChartData(
                      minY: minY,
                      maxY: maxY,
                      barGroups: _groups(data),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (v, meta) =>
                                Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: _bottomTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Firestore error: ${snapshot.error}"));
            }

            final rows = (snapshot.data?.docs ?? []).map((d) => d.data()).toList();
            final totals = _totals(rows);

            _buildBuckets(rows);

            final isNet = tabIndex == 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Analysis",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _metricCard(
                              title: "Balance",
                              value: totals["balance"] ?? 0,
                              icon: Icons.account_balance_wallet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _metricCard(
                              title: "Spend",
                              value: totals["expense"] ?? 0,
                              icon: Icons.trending_down,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Filter (Daily/Weekly/Monthly/Year)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x12000000)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _chip("Daily"),
                            _chip("Weekly"),
                            _chip("Monthly"),
                            _chip("Year"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Tabs (Net / Spend)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x12000000)),
                          ],
                        ),
                        child: Row(
                          children: [
                            _tab("Balance (Net)", 0),
                            _tab("Spend", 1),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Chart
                      if (isNet)
                        _chartCard(
                          title: "Balance (Net = Income - Spend)",
                          data: netBuckets,
                          minY: _minYNet(),
                          maxY: _maxYNet(),
                        )
                      else
                        _chartCard(
                          title: "Spend (Expense Only)",
                          data: spendBuckets,
                          maxY: _maxYSpend(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}