import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_tracker/providers/ThemeProvider.dart';
import 'package:life_tracker/screens/Welcome.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_tracker/models/TaskModel.dart';
import 'package:life_tracker/models/SectorModel.dart';
import 'screens/Home.dart';
import 'screens/DailyTracker.dart';
import 'screens/Sector.dart';
import 'screens/Routine.dart';
import 'screens/Statistics.dart';
import 'package:life_tracker/adapters/time_of_day_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(SectorModelAdapter());
  
  // Open the boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<SectorModel>('sectors');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Life Tracker',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const WelcomePage(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const DailyTrackerPage(),
    const SectorOverviewPage(),
    const AddEditRoutinePage(),
    const StatisticsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Sectors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}