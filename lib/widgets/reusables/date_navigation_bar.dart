import 'package:flutter/material.dart';

class DateNavBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateNavBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      // Reduced top/bottom padding from 8 to 2
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            // Tightens button padding & touch bounds
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), 
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => onDateChanged(selectedDate.subtract(const Duration(days: 1))),
          ),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => onDateChanged(selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}