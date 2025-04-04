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
  bool showBanner = true;
  bool categorySelected = true;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.black87),
          thickness: MaterialStateProperty.all(4),
          radius: const Radius.circular(8),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBanner)
                  Stack(
                    children: [
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: null,
                                    child: Text('Ver'),
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
                          onTap: () {
                            setState(() {
                              showBanner = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                if (categorySelected) ...[
                  const Text(
                    'Sacolas Disponíveis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: filteredBags.map((bag) {
                      return BagCard(
                        id: bag['id'],
                        imagePath: bag['imagePath'],
                        description: bag['description'],
                        title: bag['title'],
                        price: bag['price'],
                        category: bag['category'],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/order');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/bag');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/user');
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
          categorySelected = true;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor:
                selectedCategory == title ? Colors.orange : Colors.grey[200],
            child: Icon(
              icon,
              color: selectedCategory == title ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
