import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/widgets/diary_main_screen.dart';

class DiaryScreenContainer extends StatefulWidget {
  const DiaryScreenContainer({super.key});

  @override
  State<DiaryScreenContainer> createState() => _DiaryScreenContainerState();
}

class _DiaryScreenContainerState extends State<DiaryScreenContainer> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DiaryMainScreen(
      selectedDate: _selectedDate,
      onDateChanged: (newDate) {
        setState(() {
          _selectedDate = newDate;
        });
      },
      onEntryChanged: () {
        // Rebuilds screen to recalculate totals when entries change
        setState(() {});
      },
    );
  }
}