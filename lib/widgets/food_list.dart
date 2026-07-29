import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:local_ai_calorie_app/widgets/food_list_add.dart';
import 'package:local_ai_calorie_app/widgets/food_modal.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';

class FoodList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => FoddListState();
}

class FoddListState extends State<FoodList> {
  late Future<List<Food>> foods;

  @override
  void initState() {
    super.initState();
    foods = DatabaseHelper.instance.getFoods();
  }

  Future<void> onFoodSelected(BuildContext context, Food food) async {
    Food? updatedFood = await showDialog<Food>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => FoodModal(foodToEdit: food),
    );
    if (updatedFood != null)
    {
      await DatabaseHelper.instance.updateFood(updatedFood);
      //debugPrint("updated food name ${updatedFood.name} and grams ${updatedFood.grams}");
      setState(() {
          foods = DatabaseHelper.instance.getFoods();
      });
    } 
      
  }

  Future<void> foodAdd(BuildContext context) async {
    Food? newFood = await showDialog<Food>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => FoodModal(),
    );
    if (newFood != null){
      await DatabaseHelper.instance.insertFood(newFood);
      setState(() {
        foods = DatabaseHelper.instance.getFoods();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: 
        FutureBuilder<List<Food>>(
        future: foods, // 1. The order placed (takes time)
        builder: (context, snapshot) {    // 2. The waiter reporting back
          
          // State 1: Still cooking...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); 
          }

          // State 2: Dropped the plate...
          if (snapshot.hasError) {
            debugPrint("SnapshotError: ${snapshot.error.toString()}");
            return Text('Error loading data. Error ${snapshot.error.toString()}');
          }

          // State 3: Food is served!
          final foods = snapshot.data!;
          return 
            ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: foods.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final food = foods[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    'P: ${food.protein}g  C: ${food.carbs}g  F: ${food.fat}g',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: Text(
                    '${food.calories} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    if (onFoodSelected != null) {
                      onFoodSelected!(context,food);
                    }
                  },
                );
              },
            );
          },
        ) 
      ),
      floatingActionButton: 
        FoodAddButton(onFoodAdded: () {
          setState(() {
            foods = DatabaseHelper.instance.getFoods();
          });
        },)
    );
  }
}