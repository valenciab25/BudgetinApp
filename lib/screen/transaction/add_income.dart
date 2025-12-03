import 'package:flutter/material.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF392DD2),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white)),
                  const SizedBox(width: 15),
                  const Text("Add Income",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    CategoryTile("Salary", Icons.payments),
                    CategoryTile("Donation", Icons.volunteer_activism),
                    CategoryTile("Saving", Icons.savings),
                    CategoryTile("Dividen", Icons.show_chart),
                    CategoryTile("Refund", Icons.reply),
                    CategoryTile("Sales", Icons.sell),
                    CategoryTile("Bonus", Icons.workspace_premium),
                    CategoryTile("Voucher", Icons.card_giftcard),
                    CategoryTile("Other", Icons.more_horiz),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const CategoryTile(this.title, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue)),
      title: Text(title),
    );
  }
}
