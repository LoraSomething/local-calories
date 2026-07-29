import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';

class DailyTotalsSummary extends StatefulWidget {
  final DateTime selectedDate;

  const DailyTotalsSummary({super.key, required this.selectedDate});

  @override
  State<DailyTotalsSummary> createState() => DailyTotalsSummaryState();
}

class DailyTotalsSummaryState extends State<DailyTotalsSummary> {
  // Public method so parent/sections can trigger a refresh when entries change
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: DatabaseHelper.instance.getEntriesForDate(widget.selectedDate),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];

        final totalCalories = entries.fold<int>(
          0, (sum, item) => sum + (item.calories?.toInt() ?? 0),
        );
        final totalProtein = entries.fold<double>(
          0.0, (sum, item) => sum + (item.protein ?? 0),
        );
        final totalSatFat = entries.fold<double>(
          0.0, (sum, item) => sum + (item.saturatedFat ?? 0),
        );
        final totalFiber = entries.fold<double>(
          0.0, (sum, item) => sum + (item.fiber ?? 0),
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Calories', totalCalories.toString(), isHighlight: true),
              _buildStat('Protein', totalProtein.toStringAsFixed(1)),
              _buildStat('Sat fat', totalSatFat.toStringAsFixed(1)),
              _buildStat('Fiber', totalFiber.toStringAsFixed(1)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 86, 86, 86)),
        ),
      ],
    );
  }
}