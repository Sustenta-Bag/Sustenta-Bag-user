import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.onItemSelected,
    required this.currentIndex,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEBAE43), Color(0xFFEA7672)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.list, 1),
          _buildNavItem(Icons.shopping_bag, 2),
          _buildNavItem(Icons.person, 3),
        ],
      ),
    );
  }
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == widget.currentIndex;

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3), 
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          Icon(
            icon,
            color: Colors.white,
            size: isSelected ? 36 : 30,
          ),
          if (index == 2 && _cartService.itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  '${_cartService.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
