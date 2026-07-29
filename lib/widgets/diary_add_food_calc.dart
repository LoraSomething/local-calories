import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';

enum DiaryEditorMode { create, edit }

class DiaryEditorModal extends StatefulWidget {
  final DiaryEntry diaryEntry;
  final DiaryEditorMode mode;
  final ValueChanged<DiaryEntry> onSave;
  final VoidCallback? onDelete;

  const DiaryEditorModal({
    super.key,
    required this.diaryEntry,
    required this.mode,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<DiaryEditorModal> createState() => _DiaryEditorModalState();
}

class _DiaryEditorModalState extends State<DiaryEditorModal> {
  late final TextEditingController _caloriesController;
  late final TextEditingController _gramsController;
  late DiaryEntry _workingEntry;

  @override
  void initState() {
    super.initState();
    // Clone or reference the entry so edits don't mutate state prematurely
    _workingEntry = widget.diaryEntry;
    _caloriesController = TextEditingController(text: _workingEntry.calories.toString());
    _gramsController = TextEditingController(text: _workingEntry.grams.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  void _updateGrams(double grams) {
    setState(() {
      _workingEntry.grams = grams;
      _workingEntry.calculateAllValuesFromGrams();
      _caloriesController.text = _workingEntry.calories.toString();
    });
  }

  @override
Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min, // Hugs the content vertically
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Entry',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // Food Title
      Text(
        widget.diaryEntry.foodName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 16),

      // Input Fields
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _caloriesController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Calories',
                suffixText: 'kcal',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Serving',
                suffixText: 'g',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value) ?? 0.0;
                _updateGrams(parsed);
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Macro Display Box
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMacroTile("Carbs", widget.diaryEntry.carbs)),
                Expanded(child: _buildMacroTile("Sugar", widget.diaryEntry.sugars)),
                Expanded(child: _buildMacroTile("Fiber", widget.diaryEntry.fiber)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMacroTile("Fat", widget.diaryEntry.fat)),
                Expanded(child: _buildMacroTile("Sat. Fat", widget.diaryEntry.saturatedFat)),
                Expanded(child: _buildMacroTile("Protein", widget.diaryEntry.protein)),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Action Button
      FilledButton.icon(
        onPressed: () {
          widget.onSave(widget.diaryEntry);
        },
        icon: const Icon(Icons.add, size: 18),
        label: Text('Add to ${widget.diaryEntry.mealType.name}'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ],
  );
}

  Widget _buildMacroTile(String label, dynamic value) {
    final formattedValue = value is double ? value.toStringAsFixed(1) : value.toString();
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
        const SizedBox(height: 2),
        Text('${formattedValue}g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}