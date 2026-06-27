import 'package:flutter/material.dart';

class QuickStatisticsCard extends StatelessWidget {
  final String highestCategory;
  final double highestExpense;
  final int transactionCount;
  final double budgetUsed;

  const QuickStatisticsCard({
    super.key,
    required this.highestCategory,
    required this.highestExpense,
    required this.transactionCount,
    required this.budgetUsed,
  });

  Widget buildTile(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  "Quick Statistics",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                buildTile(
                  Icons.restaurant,
                  "Highest Category",
                  highestCategory,
                  Colors.orange,
                ),

                const SizedBox(width: 10),

                buildTile(
                  Icons.currency_rupee,
                  "Largest Expense",
                  "₹${highestExpense.toStringAsFixed(0)}",
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                buildTile(
                  Icons.receipt_long,
                  "Transactions",
                  transactionCount.toString(),
                  Colors.blue,
                ),

                const SizedBox(width: 10),

                buildTile(
                  Icons.pie_chart,
                  "Budget Used",
                  "${budgetUsed.toStringAsFixed(0)}%",
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}