import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/favorites'),
          icon: const Icon(Icons.favorite, color: Color(0xFFE8514C)),
          label: const Text('Favoritos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF2F2F2),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
