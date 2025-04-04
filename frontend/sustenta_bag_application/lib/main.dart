import 'package:flutter/material.dart';
import 'screens/homeScreen.dart';
// import 'ordersScreen.dart';
// import 'cartScreen.dart';
// import 'profileScreen.dart';
import 'components/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Surprise Food',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    // const OrdersScreen(),
    // const ProfileScreen(),
    // const CartScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Exibe a tela correspondente
      bottomNavigationBar: BottomNavBar(
        onItemSelected: _onItemTapped,
        // selectedIndex:
        //     _selectedIndex, // Passa o índice selecionado para a Navbar
      ),
    );
  }
}
