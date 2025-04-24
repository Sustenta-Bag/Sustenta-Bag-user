import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/components/navbar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, String>> orderHistory = const [
    {
      'date': 'Dom, 02 fevereiro 2025',
      'title': 'Aurelius Gastro Bar',
      'subtitle': '1 Sacola Salgada',
    },
    {
      'date': 'Qua, 20 novembro 2024',
      'title': 'The Best Açaí',
      'subtitle': '1 Sacola Doce',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status do Pedido'),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, 
      ),
      backgroundColor:
          const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS ATUAL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aguardando Pagamento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Sacola Mista | Kampai Sushi'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // HISTÓRICO
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // LISTA DINÂMICA
            ...orderHistory.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildHistoryItem(
                    date: order['date']!,
                    title: order['title']!,
                    subtitle: order['subtitle']!,
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, 
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/history');
              break;
            case 2:
              Navigator.pushNamed(context, '/bag');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fazer avaliação',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(subtitle),
              )
            ],
          ),
        ),
      ],
    );
  }
}
