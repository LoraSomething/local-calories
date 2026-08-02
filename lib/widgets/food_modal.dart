import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/food.dart';

class FoodModal extends StatefulWidget {
  final Food? foodToEdit;

  const FoodModal({super.key, this.foodToEdit});

  @override
  State<FoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<FoodModal> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _gramsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _sugarsController;
  late final TextEditingController _fiberController;
  late final TextEditingController _fatController;
  late final TextEditingController _saturatedFatController;
  late final TextEditingController _proteinController;

  // Helper getter to check if we are editing
  bool get isEditing => widget.foodToEdit != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers if editing, otherwise leave empty/default
    final food = widget.foodToEdit;
    _nameController = TextEditingController(text: food?.name ?? '');
    _caloriesController = TextEditingController(text: food != null ? food.calories.toString() : '');
    _gramsController = TextEditingController(text: food != null ? food.grams.toString() : '');
    _carbsController = TextEditingController(text: food != null ? food.carbs.toString() : '');
    _sugarsController = TextEditingController(text: food != null ? food.sugars.toString() : '');
    _fiberController = TextEditingController(text: food != null ? food.fiber.toString() : '');
    _fatController = TextEditingController(text: food != null ? food.fat.toString() : '');
    _saturatedFatController = TextEditingController(text: food != null ? food.saturatedFat.toString() : '');
    _proteinController = TextEditingController(text: food != null ? food.protein.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _sugarsController.dispose();
    _fiberController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Build updated or new Food object
      final updatedFood = Food(
        id: widget.foodToEdit != null ? widget.foodToEdit!.id : -1,
        name: _nameController.text.trim(),
        grams: double.tryParse(_gramsController.text) ?? 0,
        calories: double.tryParse(_caloriesController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0.0,
        sugars: double.tryParse(_sugarsController.text) ?? 0.0,
        fiber: double.tryParse(_fiberController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        saturatedFat: double.tryParse(_saturatedFatController.text) ?? 0.0,
        protein: double.tryParse(_proteinController.text) ?? 0.0,
      );

      Navigator.of(context).pop(updatedFood);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Food' : 'Add Food',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),

                // Calories & Grams
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories (kcal)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _gramsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Grams',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Carbs, Sugars, Fiber
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Carbs',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _sugarsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Sugars',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _fiberController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Fiber',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Fat, Sat Fat, Protein
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Fat',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _saturatedFatController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Sat. Fat',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Protein',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Button
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Add Food'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> showDeleteDialog(BuildContext context, String foodName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Food'),
          content: Text('Are you sure you want to delete $foodName?'),
          actions: [
            // "No" / Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Close dialog & return false
              },
              child: const Text('No'),
            ),
            
            // "Yes" / Delete Button
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Make delete action red
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Close dialog & return true
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}