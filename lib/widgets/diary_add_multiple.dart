import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/food.dart';

class DiaryAddMultiple extends StatelessWidget {
  final List<(List<Food>, double)> foodsIdentified;
  final List<Food> selectedFoods;
  final List<TextEditingController> controllers;

  const DiaryAddMultiple({
    super.key,
    required this.foodsIdentified,
    required this.selectedFoods,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: foodsIdentified.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          return DiaryAddMultipleRow(
            foods: foodsIdentified[index].$1,
            currentFood: selectedFoods[index],
            gramsController: controllers[index],
            onFoodChanged: (newFood) {
              selectedFoods[index] = newFood;
            },
          );
        },
      ),
    );
  }
}

class DiaryAddMultipleRow extends StatefulWidget {
  final List<Food> foods;
  final TextEditingController gramsController;
  final Function(Food) onFoodChanged;
  final Food currentFood;

  const DiaryAddMultipleRow({
    super.key,
    required this.foods,
    required this.gramsController,
    required this.currentFood,
    required this.onFoodChanged,
  });

  @override
  State<DiaryAddMultipleRow> createState() => _DiaryAddMultipleRowState();
}

class _DiaryAddMultipleRowState extends State<DiaryAddMultipleRow> {
  
  late Food selectedFood;

  @override
  void initState() {
    super.initState();
    selectedFood = widget.foods.first;
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Food>(
                isExpanded: true,
                value: widget.currentFood,
                items: widget.foods.map((Food option) {
                  return DropdownMenuItem<Food>(
                    value: option,
                    child: Text(
                      option.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (Food? newValue) {
                  if (newValue != null) {
                    setState(() => widget.onFoodChanged(newValue));
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 12),
          
          SizedBox(
            width: 85,
            child: TextField(
              controller: widget.gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                suffixText: 'g',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}