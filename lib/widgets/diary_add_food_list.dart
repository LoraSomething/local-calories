import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';

class DiaryAddFoodListModal extends StatefulWidget {
  final ValueChanged<Food> onFoodSelected;

  const DiaryAddFoodListModal({
    required this.onFoodSelected,
  });

  @override
  State<DiaryAddFoodListModal> createState() => _DiaryAddFoodListModalState();
}

class _DiaryAddFoodListModalState extends State<DiaryAddFoodListModal> {

  late Future<List<Food>> foods;

  @override
  void initState() {
    super.initState();
    foods = DatabaseHelper.instance.getFoods();
  }

  @override
  Widget build(BuildContext context) {

    return 
      Column(
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: OutlinedButton.icon(
                onPressed: (){},
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New food", maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis,),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ),
            SizedBox(width: 20,),
            IconButton(
              onPressed: (){ Navigator.of(context).pop();},
              icon: const Icon(Icons.close, size: 18),
              
            ),
          ]
        ),
        Expanded(child: 
          FutureBuilder<List<Food>>(
            future: foods,
            builder: (context, snapshot) { 
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); 
              }

              if (snapshot.hasError) {
                debugPrint("SnapshotError: ${snapshot.error.toString()}");
                return Text('Error loading data. Error ${snapshot.error.toString()}');
              }

              final foods = snapshot.data!;
              
                return ListView.separated(
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
                      onTap: () {widget.onFoodSelected(food);},
                    );
                  },
                );
              },
          )
        )
      ],
    );
  }
}