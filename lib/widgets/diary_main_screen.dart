import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/widgets/diary_section.dart';
import 'package:local_ai_calorie_app/widgets/reusables/daily_totals.dart';
import 'package:local_ai_calorie_app/widgets/reusables/date_navigation_bar.dart';

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
            // 1. Date Selector Component
            DateNavBar(
              selectedDate: selectedDate,
              onDateChanged: onDateChanged,
            ),

            // 2. Totals Component
            DailyTotalsSummary(selectedDate: selectedDate),

            const Divider(height: 1),

            // 3. Sections
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