import 'package:flutter/material.dart';
import '../../components/bag_card.dart';
import '../../models/bag.dart';
import '../../models/business.dart';
import '../../models/nearby_bag.dart';
import '../../services/bag_service.dart';
import '../../utils/database_helper.dart';

class BusinessBagsScreen extends StatefulWidget {
  final BusinessData business;

  const BusinessBagsScreen({
    super.key,
    required this.business,
  });

  @override
  State<BusinessBagsScreen> createState() => _BusinessBagsScreenState();
}

class _BusinessBagsScreenState extends State<BusinessBagsScreen> {
  late Future<List<Bag>> _bagsFuture;

  @override
  void initState() {
    super.initState();
    _bagsFuture = _fetchBags();
  }

  Future<List<Bag>> _fetchBags() async {
    final token = await DatabaseHelper.instance.getToken();
    if (token == null) {
      throw Exception('Token de autenticação não encontrado.');
    }
    return BagService.getBagsByBusiness(widget.business.id.toString(), token);
  }

  Future<void> _refreshBags() async {
    setState(() {
      _bagsFuture = _fetchBags();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sacolas de ${widget.business.appName}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _refreshBags,
        child: FutureBuilder<List<Bag>>(
          future: _bagsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 50),
                      const SizedBox(height: 16),
                      const Text(
                        'Ocorreu um erro ao buscar as sacolas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString().replaceAll("Exception: ", ""),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refreshBags,
                        child: const Text('Tentar Novamente'),
                      )
                    ],
                  ),
                ),
              );
            }

            final bags = snapshot.data;

            if (bags == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final availableBags = bags.where((bag) => bag.status == 1).toList();

            if (availableBags.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhuma sacola disponível',
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Este estabelecimento não possui sacolas ativas no momento. Volte mais tarde!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.62,
              ),
              itemCount: availableBags.length,
              itemBuilder: (context, index) {
                final bag = availableBags[index];

                final BusinessAddress convertedAddress;
                final sourceAddress = widget.business.address;

                if (sourceAddress != null) {
                  convertedAddress = BusinessAddress(
                    street: sourceAddress.street,
                    number: sourceAddress.number,
                    city: sourceAddress.city,
                    state: sourceAddress.state,
                    zipCode: sourceAddress.zipCode,
                  );
                } else {
                  convertedAddress = BusinessAddress(
                    street: 'Endereço não disponível',
                    number: '',
                    city: '',
                    state: '',
                    zipCode: '',
                  );
                }

                final businessForCard = Business(
                  id: widget.business.id,
                  name: widget.business.appName,
                  legalName: widget.business.legalName,
                  address: convertedAddress,
                  distance: 0.0,
                );

                return BagCard(
                  id: bag.id.toString(),
                  title: bag.name,
                  description: bag.description,
                  price: bag.price,
                  tags: bag.tags,
                  business: businessForCard,
                  imagePath: 'assets/bag.png',
                  category: bag.type,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
