import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetin_app/screen/transaction/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgetin_app/screen/home/home.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() => isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      final d = doc.data();
      return {
        'id': doc.id,
        'type': d['type'],
        'amount': d['amount'],
        'category': d['category'],
        'note': d['note'],
        'date': d['date'],
        'icon': d['icon'], // ✅ AMBIL ICON
      };
    }).toList();

    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  Map<String, List<Map<String, dynamic>>> groupedByDate() {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (var t in transactions) {
      final key = t['date'] ?? '';
      map.putIfAbsent(key, () => []).add(t);
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var k in sortedKeys) k: map[k]!};
  }

  String fmt(int n) => NumberFormat('#,###', 'id').format(n);

  String fmtAmount(dynamic amt) {
    if (amt == null) return '0';
    if (amt is num) return NumberFormat('#,###', 'id').format(amt.round());
    final parsed = double.tryParse(amt.toString());
    if (parsed == null) return amt.toString();
    return NumberFormat('#,###', 'id').format(parsed.round());
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedByDate();

    return Scaffold(
      backgroundColor: const Color(0xFF392DD2),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Text(
                    'Transaction',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ================= SUMMARY =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Builder(
                builder: (_) {
                  double totalIncome = transactions
                      .where((e) => e['type'] == 'income')
                      .fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());

                  double totalSpending = transactions
                      .where((e) =>
                  e['type'] == 'spend' || e['type'] == 'spending')
                      .fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());

                  final balance = totalIncome - totalSpending;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NumberFormat('#,###', 'id')
                            .format(balance.round()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Spending : -${NumberFormat('#,###', 'id').format(totalSpending.round())}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Income : +${NumberFormat('#,###', 'id').format(totalIncome.round())}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // ================= BUTTONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryPage(type: 'spend'),
                          ),
                        );
                        if (result == true) await loadTransactions();
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text(
                        'Add Spending',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryPage(type: 'income'),
                          ),
                        );
                        if (result == true) await loadTransactions();
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text(
                        'Add Income',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDFF6E9),
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================= HISTORY =================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent History',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: isLoading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : grouped.isEmpty
                            ? const Center(
                          child:
                          Text('No transactions yet'),
                        )
                            : ListView(
                          children: grouped.entries.map((entry) {
                            final dateKey = entry.key;
                            final items = entry.value;

                            double dayTotal = items.fold(
                              0.0,
                                  (p, e) =>
                              p +
                                  (e['amount'] as num)
                                      .toDouble() *
                                      (e['type'] == 'income'
                                          ? 1
                                          : -1),
                            );

                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(DateTime.parse(
                                          dateKey)),
                                      style: const TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    trailing: Text(
                                      (dayTotal < 0 ? '-' : '+') +
                                          fmt(dayTotal
                                              .abs()
                                              .round()),
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        color: dayTotal < 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                                ...items.map((t) {
                                  /// 🔥 FIX ICON DI SINI
                                  IconData icon;
                                  if (t['icon'] != null) {
                                    icon = IconData(
                                      t['icon'],
                                      fontFamily:
                                      'MaterialIcons',
                                    );
                                  } else {
                                    icon = t['type'] ==
                                        'income'
                                        ? Icons.attach_money
                                        : Icons.shopping_cart;
                                  }

                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors
                                              .blue
                                              .shade50,
                                          child: Icon(icon,
                                              color:
                                              Colors.blue),
                                        ),
                                        title: Text(
                                            t['category'] ??
                                                ''),
                                        subtitle:
                                        Text(t['note'] ?? ''),
                                        trailing: Text(
                                          (t['type'] ==
                                              'income'
                                              ? '+'
                                              : '-') +
                                              fmtAmount(
                                                  t['amount']),
                                          style: TextStyle(
                                            color: t['type'] ==
                                                'income'
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
