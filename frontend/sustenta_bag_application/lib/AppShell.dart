import 'package:flutter/material.dart';
import 'components/navbar.dart';
import 'screens/homeScreen.dart';
import 'screens/HistoryScreen.dart';
import 'screens/bag/BagScreen.dart';
import 'screens/ProfileScreen.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  final pages = const [
    DashboardScreen(),
    HistoryScreen(),
    BagScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onItemSelected: (i) => setState(() => currentIndex = i),
      ),
    );
  }
}
