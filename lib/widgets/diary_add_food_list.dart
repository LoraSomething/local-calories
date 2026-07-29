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

  late Future<List<Food>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _foodsFuture = DatabaseHelper.instance.getFoods();
  }

  List<Food>? _masterList;
  List<Food> _displayedList = [];
  bool _isInitialized = false;

  void _runFilter(String query) {
    if (_masterList == null) return;

    setState(() {
      if (query.isEmpty) {
        _displayedList = List.from(_masterList!);
      } else {
        _displayedList = _masterList!
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _runFilter,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: FutureBuilder<List<Food>>(
            // 3. Pass the cached state Future, NOT a direct function call
            future: _foodsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading data: ${snapshot.error}'),
                );
              }

              // Initialize master & search arrays on first data arrival
              if (!_isInitialized && snapshot.hasData) {
                _masterList = snapshot.data!;
                _displayedList = List.from(_masterList!);
                _isInitialized = true;
              }

              if (_displayedList.isEmpty) {
                return const Center(child: Text('No food items found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _displayedList.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final food = _displayedList[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      food.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      'P: ${food.protein}g  C: ${food.carbs}g  F: ${food.fat}g',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: Text(
                      '${food.calories} kcal',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onTap: () => widget.onFoodSelected(food),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}