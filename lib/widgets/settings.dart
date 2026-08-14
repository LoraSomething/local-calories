import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Macro goals')),
      body: ListView(
        children: [
          MacroGoalTile(
            settingKey: 'caloriesMin',
            title: 'Calories Min',
            unit: 'kcal',
          ),
          MacroGoalTile(
            settingKey: 'caloriesMax',
            title: 'Calories Max',
            unit: 'kcal',
          ),
          MacroGoalTile(
            settingKey: 'proteinMin',
            title: 'Protein Min',
            unit: 'g',
          ),
          MacroGoalTile(
            settingKey: 'proteinMax',
            title: 'Protein Max',
            unit: 'g',
          ),
          MacroGoalTile(
            settingKey: 'fiberMin',
            title: 'Fiber Min',
            unit: 'g',
          ),
          MacroGoalTile(
            settingKey: 'fiberMax',
            title: 'Fiber Max',
            unit: 'g',
          ),
          MacroGoalTile(
            settingKey: 'saturatedfatMin',
            title: 'Sat. Fat Min',
            unit: 'g',
          ),
          MacroGoalTile(
            settingKey: 'saturatedfatMax',
            title: 'Sat. Fat Max',
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class MacroGoalTile extends StatefulWidget {
  final String settingKey;
  final String title;
  final String unit;

  const MacroGoalTile({
    super.key,
    required this.settingKey,
    required this.title,
    required this.unit,
  });

  @override
  State<MacroGoalTile> createState() => _MacroGoalTileState();
}

class _MacroGoalTileState extends State<MacroGoalTile> {
  late TextEditingController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final savedValue = await DatabaseHelper.instance.getSetting(widget.settingKey);
    final valueToSet = savedValue ?? null;

    if (mounted) {
      setState(() {
        _controller.text = valueToSet == null ? "" : valueToSet.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateValue(String input) async {
    final parsed = int.tryParse(input);
    if (parsed != null) {
      // Async write to SQLite in the background
      await DatabaseHelper.instance.updateSetting(widget.settingKey, parsed);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListTile(
        title: Text(widget.title),
        trailing: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      title: Text(widget.title),
      trailing: SizedBox(
        width: 150,
        height: 50,
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: widget.unit, border: OutlineInputBorder()),
          onChanged: _updateValue, // Auto-saves to SQLite as user edits
        ),
      ),
    );
  }
}