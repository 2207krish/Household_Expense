import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String subtitle;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(icon, color: Colors.white),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
