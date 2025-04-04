import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/bagCard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = 'Ver tudo';

  // Lista completa de sacolas disponíveis
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
      'id': '1',
      'imagePath': 'assets/bag.png',
      'description': 'Doces irresistíveis para adoçar seu dia!',
      'title': 'Sweet Surprise',
      'price': 20.50,
      'category': 'Doces'
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
      'id': '1',
      'imagePath': 'assets/bag.png',
      'description': 'Salgados crocantes e saborosos!',
      'title': 'Salty Secret',
      'price': 15.50,
      'category': 'Salgados'
    },
    {
      'id': '1',
      'imagePath': 'assets/bag.png',
      'description': 'Uma mistura deliciosa de doces e salgados!',
      'title': 'Mixed Mystery',
      'price': 18.90,
      'category': 'Mistas'
    },
  ];

  // Filtra as sacolas de acordo com a categoria selecionada
  List<Map<String, dynamic>> get filteredBags {
    if (selectedCategory == 'Ver tudo') {
      return bags;
    }
    return bags.where((bag) => bag['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Pesquisar',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset('assets/foods.png', width: 80),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veja sacolas perto de você',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Ver'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Categorias
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
            // Sacolas Disponíveis
            const Text(
              'Sacolas Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.6,
                children: filteredBags.map((bag) {
                  return BagCard(
                    imagePath: bag['imagePath'],
                    description: bag['description'],
                    title: bag['title'],
                    price: bag['price'],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onItemSelected: (index) {
          print('Selected index: $index');
        },
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor:
                selectedCategory == title ? Colors.orange : Colors.grey[200],
            child: Icon(icon,
                color:
                    selectedCategory == title ? Colors.white : Colors.black54),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selectedCategory == title
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
