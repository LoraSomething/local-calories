import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';
import 'package:local_ai_calorie_app/widgets/diary_meal_section.dart';
import 'package:local_ai_calorie_app/widgets/diary_report.dart';

class DiaryMainScreen extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onEntryChanged;

  const DiaryMainScreen({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onEntryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            DateNavBar(
              selectedDate: selectedDate,
              onDateChanged: onDateChanged,
            ),

            DailyTotalsSummary(selectedDate: selectedDate),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                children: [
                  DiarySection(
                    title: 'Breakfast',
                    mealType: MealType.breakfast,
                    selectedDate: selectedDate,
                    onAddPressed: onEntryChanged,
                  ),
                  DiarySection(
                    title: 'Lunch',
                    mealType: MealType.lunch,
                    selectedDate: selectedDate,
                    onAddPressed: onEntryChanged,
                  ),
                  DiarySection(
                    title: 'Dinner',
                    mealType: MealType.dinner,
                    selectedDate: selectedDate,
                    onAddPressed: onEntryChanged,
                  ),
                  DiarySection(
                    title: 'Snacks',
                    mealType: MealType.snack,
                    selectedDate: selectedDate,
                    onAddPressed: onEntryChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DailyTotalsSummary extends StatefulWidget {
  final DateTime selectedDate;

  const DailyTotalsSummary({super.key, required this.selectedDate});

  @override
  State<DailyTotalsSummary> createState() => DailyTotalsSummaryState();
}

class DailyTotalsSummaryState extends State<DailyTotalsSummary> {
  // Public method so parent/sections can trigger a refresh when entries change
  void refresh() {
    setState(() {
      //_entriesFuture = DatabaseHelper.instance.getEntriesForDate(widget.selectedDate);
    });
  }

  //late Future<List<DiaryEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    //_entriesFuture = DatabaseHelper.instance.getEntriesForDate(widget.selectedDate);
  }

  void showSummaruDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => DailyReport(selectedDate: widget.selectedDate),
    );
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

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            onTap: () {
                showSummaruDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Calories', totalCalories.toString(), isHighlight: true),
                  _buildStat('Protein', totalProtein.toStringAsFixed(1)),
                  _buildStat('Sat fat', totalSatFat.toStringAsFixed(1)),
                  _buildStat('Fiber', totalFiber.toStringAsFixed(1)),
                ],
              ),
            ),
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



class DateNavBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateNavBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      // Reduced top/bottom padding from 8 to 2
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            // Tightens button padding & touch bounds
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), 
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => onDateChanged(selectedDate.subtract(const Duration(days: 1))),
          ),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => onDateChanged(selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}