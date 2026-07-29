import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';
import 'package:local_ai_calorie_app/widgets/diary_add_food_calc.dart';
import 'package:local_ai_calorie_app/widgets/diary_add_food_list.dart';
class DiaryAddEntryModal extends StatefulWidget {
  final MealType mealType;
  final DateTime date;

  const DiaryAddEntryModal(this.mealType, this.date, {super.key});

  @override
  State<DiaryAddEntryModal> createState() => _DiaryAddEntryModalState();
}

class _DiaryAddEntryModalState extends State<DiaryAddEntryModal> {
  Food? selectedFood;
  DiaryEntry? pendingEntry;

  void _handleFoodSelected(Food food) {
    setState(() {
      selectedFood = food;
      pendingEntry = DiaryEntry.fromFood(
        food: food, 
        mealType: widget.mealType, 
        date: widget.date,
      );
    });
  }

  void _handleBackToList() {
    setState(() {
      selectedFood = null;
      pendingEntry = null;
    });
  }

  Future<void> _handleSaveEntry(DiaryEntry entryToSave) async {
    await DatabaseHelper.instance.insertEntry(entryToSave);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: (selectedFood == null || pendingEntry == null)
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6, // Keep height for food search list
                  child: DiaryAddFoodListModal(
                    onFoodSelected: _handleFoodSelected,
                  ),
                )
              : DiaryEditorModal(
                  mode: DiaryEditorMode.create,
                  diaryEntry: pendingEntry!,
                  onDelete: _handleBackToList,
                  onSave: _handleSaveEntry,
                ),
        ),
      ),
    );
  }
}