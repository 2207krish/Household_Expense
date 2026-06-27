import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String month;

  const DashboardHeader({super.key, required this.month});

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning ☀️";
    if (hour < 17) return "Good Afternoon 🌤";
    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xff6C63FF), Color(0xff4D8DFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getGreeting(),
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),

          const SizedBox(height: 8),

          const Text(
            "Household Expense Tracker",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            month,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 6),

          const Text(
            "Track every rupee. Save every month.",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
