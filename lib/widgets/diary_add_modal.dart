import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';
import 'package:local_ai_calorie_app/widgets/diary_add_food_calc.dart';
import 'package:local_ai_calorie_app/widgets/diary_add_food_list.dart';

class DiaryAddEntryModal extends StatefulWidget {
  final MealType mealType;

  @override
  State<DiaryAddEntryModal> createState() => _DiaryAddEntryModalState();

  const DiaryAddEntryModal(this.mealType, {super.key});
}

class _DiaryAddEntryModalState extends State<DiaryAddEntryModal> {
  Food? selectedFood;

  @override
  Widget build(BuildContext context) {

    final double screenHeight = MediaQuery.of(context).size.height * 0.5;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Padding(
          padding: EdgeInsetsGeometry.all(6),
          child: 
            (selectedFood == null) ? 
            DiaryAddFoodListModal(onFoodSelected: (Food f){
              setState(() {
                selectedFood = f;
              });
            },) 
            : DiaryAddFoodCalcModal(food: selectedFood!, mealType: widget.mealType,
              onFoodRemoved: (){
                setState(() {
                  selectedFood = null;
                });
              },
              onFoodAddedToDiary: (DiaryEntry de){
                setState(() {
                  selectedFood = null;
                  DatabaseHelper.instance.insertEntry(de);
                  Navigator.of(context).pop();
                });
              }
            )
        ),
      ),
    );
  }

}