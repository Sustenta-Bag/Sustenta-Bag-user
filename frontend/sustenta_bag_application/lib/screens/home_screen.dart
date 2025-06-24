import 'package:flutter/material.dart';
import '../components/bag_card.dart';
import '../services/location_service.dart';
import '../utils/database_helper.dart';
import 'business/business_search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = 'Ver tudo';
  bool showBanner = true;
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> bags = [];
  List<Map<String, dynamic>> allBags = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyBags();
  }

  Future<void> _loadNearbyBags() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await DatabaseHelper.instance.getToken();

      if (token == null) {
        setState(() {
          errorMessage = 'Token de autenticação não encontrado';
          isLoading = false;
        });
        return;
      }

      final response = await LocationService.getNearbyBags(
        token: token,
        radius: 10.0,
        limit: 50,
      );

      if (response != null) {
        final bagsData = LocationService.convertToHomeFormat(response);
        setState(() {
          allBags = bagsData;
          bags = bagsData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Nenhuma sacola encontrada próxima a você';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar sacolas: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredBags {
    if (selectedCategory == 'Ver tudo') return allBags;
    return LocationService.filterBagsByCategory(allBags, selectedCategory);
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
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
          // IconButton(
          //   icon: const Icon(Icons.notifications_none, color: Colors.black),
          //   onPressed: () async {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Configurando notificações...'),
          //         duration: Duration(seconds: 1),
          //       ),
          //     );
          //
          //     final success =
          //         await FirebaseMessagingService.sendFCMTokenToServer();
          //
          //     if (success) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('Notificações configuradas com sucesso!'),
          //           backgroundColor: Colors.green,
          //         ),
          //       );
          //     } else {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text(
          //               'Falha ao configurar notificações. Tente novamente.'),
          //           backgroundColor: Colors.red,
          //         ),
          //       );
          //     }
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.storefront, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusinessSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNearbyBags,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                                    _loadNearbyBags();
                                  },
                                  child: const Text('Atualizar'),
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
                          child:
                              Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
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
              Row(
                children: [
                  const Text(
                    'Sacolas Disponíveis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[600], size: 48),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadNearbyBags,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                        ),
                        child: const Text(
                          'Tentar novamente',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else if (filteredBags.isEmpty && !isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma sacola encontrada',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tente ajustar os filtros ou verificar sua localização',
                        style: TextStyle(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
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
                      business: bag['business'],
                      tags: bag['tags'] ?? [],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: () => _onCategorySelected(title),
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
