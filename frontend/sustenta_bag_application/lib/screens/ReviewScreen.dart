import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String estabelecimento;

  const ReviewScreen({super.key, required this.estabelecimento});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedStars = 0;
  final TextEditingController _controller = TextEditingController();

  void _submitReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação enviada!')),
    );
    Navigator.pop(context);
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _selectedStars ? Icons.star : Icons.star_border,
        color: Colors.amber,
      ),
      onPressed: () {
        setState(() {
          _selectedStars = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Avaliar ${widget.estabelecimento}',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantas estrelas você dá?',
              style: TextStyle(fontSize: 18),
            ),
            Row(
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escreva sua avaliação:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Sua experiência com o estabelecimento...',
                hintStyle: const TextStyle(fontSize: 16),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFE8514C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedStars == 0 ? null : _submitReview,
                child: const Text(
                  'Enviar Avaliação',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
