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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    foods = DatabaseHelper.instance.getFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> onFoodSelected(BuildContext context, Food food) async {
    Food? updatedFood = await showDialog<Food>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => FoodModal(foodToEdit: food),
    );
    if (updatedFood != null) {
      await DatabaseHelper.instance.updateFood(updatedFood);
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
    if (newFood != null) {
      await DatabaseHelper.instance.insertFood(newFood);
      setState(() {
        foods = DatabaseHelper.instance.getFoods();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Component
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search food...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            // Food List View
            Expanded(
              child: FutureBuilder<List<Food>>(
                future: foods,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    debugPrint("SnapshotError: ${snapshot.error.toString()}");
                    return Text('Error loading data. Error ${snapshot.error.toString()}');
                  }

                  final allFoods = snapshot.data!;

                  // Filter foods locally based on the search query
                  final filteredFoods = allFoods.where((food) {
                    return food.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredFoods.isEmpty) {
                    return const Center(
                      child: Text('No food found matching your search.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredFoods.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];

                      return Dismissible(
                        key: Key(food.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Food'),
                                content: Text('Are you sure you want to delete "${food.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          await DatabaseHelper.instance.deleteFood(food);
                          setState(() {
                            foods = DatabaseHelper.instance.getFoods();
                          });
                        },
                        child: ListTile(
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
                            onFoodSelected(context, food);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FoodAddButton(
        onFoodAdded: () {
          setState(() {
            foods = DatabaseHelper.instance.getFoods();
          });
        },
      ),
    );
  }
}