import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;
  const BottomNavBar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Ajuste da altura da navbar
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEBAE43), Color(0xFFEA7672)], // Gradiente
          begin: Alignment.topLeft, // Começa no topo esquerdo
          end: Alignment.bottomRight, // Termina no canto inferior direito
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Distribui os botões igualmente
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
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: () {
        onItemSelected(index);
      },
    );
  }
}
