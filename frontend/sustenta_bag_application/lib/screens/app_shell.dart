import 'package:flutter/material.dart';
import '../components/navbar.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'bag/bag_screen.dart';
import 'profile_screen.dart';
import '../services/cart_service.dart';
import '../utils/database_helper.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;
  final CartService _cartService = CartService();

  final pages = const [
    DashboardScreen(),
    HistoryScreen(),
    BagScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadActiveCartOnLogin();
  }

  Future<void> _loadActiveCartOnLogin() async {
    try {
      final token = await DatabaseHelper.instance.getToken();
      final userData = await DatabaseHelper.instance.getUser();
      
      if (token != null && userData != null) {
        await _cartService.loadActiveCart(userData['id'], token);
      }
    } catch (e) {
      print('Erro ao carregar carrinho ativo no AppShell: $e');
    }
  }

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
