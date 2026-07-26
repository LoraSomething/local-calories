import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';

class DiaryAddFoodCalcModal extends StatefulWidget {
  final Food food;
  final MealType mealType;
  final VoidCallback onFoodRemoved;
  final ValueChanged<DiaryEntry> onFoodAddedToDiary;

  @override
  State<DiaryAddFoodCalcModal> createState() => _DiaryAddFoodCalcModalState();

  const DiaryAddFoodCalcModal(
    {super.key, 
    required this.food, 
    required this.onFoodRemoved, 
    required this.onFoodAddedToDiary, 
    required this.mealType});

}

class _DiaryAddFoodCalcModalState extends State<DiaryAddFoodCalcModal> {

  late final TextEditingController _caloriesController;
  late final TextEditingController _gramsController;
  late DiaryEntry diaryEntry;  
  bool settingGrams = true;

  @override
  void initState(){

    diaryEntry = 
        DiaryEntry(id: -1, 
        date: DateTime.now(), 
        mealType: widget.mealType, 
        foodName: widget.food.name,
        foodId: widget.food.id,
        calories: widget.food.calories,
        grams: widget.food.grams,
        carbs: widget.food.carbs,
        sugars: widget.food.sugars,
        fiber: widget.food.fiber,
        fat: widget.food.fat,
        saturatedFat: widget.food.saturatedFat,
        protein: widget.food.protein,
        foodCalories: widget.food.calories,
        foodGrams: widget.food.grams,
        foodCarbs: widget.food.carbs,
        foodSugars: widget.food.sugars,
        foodFiber: widget.food.fiber,
        foodFat: widget.food.fat,
        foodSaturatedFat: widget.food.saturatedFat,
        foodProtein: widget.food.protein);

    _caloriesController = TextEditingController(text: diaryEntry.calories.toString());
    _gramsController = TextEditingController(text: diaryEntry.grams.toString());

    super.initState();
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void setGrams(double grams) {
    settingGrams = true;
    setState(() {
      if (settingGrams){
        diaryEntry.grams = grams;
        diaryEntry.calculateAllValuesFromGrams();
        _caloriesController.text = diaryEntry.calories.toString();
      }
    });
  }
  
  void setCalories(double kcal) {

  }

  void addToDiary(){
    DatabaseHelper.instance.insertEntry(diaryEntry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return 

    Column(
      children: [
          Row(
          children: [
            Expanded(child: OutlinedButton.icon(
                onPressed: widget.onFoodRemoved,
                icon: const Icon(Icons.camera, size: 18),
                label: const Text('AI parse'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: OutlinedButton.icon(
                onPressed: widget.onFoodRemoved,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('back'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            )
          ],
        ),
        Text(widget.food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight(600), color: Colors.black),),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                enabled: false,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'kcal',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value) ?? 0.0;
                  setCalories(parsed);
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextFormField(
                controller: _gramsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'g',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value) ?? 0.0;
                  setGrams(parsed);
                },
              ),
            ),
          ],
        ),

        Column(
          children: [
            // Row 1
            Row(
              children: [
                Expanded(child: _buildMacroTile("Carbs", diaryEntry.carbs)),
                Expanded(child: _buildMacroTile("Sugar", diaryEntry.sugars)),
                Expanded(child: _buildMacroTile("Fiber", diaryEntry.fiber)),
              ],
            ),
            const SizedBox(height: 12),
            // Row 2
            Row(
              children: [
                Expanded(child: _buildMacroTile("Fat", diaryEntry.fat)),
                Expanded(child: _buildMacroTile("Sat. Fat", diaryEntry.saturatedFat)),
                Expanded(child: _buildMacroTile("Protein", diaryEntry.protein)),
              ],
            ),
          ],
        ),
        Spacer(),
        FilledButton.icon(
          onPressed: (){widget.onFoodAddedToDiary(diaryEntry);},
          icon: const Icon(Icons.save, size: 18),
          label: Text('add to ${widget.mealType.name}'),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroTile(String label, dynamic value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$label:",
          style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

}