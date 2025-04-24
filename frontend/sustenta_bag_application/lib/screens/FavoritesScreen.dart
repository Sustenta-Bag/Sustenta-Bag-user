import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, String>> mockFavorites = [
    {
      'name': 'Padaria do Zé',
      'logo': 'assets/shop.png',
    },
    {
      'name': 'Doces da Ju',
      'logo': 'assets/shop.png',
    },
    {
      'name': 'Lanches do Leo',
      'logo': 'assets/shop.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
        backgroundColor: Colors.white,
      ),
      backgroundColor:
          const Color(0xFFFFFFFF), 
      body: ListView.builder(
        itemCount: mockFavorites.length,
        itemBuilder: (context, index) {
          final establishment = mockFavorites[index];
          return Card(
            color: const Color(0xFFEACF9D), 
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Color.fromARGB(255, 212, 186, 141), 
                width: 2, 
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading:
                  Image.asset(establishment['logo']!, width: 50, height: 50),
              title: Text(
                establishment['name']!,
                style: const TextStyle(
                  color: Color(0xFF3D3D3D), 
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/home', arguments: establishment);
              },
            ),
          );
        },
      ),
    );
  }
}
