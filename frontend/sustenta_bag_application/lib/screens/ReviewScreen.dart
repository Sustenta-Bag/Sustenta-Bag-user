import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String estabelecimento;
  final String estabelecimentoId;

  const ReviewScreen({
    super.key,
    required this.estabelecimento,
    this.estabelecimentoId = '',
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with TickerProviderStateMixin {
  int _selectedStars = 0;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  bool _isLoading = false;

  late AnimationController _starAnimationController;
  late AnimationController _submitAnimationController;

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textFocusNode.dispose();
    _starAnimationController.dispose();
    _submitAnimationController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedStars == 0) return;

    setState(() => _isLoading = true);

    _submitAnimationController.forward();

    await Future.delayed(const Duration(seconds: 2));

    final reviewData = {
      'store_id': widget.estabelecimentoId,
      'rating': _selectedStars,
      'comment': _controller.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('Dados da avaliação: $reviewData');

    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Avaliação Enviada!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Obrigado por avaliar ${widget.estabelecimento}. Sua opinião é muito importante!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8514C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStar(int index) {
    final isSelected = index <= _selectedStars;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStars = index;
        });
        _starAnimationController.forward().then((_) {
          _starAnimationController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(
          isSelected ? Icons.star : Icons.star_border,
          color: isSelected ? Colors.amber : Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }

  Widget _buildStarRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Como foi sua experiência?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) => _buildStar(index + 1)),
          ),
          if (_selectedStars > 0) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                _getRatingText(_selectedStars),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getRatingColor(_selectedStars),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingText(int stars) {
    switch (stars) {
      case 1: return 'Muito ruim 😞';
      case 2: return 'Ruim 😕';
      case 3: return 'Regular 😐';
      case 4: return 'Bom 😊';
      case 5: return 'Excelente! 🤩';
      default: return '';
    }
  }

  Color _getRatingColor(int stars) {
    switch (stars) {
      case 1: case 2: return Colors.red;
      case 3: return Colors.orange;
      case 4: case 5: return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conte mais sobre sua experiência',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          focusNode: _textFocusNode,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'O que você achou da comida, atendimento, ambiente...?',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8514C)),
            ),
            counterStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _selectedStars > 0 && !_isLoading;

    return AnimatedBuilder(
      animation: _submitAnimationController,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: isEnabled
                  ? const Color(0xFFE8514C)
                  : Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isEnabled ? 2 : 0,
            ),
            onPressed: isEnabled ? _submitReview : null,
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Enviar Avaliação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          'Avaliar ${widget.estabelecimento}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => _textFocusNode.unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStarRatingSection(),
                    const SizedBox(height: 24),
                    _buildCommentSection(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }
}
