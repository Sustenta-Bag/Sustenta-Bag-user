import 'package:flutter/material.dart';
import '../components/bagCard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = 'Ver tudo';
  bool showBanner = true;

  final List<Map<String, dynamic>> bags = [
     {
      'id': '1',
      'imagePath': 'assets/bag.png',
      'description': 'Doces irresistíveis para adoçar seu dia!',
      'title': 'Sweet Surprise',
      'price': 20.50,
      'category': 'Doces'
    },
    {
      'id': '2',
      'imagePath': 'assets/bag.png',
      'description': 'Salgados crocantes e saborosos!',
      'title': 'Salty Secret',
      'price': 15.50,
      'category': 'Salgados'
    },
    {
      'id': '3',
      'imagePath': 'assets/bag.png',
      'description': 'Uma mistura deliciosa de doces e salgados!',
      'title': 'Mixed Mystery',
      'price': 18.90,
      'category': 'Mistas'
    },
    {
      'id': '1',
      'imagePath': 'assets/bag.png',
      'description': 'Doces irresistíveis para adoçar seu dia!',
      'title': 'Sweet Surprise',
      'price': 20.50,
      'category': 'Doces'
    },
    {
      'id': '2',
      'imagePath': 'assets/bag.png',
      'description': 'Salgados crocantes e saborosos!',
      'title': 'Salty Secret',
      'price': 15.50,
      'category': 'Salgados'
    },
    {
      'id': '3',
      'imagePath': 'assets/bag.png',
      'description': 'Uma mistura deliciosa de doces e salgados!',
      'title': 'Mixed Mystery',
      'price': 18.90,
      'category': 'Mistas'
    },
    {
      'id': '1',
      'imagePath': 'assets/bag.png',
      'description': 'Doces irresistíveis para adoçar seu dia!',
      'title': 'Sweet Surprise',
      'price': 20.50,
      'category': 'Doces'
    },
    {
      'id': '2',
      'imagePath': 'assets/bag.png',
      'description': 'Salgados crocantes e saborosos!',
      'title': 'Salty Secret',
      'price': 15.50,
      'category': 'Salgados'
    },
    {
      'id': '3',
      'imagePath': 'assets/bag.png',
      'description': 'Uma mistura deliciosa de doces e salgados!',
      'title': 'Mixed Mystery',
      'price': 18.90,
      'category': 'Mistas'
    },
  ];

  List<Map<String, dynamic>> get filteredBags {
    if (selectedCategory == 'Ver tudo') return bags;
    return bags.where((b) => b['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Início', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBanner)
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/foods.png', width: 80),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Veja sacolas perto de você',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // ação futura
                                },
                                child: const Text('Ver'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => showBanner = false),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black38,
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Categorias Populares',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategory('Salgados', Icons.fastfood),
                _buildCategory('Doces', Icons.cake),
                _buildCategory('Mistas', Icons.restaurant),
                _buildCategory('Ver tudo', Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Sacolas Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBags.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, index) {
                final bag = filteredBags[index];
                return BagCard(
                  id: bag['id'],
                  imagePath: bag['imagePath'],
                  description: bag['description'],
                  title: bag['title'],
                  price: bag['price'],
                  category: bag['category'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? Colors.orange : Colors.grey[200],
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
