import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:local_ai_calorie_app/main.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';



class Analytics extends StatefulWidget {

  final MaterialColor carbsColor = Colors.blue;
  final MaterialColor sugarColor = Colors.indigo;
  final MaterialColor fiberColor = Colors.deepPurple;
  final MaterialColor fatColor = Colors.amber;
  final MaterialColor saturatedFatColor = Colors.deepOrange;
  final MaterialColor proteinColor = Colors.green;

  const Analytics({super.key});

  @override
  State<Analytics> createState() => AnalyticsState();
}

class AnalyticsState extends State<Analytics> {

  late Future<List<({DateTime date, double calories, double carbs, double sugars, double fiber, double fat, double saturatedFat, double protein,})>> futureEntriesTotals;
  String lineChartLabel = "Last 7 days";
  String chartAverage = "0";
  DateTime startMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: -7));
  DateTime endMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  int calendarDaysBetween = 0;

  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _minCaloriesController = TextEditingController();

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
    // _loadData;
    futureEntriesTotals = DatabaseHelper.instance.getMacroTotalsForDates(startMidnight, endMidnight);
  }

  void loadData() {
    setState(() {
      futureEntriesTotals = DatabaseHelper.instance.getMacroTotalsForDates(startMidnight, endMidnight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: 
            FutureBuilder<List<({DateTime date, double calories, double carbs, double sugars, double fiber, double fat, double saturatedFat, double protein,})>>(
            future: futureEntriesTotals,
            builder: (context, snapshot) {
            final data = snapshot.data ?? [];

            return Stack(
                children: <Widget>[
                    AspectRatio(
                    aspectRatio: 1.70,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: 18,
                            left: 12,
                            top: 24,
                            bottom: 12,
                            ),
                            child: 
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                    if (!data.isNotEmpty) Text("No data", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), ),
                                    if (data.isNotEmpty) Expanded(child: LineChart(mainData(data),),),
                                    if (data.isNotEmpty) Text("$lineChartLabel - Avg: $chartAverage kcal", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), ),
                                    
                                ],
                            )
                    ),
                ),
            ],
          );
        }
      )      
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value == meta.min || value == meta.max) {
        return const SizedBox.shrink();
    }

    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
  
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');

    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontSize: 15,
    );
    return SideTitleWidget(
      meta: meta,
      child: Text("$month.$day", style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {

    if (value == meta.min || value == meta.max) {
        return const SizedBox.shrink();
    }

    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontSize: 15,
    );
    return SideTitleWidget(
        meta: meta,
        space: 6, // Distance between label and chart grid line
        child: Text(
        formatToK(value),
        style: style,
        textAlign: TextAlign.right, // Standard alignment for Y-axis
      ),
    );
  }

  String formatToK(num number) {
    double value = number / 1000;
    return '${value.toStringAsFixed(1)}k'; 
  }

  LineChartData mainData(List<({DateTime date, double calories, double carbs, double sugars, double fiber, double fat, double saturatedFat, double protein})> data) {
    if (data.isEmpty) {
      return LineChartData();
    }

    // Sort to ensure proper chart rendering
    data.sort((a, b) => a.date.compareTo(b.date));

    double minX = data.first.date.millisecondsSinceEpoch.toDouble();
    double maxX = data.last.date.millisecondsSinceEpoch.toDouble();

    // Fix #2: Prevent divide-by-zero if there's only 1 data point
    if (minX == maxX) {
      minX -= (24 * 60 * 60 * 1000); // Expand range by 1 day back
      maxX += (24 * 60 * 60 * 1000); // Expand range by 1 day forward
    }

    double minValue = data.map((i) => i.calories).reduce(math.min) - 100;
    double maxValue = data.map((i) => i.calories).reduce(math.max) + 100;

    // Prevent Y-axis crash if all calorie values are identical
    if (minValue == maxValue) {
      minValue -= 100;
      maxValue += 100;
    }

    // Fix #1: Calculate local average without mutating widget state directly in build
    double avg = data.map((e) => e.calories).reduce((a, b) => a + b) / data.length;
    chartAverage = avg.toStringAsFixed(0);
    calendarDaysBetween = endMidnight.difference(startMidnight).inDays;
    lineChartLabel = "Last $calendarDaysBetween days";

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        // Fix #2: Avoid static 1 interval on millisecond timestamps!
        horizontalInterval: ((maxValue - minValue) / 5).clamp(1.0, double.infinity),
        verticalInterval: ((maxX - minX) / 5).clamp(1.0, double.infinity),
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Colors.transparent,
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: const Color(0xff37434d).withValues(alpha: 0.3),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (24 * 60 * 60 * 1000).toDouble(), // 1 day
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: ((maxValue - minValue) / 4).clamp(100.0, double.infinity),
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: minX,
      maxX: maxX,
      minY: math.max(0, minValue), // Don't allow negative calorie Y-axis
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          spots: data.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.calories)).toList(),
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withValues(alpha: 0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  } 
}