import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:local_ai_calorie_app/globals.dart';
import 'package:local_ai_calorie_app/widgets/debug.dart';
import 'package:local_ai_calorie_app/widgets/diary_main_screen.dart';
import 'package:local_ai_calorie_app/widgets/food_list.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  FlutterGemma.initialize(
    // Inference engines — add the ones whose packages you depend on:
    inferenceEngines: [
      LiteRtLmEngine()   // flutter_gemma_builtin_ai — Gemini Nano / Apple FM
    ],
    maxDownloadRetries: 10,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      scaffoldMessengerKey: snackbarKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  int _currentIndex = 0;

  // List of root tab screens
  final List<Widget> _screens = [
    const DiaryMainScreen(),
    const Center(child: Text('Analytics Screen (Coming Soon)')),
    FoodList(),
    const Center(child: Text('Profile & Settings (Coming Soon)')),
    DebugScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves state (like scroll position) when switching tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Foods',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.bug_report_outlined),
            selectedIcon: Icon(Icons.bug_report),
            label: 'Debug',
          ),
        ],
      ),
    );
  }
}
