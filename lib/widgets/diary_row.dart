// meal_entry_tile.dart
import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';
import 'package:local_ai_calorie_app/widgets/diary_add_food_calc.dart';

class DiaryRow extends StatelessWidget {
  final DiaryEntry entry;
  final ValueChanged<DiaryEntry> onTap;
  final ValueChanged<DiaryEntry> onLongPress;

  const DiaryRow({super.key, required this.entry, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return 
    InkWell(
      onLongPress: () { onLongPress(entry); },
      onTap: () async {
        await showDialog(
        context: context,
        builder: (context) => Dialog(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: DiaryEditorModal(
              diaryEntry: entry,
              mode: DiaryEditorMode.edit,
              onSave: (updatedEntry) async {
                await DatabaseHelper.instance.updateEntry(updatedEntry);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      );
      },
      child: 
        Container(
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
                    'P: ${entry.protein!.toStringAsFixed(1)}g  C: ${entry.carbs!.toStringAsFixed(1)}g  F: ${entry.fat!.toStringAsFixed(1)}g',
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
      )
    );
  }
}