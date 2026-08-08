import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/model/diary_entry.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';



class DailyReport extends StatefulWidget {
  final DateTime selectedDate;

  final MaterialColor carbsColor = Colors.blue;
  final MaterialColor sugarColor = Colors.indigo;
  final MaterialColor fiberColor = Colors.deepPurple;
  final MaterialColor fatColor = Colors.amber;
  final MaterialColor saturatedFatColor = Colors.deepOrange;
  final MaterialColor proteinColor = Colors.green;

  const DailyReport({super.key, required this.selectedDate});

  @override
  State<DailyReport> createState() => DailyReportState();
}

class DailyReportState extends State<DailyReport> {

  late final Future<List<DiaryEntry>> futureEntries;
  String selectedMacro = "Calories";

  @override
  void initState() {
    super.initState();
    futureEntries = DatabaseHelper.instance.getEntriesForDate(widget.selectedDate);
  }

  void changeMacroSelection(String macroLabel) {
    setState(() {
      selectedMacro = macroLabel;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiaryEntry>>(
      future: futureEntries,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        //label/key, (total, entries(name, value)), unit)
        Map<String, ({double total, List<({String foodName, double? value})> entries, String unit})> entries = {
          "Calories": (
            total: data.fold<double>(0, (sum, item) => sum + (item.calories ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.calories)).toList(),
            unit: "kcal",
          ),
          "Carbs": (
            total: data.fold<double>(0, (sum, item) => sum + (item.carbs ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.carbs)).toList(),
            unit: "g",
          ),
          "Sugars": (
            total: data.fold<double>(0, (sum, item) => sum + (item.sugars ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.sugars)).toList(),
            unit: "g",
          ),
          "Fiber": (
            total: data.fold<double>(0, (sum, item) => sum + (item.fiber ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.fiber)).toList(),
            unit: "g",
          ),
          "Fat": (
            total: data.fold<double>(0, (sum, item) => sum + (item.fat ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.fat)).toList(),
            unit: "g",
          ),
          "Sat. Fat": (
            total: data.fold<double>(0, (sum, item) => sum + (item.saturatedFat ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.saturatedFat)).toList(),
            unit: "g",
          ),
          "Protein": (
            total: data.fold<double>(0, (sum, item) => sum + (item.protein ?? 0),), //total
            entries: data.map((item) => (foodName: item.foodName, value: item.protein)).toList(),
            unit: "g",
          ),
        };

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('   Daily report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
                  IconButton(icon: const Icon(Icons.close),onPressed: () => Navigator.of(context).pop(), ),
                ],
              ),
              getChart(entries),
              getMacroRow(entries),
              getMacroListBreakdown(entries)
            ],
          ),
        );
      },
    );
  }


  Widget getMacroBlock(String label, String value, Color color, {bool highlight = false, double width = 75, double? height,}) {
    
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer( // Animates size, shadow, border, etc.
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: selectedMacro == label ? Border.all(color: Colors.white, width: 2.0) : null,
      ),
      child: InkWell(
        onTap: () => {changeMacroSelection(label)},
        child: Ink(
          decoration: BoxDecoration(
            color: selectedMacro == label ? color.withValues(alpha: 0.8) : color,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          )
        )
      )
    );
  }

  Widget getMacroRow( Map<String, ({double total, List<({String foodName, double? value})> entries, String unit})> entries) {
    const double blockHeight = 60; // Standard single block height

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 1st Column: Calories & Protein
        Column(
          children: [
            getMacroBlock("Calories", entries["Calories"]!.total.toStringAsFixed(1), Colors.black, height: blockHeight - 5),
            const SizedBox(height: 10),
            getMacroBlock("Protein", entries["Protein"]!.total.toStringAsFixed(1), widget.proteinColor, height: blockHeight - 5),
          ],
        ),

        // 2nd Section: Carbs (Tall) + Sugars & Fiber (Stacked)
        IntrinsicHeight( // Forces Carbs to match the height of Sugars + Fiber
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carbs fills 100% of the combined vertical height
              getMacroBlock("Carbs", entries["Carbs"]!.total.toStringAsFixed(1), widget.carbsColor),
              
              // Stacked Sugars & Fiber
              Column(
                children: [
                  getMacroBlock("Sugars", entries["Sugars"]!.total.toStringAsFixed(1), widget.sugarColor, height: blockHeight),
                  getMacroBlock("Fiber", entries["Fiber"]!.total.toStringAsFixed(1), widget.fiberColor, height: blockHeight),
                ],
              ),
            ],
          ),
        ),

        // 3rd Column: Fat & Sat. Fat
        Column(
          children: [
            getMacroBlock("Fat", entries["Fat"]!.total.toStringAsFixed(1), widget.fatColor, height: blockHeight),
            getMacroBlock("Sat. Fat", entries["Sat. Fat"]!.total.toStringAsFixed(1), widget.saturatedFatColor, height: blockHeight),
          ],
        ),
      ],
    );
  }

  Widget getMacroListBreakdown(Map<String, ({double total, List<({String foodName, double? value})> entries, String unit})> entries) {

    String unit = entries["Calories"]!.unit;
    double totals = entries["Calories"]!.total;
    entries["Calories"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
    List<({String foodName, double? value})> sortedData = entries["Calories"]!.entries;
    

    if (selectedMacro == "Calories"){
      entries["Calories"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Calories"]!.entries;
      unit = entries["Calories"]!.unit;
      totals = entries["Calories"]!.total;
    }
    if (selectedMacro == "Carbs"){
      entries["Carbs"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Carbs"]!.entries;
      unit = entries["Carbs"]!.unit;
      totals = entries["Carbs"]!.total;
    }
    if (selectedMacro == "Sugars"){
      entries["Sugars"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Sugars"]!.entries;
      unit = entries["Sugars"]!.unit;
      totals = entries["Sugars"]!.total;
    }
    if (selectedMacro == "Fiber"){
      entries["Fiber"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Fiber"]!.entries;
      unit = entries["Fiber"]!.unit;
      totals = entries["Fiber"]!.total;
    }
    if (selectedMacro == "Fat"){
      entries["Fat"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Fat"]!.entries;
      unit = entries["Fat"]!.unit;
      totals = entries["Fat"]!.total;
    }
    if (selectedMacro == "Sat. Fat"){
      entries["Sat. Fat"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Sat. Fat"]!.entries;
      unit = entries["Sat. Fat"]!.unit;
      totals = entries["Sat. Fat"]!.total;
    }
    if (selectedMacro == "Protein"){
      entries["Protein"]!.entries.sort((a, b) => b.value!.compareTo(a.value!));
      sortedData = entries["Protein"]!.entries;
      unit = entries["Protein"]!.unit;
      totals = entries["Protein"]!.total;
    }

    return Expanded( 
      child: 
        ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sortedData.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final entry = sortedData[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            title: Text(entry.foodName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            trailing: Text(
              "${entry.value!.toStringAsFixed(1)} $unit (${(totals == 0 ? 0 : (entry.value! / totals * 100).toStringAsFixed(0))}%)",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          );
        },
      )
    );    
  }

  Widget getChart(Map<String, ({double total, List<({String foodName, double? value})> entries, String unit})> entries) {

    final double sugar = entries["Sugars"] == null ? 0 : entries["Sugars"]!.total;
    final double fiber = entries["Fiber"] == null ? 0 : entries["Fiber"]!.total;
    final double carbs = (entries["Carbs"] == null ? 0 : entries["Carbs"]!.total) - sugar - fiber;
    final double saturatedFat = entries["Sat. Fat"] == null ? 0 : entries["Sat. Fat"]!.total;
    final double fat = (entries["Fat"] == null ? 0 : entries["Fat"]!.total) - saturatedFat;
    final double protein = entries["Protein"] == null ? 0 : entries["Protein"]!.total;

    final total = carbs + fat + protein;

    final double sugarTotal = total == 0 ? 0 : sugar / total * 100;
    final double fiberTotal = total == 0 ? 0 : fiber / total * 100;
    final double carbsTotal = total == 0 ? 0 : carbs / total * 100;
    final double saturatedFatTotal = total == 0 ? 0 : saturatedFat / total * 100;
    final double fatTotal = total == 0 ? 0 : fat / total * 100;
    final double proteinTotal = total == 0 ? 0 : protein / total * 100;

    return SizedBox(
      height: 200,
      width: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: widget.carbsColor,
              value: carbsTotal,
              title: "${carbsTotal.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: widget.sugarColor,
              value: sugarTotal,
              title: "${sugarTotal.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: widget.fiberColor,
              value: fiberTotal,
              title: "${fiberTotal.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: widget.fatColor,
              value: fatTotal,
              title: "${fatTotal.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: widget.saturatedFatColor,
              value: saturatedFatTotal,
              title: "${saturatedFatTotal.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: widget.proteinColor,
              value: proteinTotal,
              title: "${proteinTotal.toStringAsFixed(0)}%",
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}