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
  String filter = "Weekly"; // default

  // -------- GET DATA --------
  Stream<QuerySnapshot> getTransactions() {
    return FirebaseFirestore.instance
        .collection("transactions")
        .orderBy("date")
        .snapshots();
  }

  // -------- TOTALS --------
  Map<String, dynamic> calculateTotals(List<QueryDocumentSnapshot> docs) {
    double income = 0, expense = 0;

    for (var d in docs) {
      double amount = double.tryParse(d["amount"].toString()) ?? 0;

      if (d["type"] == "income") income += amount;
      else expense += amount;
    }

    return {
      "income": income,
      "expense": expense,
      "balance": income - expense,
    };
  }

  // ---------- CHART DATA ----------
  List<double> weeklyIncome = List.filled(7, 0);
  List<double> weeklyExpense = List.filled(7, 0);

  List<double> monthlyIncome = List.filled(31, 0);
  List<double> monthlyExpense = List.filled(31, 0);

  List<double> dailyIncome = List.filled(24, 0);
  List<double> dailyExpense = List.filled(24, 0);

  List<double> yearlyIncome = List.filled(12, 0);
  List<double> yearlyExpense = List.filled(12, 0);

  void buildChart(List<QueryDocumentSnapshot> docs) {
    // Reset dulu
    dailyIncome = List.filled(24, 0);
    dailyExpense = List.filled(24, 0);

    weeklyIncome = List.filled(7, 0);
    weeklyExpense = List.filled(7, 0);

    monthlyIncome = List.filled(31, 0);
    monthlyExpense = List.filled(31, 0);

    yearlyIncome = List.filled(12, 0);
    yearlyExpense = List.filled(12, 0);

    DateTime now = DateTime.now();

    for (var d in docs) {
      DateTime dt = DateTime.parse(d["date"]);
      double amount = double.tryParse(d["amount"].toString()) ?? 0;
      bool isIncome = d["type"] == "income";

      // DAILY
      if (filter == "Daily") {
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          if (isIncome) dailyIncome[dt.hour] += amount;
          else dailyExpense[dt.hour] += amount;
        }
      }

      // WEEKLY
      else if (filter == "Weekly") {
        int i = dt.weekday % 7;
        if (isIncome) weeklyIncome[i] += amount;
        else weeklyExpense[i] += amount;
      }

      // MONTHLY
      else if (filter == "Monthly") {
        if (dt.year == now.year && dt.month == now.month) {
          int i = dt.day - 1;
          if (isIncome) monthlyIncome[i] += amount;
          else monthlyExpense[i] += amount;
        }
      }

      // YEAR
      else if (filter == "Year") {
        if (dt.year == now.year) {
          int i = dt.month - 1;
          if (isIncome) yearlyIncome[i] += amount;
          else yearlyExpense[i] += amount;
        }
      }
    }
  }

  // ------------------------ BAR GROUP BUILDER ------------------------
  List<BarChartGroupData> getBarGroups() {
    if (filter == "Daily") {
      return List.generate(24, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: dailyIncome[i], width: 6),
            BarChartRodData(toY: dailyExpense[i], width: 6),
          ],
        );
      });
    }

    if (filter == "Weekly") {
      return List.generate(7, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: weeklyIncome[i], width: 7),
            BarChartRodData(toY: weeklyExpense[i], width: 7),
          ],
        );
      });
    }

    if (filter == "Monthly") {
      return List.generate(31, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: monthlyIncome[i], width: 4),
            BarChartRodData(toY: monthlyExpense[i], width: 4),
          ],
        );
      });
    }

    return List.generate(12, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: yearlyIncome[i], width: 8),
          BarChartRodData(toY: yearlyExpense[i], width: 8),
        ],
      );
    });
  }

  // ------------------------ LABEL BUILDER ------------------------
  Widget buildBottomTitle(double value, TitleMeta meta) {
    if (filter == "Daily") {
      if (value % 3 != 0) return const SizedBox();
      return Text("${value.toInt()}h");
    }

    if (filter == "Weekly") {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      return Text(days[value.toInt()]);
    }

    if (filter == "Monthly") {
      if (value % 3 != 0) return const SizedBox();
      return Text("${value.toInt() + 1}");
    }

    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return Text(months[value.toInt()]);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: StreamBuilder(
        stream: getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          final totals = calculateTotals(docs);
          buildChart(docs); // update grafik setiap snapshot
          double calculateChartWidth() {
            if (filter == "Daily") return 24 * 30;   // 24 bar
            if (filter == "Weekly") return 7 * 40;   // 7 bar
            if (filter == "Monthly") return 31 * 25; // 31 bar
            return 12 * 40;                          // 12 months
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text("Analysis",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                const SizedBox(height: 20),

                // BALANCE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _totalCard("Total Balance", totals["balance"], Colors.green),
                    _totalCard("Total Expense", totals["expense"], Colors.red),
                  ],
                ),

                const SizedBox(height: 20),

                // FILTER BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _filterButton("Daily"),
                    _filterButton("Weekly"),
                    _filterButton("Monthly"),
                    _filterButton("Year"),
                  ],
                ),

                const SizedBox(height: 20),

                // ----------------- CHART -----------------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Income & Expenses",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 230,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: calculateChartWidth(),   // <- otomatis lebar sesuai jumlah data
                            child: BarChart(
                              BarChartData(
                                barGroups: getBarGroups(),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: buildBottomTitle,
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                // ------------------- (WIDGET LAIN JANGAN DIUBAH) -------------------
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summary("Income", totals["income"], Icons.arrow_upward),
                    _summary("Expense", totals["expense"], Icons.arrow_downward),
                  ],
                ),

                const SizedBox(height: 30),
                const Text("My Targets",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _targetCircle("Travel", 0.30, Colors.blue),
                    _targetCircle("Car", 0.50, Colors.blueAccent),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // ====================================================================================
  // ========================   WIDGETS DI BAWAH TIDAK DIUBAH   ==========================
  // ====================================================================================

  Widget _filterButton(String name) {
    bool active = filter == name;
    return GestureDetector(
      onTap: () => setState(() => filter = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          name,
          style: TextStyle(
              color: active ? Colors.white : Colors.black, fontSize: 14),
        ),
      ),
    );
  }

  Widget _totalCard(String title, double value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            "Rp${value.toStringAsFixed(0)}",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _summary(String name, double value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 4),
        Text(name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("Rp${value.toStringAsFixed(0)}",
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _targetCircle(String name, double percent, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 10,
                color: color,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text("${(percent * 100).toInt()}%",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class StatisticScreen extends StatefulWidget {
//   const StatisticScreen({super.key});
//
//   @override
//   State<StatisticScreen> createState() => _StatisticScreenState();
// }
//
// class _StatisticScreenState extends State<StatisticScreen> {
//   int selectedMonth = DateTime.now().month;
//   int selectedYear = DateTime.now().year;
//
//   bool isLoading = true;
//   List<Map<String, dynamic>> transactions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadTransactions();
//   }
//
//   Future<void> loadTransactions() async {
//     setState(() => isLoading = true);
//
//     // Ambil awal & akhir bulan
//     DateTime start = DateTime(selectedYear, selectedMonth, 1);
//     DateTime end = DateTime(selectedYear, selectedMonth + 1, 1);
//
//     final snapshot = await FirebaseFirestore.instance
//         .collection('transactions')
//         .where('timestamp', isGreaterThanOrEqualTo: start)
//         .where('timestamp', isLessThan: end)
//         .get();
//
//     transactions = snapshot.docs.map((doc) {
//       final d = doc.data();
//
//       return {
//         'id': doc.id,
//         'type': d['type'],
//         'amount': (d['amount'] as num).toDouble(),
//         'category': d['category'],
//         'note': d['note'] ?? '',
//         'date': (d['timestamp'] as Timestamp).toDate(),
//       };
//     }).toList();
//
//     setState(() => isLoading = false);
//   }
//
//   // --- SUMMARY TOTAL ---
//   double get totalIncome => transactions
//       .where((e) => e['type'] == 'income')
//       .fold(0.0, (p, e) => p + e['amount']);
//
//   double get totalSpending => transactions
//       .where((e) => e['type'] == 'spend')
//       .fold(0.0, (p, e) => p + e['amount']);
//
//   // --- GROUP KATEGORI SPENDING ---
//   Map<String, double> get spendingByCategory {
//     Map<String, double> result = {};
//
//     for (var t in transactions.where((e) => e['type'] == 'spend')) {
//       result[t['category']] =
//           (result[t['category']] ?? 0) + t['amount'];
//     }
//
//     return result;
//   }
//
//   // --- DATA BAR CHART ---
//   double weekSum(int weekIndex, String type) {
//     DateTime start = DateTime(selectedYear, selectedMonth, 1 + (weekIndex * 7));
//     DateTime end = start.add(const Duration(days: 7));
//
//     return transactions
//         .where((e) =>
//     e['type'] == type &&
//         (e['date'] as DateTime).isAfter(start) &&
//         (e['date'] as DateTime).isBefore(end))
//         .fold(0.0, (p, e) => p + e['amount']);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF392DD2),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // HEADER
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     "Statistics",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   const Spacer(),
//                 ],
//               ),
//             ),
//
//             // --- MONTH SELECTOR ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   DropdownButton<int>(
//                     value: selectedMonth,
//                     dropdownColor: Colors.white,
//                     items: List.generate(
//                       12,
//                           (i) => DropdownMenuItem(
//                         value: i + 1,
//                         child: Text(DateFormat('MMMM').format(DateTime(0, i + 1))),
//                       ),
//                     ),
//                     onChanged: (v) {
//                       selectedMonth = v!;
//                       loadTransactions();
//                     },
//                   ),
//                   const SizedBox(width: 10),
//                   DropdownButton<int>(
//                     value: selectedYear,
//                     dropdownColor: Colors.white,
//                     items: List.generate(
//                       5,
//                           (i) => DropdownMenuItem(
//                         value: 2023 + i,
//                         child: Text((2023 + i).toString()),
//                       ),
//                     ),
//                     onChanged: (v) {
//                       selectedYear = v!;
//                       loadTransactions();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(18),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius:
//                   BorderRadius.vertical(top: Radius.circular(35)),
//                 ),
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : buildContent(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildContent() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // --- SUMMARY CARD ---
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF392DD2),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 Text("Balance",
//                     style: const TextStyle(color: Colors.white70)),
//                 Text(
//                   NumberFormat('#,###', 'id')
//                       .format((totalIncome - totalSpending).round()),
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 28),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Column(
//                       children: [
//                         const Text("Income",
//                             style: TextStyle(color: Colors.white)),
//                         Text(
//                           "+${NumberFormat('#,###', 'id').format(totalIncome.round())}",
//                           style: const TextStyle(
//                               color: Colors.greenAccent, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const Text("Spending",
//                             style: TextStyle(color: Colors.white)),
//                         Text(
//                           "-${NumberFormat('#,###', 'id').format(totalSpending.round())}",
//                           style: const TextStyle(
//                               color: Colors.redAccent, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 25),
//
//           // =========================
//           //       PIE CHART
//           // =========================
//           if (spendingByCategory.isNotEmpty) ...[
//             const Text("Spending by Category",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 240,
//               child: PieChart(
//                 PieChartData(
//                   sections: spendingByCategory.entries.map((e) {
//                     return PieChartSectionData(
//                       value: e.value,
//                       title:
//                       "${((e.value / totalSpending) * 100).round()}%",
//                       radius: 55,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 25),
//           ],
//
//           // =========================
//           //      BAR CHART
//           // =========================
//           const Text("Weekly Summary",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//
//           SizedBox(
//             height: 220,
//             child: BarChart(
//               BarChartData(
//                 barGroups: List.generate(4, (i) {
//                   final incomeVal = weekSum(i, 'income');
//                   final spendVal = weekSum(i, 'spend');
//
//                   return BarChartGroupData(
//                     x: i,
//                     barRods: [
//                       BarChartRodData(toY: incomeVal, width: 12),
//                       BarChartRodData(toY: spendVal, width: 12),
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }
// }
