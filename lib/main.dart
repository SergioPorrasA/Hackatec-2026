import 'package:flutter/material.dart';
import 'views/feed_view.dart';
import 'views/map_view.dart';
import 'views/report_view.dart';
import 'views/status_view.dart';
import 'views/profile_view.dart';

void main() {
  runApp(const OaxacaReportaApp());
}

class OaxacaReportaApp extends StatelessWidget {
  const OaxacaReportaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oaxaca Reporta',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFCFAF2),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const FeedView(),
    const MapView(),
    const ReportView(),
    const StatusView(),
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
