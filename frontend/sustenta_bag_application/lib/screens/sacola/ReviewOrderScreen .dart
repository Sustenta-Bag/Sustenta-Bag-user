import 'package:flutter/material.dart';

class ReviewOrderScreen extends StatelessWidget {
  const ReviewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Order')),
      body: Center(child: Text('Review Order Screen Content')),
    );
  }
}
