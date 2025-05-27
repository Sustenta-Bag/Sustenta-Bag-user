import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/payment.mp4')
      ..initialize().then((_) {
        setState(() {}); 
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBar(40, Colors.black),
        const SizedBox(width: 8),
        _buildBar(40, Colors.black),
        const SizedBox(width: 8),
        _buildBar(40, Colors.grey.shade400),
      ],
    );
  }

  Widget _buildBar(double width, Color color) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Aguardando Pagamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(
              255, 253, 253, 253), // Escolha a cor de fundo desejada
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              if (_controller.value.isInitialized)
                SizedBox(
                  height: 250,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 40),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Assim que seu pagamento for aprovado,\nnós vamos atualizar o status da sua compra',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildProgressBar(),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
