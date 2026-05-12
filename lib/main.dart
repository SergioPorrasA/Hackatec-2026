import 'package:flutter/material.dart';
import 'views/feed_view.dart';
import 'views/login_view.dart';
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
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  Map<String, dynamic>? _user;

  Future<void> _handleLogin(Map<String, dynamic> user) async {
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  void _handleLogout() {
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return LoginView(onLogin: _handleLogin);
    }

    return MainApp(
      user: _user!,
      onLogout: _handleLogout,
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.user, required this.onLogout});

  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileView = ProfileView(
      user: widget.user,
      onLogout: widget.onLogout,
    );
    final reportView = ReportView(user: widget.user);
    final statusView = StatusView(userPhone: (widget.user['phone'] as String?) ?? '');
    final views = [
      const FeedView(),
      const MapView(),
      reportView,
      statusView,
      const SizedBox.shrink(),
    ];

    return Scaffold(
      body: _selectedIndex == 4 ? profileView : views[_selectedIndex],
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
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(
              Icons.add_circle,
              size: 30,
            ),
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
