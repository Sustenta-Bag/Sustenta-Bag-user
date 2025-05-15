import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.onItemSelected,
    required this.currentIndex,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.list, 1),
          _buildNavItem(Icons.shopping_bag, 2),
          _buildNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onItemSelected(index),
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
        ],
      ),
    );
  }
}
