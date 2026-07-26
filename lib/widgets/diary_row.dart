// meal_entry_tile.dart
import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';

class DiaryRow extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.foodName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.protein} • P: ${entry.protein!.toStringAsFixed(1)}g  C: ${entry.carbs!.toStringAsFixed(1)}g  F: ${entry.fat!.toStringAsFixed(1)}g',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.calories} kcal',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}