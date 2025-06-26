import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sustenta_bag_application/models/business.dart';
import 'package:sustenta_bag_application/services/favorite_service.dart';
import '../../config/api_config.dart';
import '../../utils/database_helper.dart';
import '../Review/show_review_screen.dart';
import '../bag/business_bag_screen.dart';

class StoreScreen extends StatefulWidget {
  final String id;
  final String storeName;
  final String storeLogo;
  final String storeDescription;
  final double rating;
  final String workingHours;
  final BusinessData business;

  const StoreScreen({
    super.key,
    required this.id,
    required this.storeName,
    required this.storeLogo,
    required this.storeDescription,
    required this.rating,
    required this.workingHours,
    required this.business,
  });

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool isFavorite = false;
  bool isLoadingFavorite = true;
  String? _token;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      _token = await DatabaseHelper.instance.getToken();
      _userId = await DatabaseHelper.instance.getUserId();
      if (_token != null && _userId != null) {
        final result =
        await FavoriteService.isFavorite(widget.business.id, _token!);
        if (mounted) {
          setState(() {
            isFavorite = result;
          });
        }
      } else {
        debugPrint(
            "Token ou User ID não disponíveis. Favoritos não podem ser verificados/alterados.");
        if (mounted) {
          _showErrorSnackBar(
              "Não foi possível verificar status de favorito (usuário não logado?)");
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar status de favorito: $e");
      if (mounted) {
        _showErrorSnackBar("Erro ao verificar favoritos");
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingFavorite = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_token == null || _userId == null || isLoadingFavorite) {
      if (_userId == null) {
        _showErrorSnackBar("Usuário não logado. Faça login para favoritar.");
      }
      return;
    }

    setState(() => isLoadingFavorite = true);

    try {
      bool success;
      if (isFavorite) {
        success =
        await FavoriteService.removeFavorite(widget.business.id, _token!);
      } else {
        success =
        await FavoriteService.addFavorite(widget.business.id, _token!);
      }

      if (success && mounted) {
        setState(() => isFavorite = !isFavorite);

        final message = isFavorite
            ? "${widget.business.appName} adicionado aos favoritos"
            : "${widget.business.appName} removido dos favoritos";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isFavorite ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        _showErrorSnackBar("Erro ao atualizar favoritos");
      }
    } catch (e) {
      debugPrint("Erro ao alternar favorito: $e");
      if (mounted) {
        _showErrorSnackBar("Erro ao atualizar favoritos");
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingFavorite = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showWhatsAppDialog() async {
    final String phone = widget.business.cellphone;

    if (phone.isEmpty) {
      _showErrorSnackBar('Número de WhatsApp não disponível.');
      return;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Contato WhatsApp'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(FontAwesomeIcons.whatsapp,
                  color: Colors.green, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(phone,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationDialog() async {
    final String? address = widget.business.address?.fullAddress;

    if (address == null || address.isEmpty) {
      _showErrorSnackBar('Endereço não disponível.');
      return;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Endereço'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(address, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildFavoriteButton(),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -60,
                    left: -MediaQuery.of(context).size.width * 0.15,
                    right: -MediaQuery.of(context).size.width * 0.15,
                    child: Image.asset(
                      'assets/detail.png',
                      width: MediaQuery.of(context).size.width * 2.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 30,
                    child: Text(
                      widget.business.appName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    top: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: (widget.business.logo != null &&
                          widget.business.logo!.isNotEmpty)
                          ? Image.network(
                        '${ApiConfig.monolitoStaticUrl}${widget.business.logo}',
                        width: 205,
                        height: 205,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/shop.png',
                            width: 205,
                            height: 205,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        'assets/shop.png',
                        width: 205,
                        height: 205,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 242, 241, 241),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 117, 116, 116)
                                    .withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // WhatsApp
                              _buildActionButton(
                                icon: FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                                onTap: _showWhatsAppDialog,
                              ),
                              const SizedBox(width: 8),

                              // Localização
                              _buildActionButton(
                                icon: Icons.location_on,
                                color: Colors.blue,
                                onTap: _showLocationDialog,
                              ),
                              const SizedBox(width: 8),

                              // Avaliações
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowReviewScreen(
                                        storeId: widget.business.id.toString(),
                                        storeName: widget.business.appName,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Avaliações',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusinessBagsScreen(
                                        business: widget.business,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Ver Bags',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.storeDescription,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 30),
                            _buildInfoRow(
                              icon: Icons.access_time_filled,
                              text: "Horário: ${widget.workingHours}",
                            ),
                            const SizedBox(height: 10),
                            if (widget.business.delivery) ...[
                              _buildInfoRow(
                                icon: Icons.delivery_dining,
                                text:
                                "Entrega em aprox. ${widget.business.deliveryTime ?? '?'} min",
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                icon: Icons.payments,
                                text:
                                "Taxa de entrega: R\$ ${widget.business.deliveryTax?.toStringAsFixed(2) ?? 'N/A'}",
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    if (isLoadingFavorite) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? Colors.red : Colors.black,
          size: 28,
        ),
      ),
      onPressed: _toggleFavorite,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}