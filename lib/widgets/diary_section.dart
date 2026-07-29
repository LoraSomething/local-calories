import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';
import 'package:local_ai_calorie_app/widgets/diary_add_modal.dart';

import '../model/diary_entry.dart';
import 'diary_row.dart';

class DiarySection extends StatefulWidget {
  final String title;
  final MealType mealType;
  final DateTime selectedDate;
  final VoidCallback onAddPressed;

  const DiarySection({
    super.key,
    required this.title,
    required this.mealType,
    required this.selectedDate,
    required this.onAddPressed,
  });

  @override
  State<DiarySection> createState() => _DiarySectionState();
}

class _DiarySectionState extends State<DiarySection> {

  late Future<List<DiaryEntry>> entriesFuture;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  @override
  void didUpdateWidget(covariant DiarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      loadEntries();
    }
  }

  void loadEntries() {
    entriesFuture = DatabaseHelper.instance.getEntriesByMealAndDate(widget.selectedDate, widget.mealType);
  }

  void refresh() {
    setState(() {
      loadEntries();
    });
  }

  void addFood() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => DiaryAddEntryModal(widget.mealType, widget.selectedDate),
    );
    refresh();
    widget.onAddPressed();
  }
  
  void addFoodFromText() {

  }

  void onRowTapped(DiaryEntry entry) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => DiaryAddEntryModal(widget.mealType, widget.selectedDate),
    );
    refresh();
    widget.onAddPressed();
  }
  
  void onRowLongPress(DiaryEntry entry) async {
    final shouldDelete = await showDeleteDialog(context, entry.foodName);

    // 2. Check if the user clicked "Yes"
    if (shouldDelete) {
      DatabaseHelper.instance.deleteEntry(entry);
      setState(() {
        refresh();
      });
      widget.onAddPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.mealType.color;
    final cardBgColor = widget.mealType.lightBackgroundColor;

    return FutureBuilder<List<DiaryEntry>>(
      future: entriesFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final entries = snapshot.data ?? [];
        if (hasError) debugPrint("Error loading entries: ${snapshot.error.toString()}");

        // Calculate total calories (0 while loading/error)
        final int sectionCalories = entries.fold(
          0, (sum, item) => sum + (item.calories?.toInt() ?? 0),
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          elevation: 1,
          color: cardBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accentColor, width: 1),
          ),
          child: Column(
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    // Shows spinner while loading, then switches to calorie count
                    if (isLoading)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentColor,
                        ),
                      )
                    else
                      Text(
                        '$sectionCalories kcal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: accentColor),

              // Item List / Loading / Error / Empty Placeholder
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (hasError)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading ${widget.title}',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                )
              else if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No food logged for ${widget.title}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                )
              else
                ...entries.map((entry) => 
                DiaryRow(
                  entry: entry,
                  onTap: (value){onRowTapped(value);},
                  onLongPress: (value){onRowLongPress(value);},
                  )),

              Divider(height: 1, color: accentColor),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: addFood,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('from foods'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: addFoodFromText,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('from text'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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