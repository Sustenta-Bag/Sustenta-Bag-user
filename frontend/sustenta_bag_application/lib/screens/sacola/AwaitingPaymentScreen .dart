import 'package:flutter/material.dart';

class AwaitingPaymentScreen extends StatelessWidget {
  const AwaitingPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awaiting Payment')),
      body: Center(child: Text('Awaiting Payment Screen Content')),
    );
  }
}
