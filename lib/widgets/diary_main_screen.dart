// diary_screen.dart
import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/widgets/diary_section.dart';

import '../services/database_service.dart';

class DiaryMainScreen extends StatefulWidget {
  const DiaryMainScreen({super.key});

  @override
  State<DiaryMainScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryMainScreen> {
  DateTime selectedDate = DateTime.now();
  late Future<List<DiaryEntry>> entries;

  @override
  void initState() {
    super.initState();
    entries = DatabaseHelper.instance.getEntriesForDate(DateTime.now());
  }

  Future<List<DiaryEntry>> getEntries() async {    
    return DatabaseHelper.instance.getEntriesForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      body: SafeArea(
        child: 
          Column(
            children: [
              // 1. Date Navigation Bar
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          selectedDate = selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                    ),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          selectedDate = selectedDate.add(const Duration(days: 1));
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
              child: ListView(
                children: [
                  DiarySection(
                    title: 'Breakfast',
                    mealType: MealType.breakfast,
                    selectedDate: selectedDate, // <-- Passed here
                    onAddPressed: () {},
                  ),
                  DiarySection(
                    title: 'Lunch',
                    mealType: MealType.lunch,
                    selectedDate: selectedDate,
                    onAddPressed: () {},
                  ),
                  DiarySection(
                    title: 'Dinner',
                    mealType: MealType.dinner,
                    selectedDate: selectedDate,
                    onAddPressed: () {},
                  ),
                  DiarySection(
                    title: 'Snacks',
                    mealType: MealType.snack,
                    selectedDate: selectedDate,
                    onAddPressed: () {},
                  ),
                ],
              ),
            ),
            ],
          ),
        ) 
    );
  }

  Widget _buildSummaryStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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