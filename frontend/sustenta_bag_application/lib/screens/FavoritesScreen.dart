import 'package:flutter/material.dart';
import 'package:sustenta_bag_application/services/favorite_service.dart';
import 'package:sustenta_bag_application/utils/database_helper.dart';
import 'package:sustenta_bag_application/models/business.dart';
import 'package:sustenta_bag_application/screens/StoreScreen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<BusinessData> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _token = await DatabaseHelper.instance.getToken();
      if (_token == null) {
        setState(() {
          _errorMessage = "Você precisa estar logado para ver seus favoritos.";
          _isLoading = false;
        });
        return;
      }

      final fetchedFavorites = await FavoriteService.getFavorites(_token!);
      setState(() {
        _favorites = fetchedFavorites;
      });
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
      setState(() {
        _errorMessage = "Erro ao carregar favoritos. Tente novamente.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFavoritesChanged() {
    _loadFavorites();
  }

  Widget _buildFavoriteCard(BusinessData business) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEACF9D), Color(0xFFF5E6C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreScreen(
                  id: business.id.toString(),
                  storeName: business.appName,
                  storeLogo: business.logo ?? 'assets/shop.png',
                  storeDescription: business.description ?? 'Não há descrição para esta loja.',
                  rating: 0.0,
                  workingHours: 'Horário não disponível',
                  business: business,
                ),
              ),
            );
            _onFavoritesChanged();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Logo da loja
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: business.logo != null && business.logo!.isNotEmpty
                        ? Image.network(
                      business.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackLogo(),
                    )
                        : _buildFallbackLogo(),
                  ),
                ),
                const SizedBox(width: 16),

                // Informações da loja
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome da loja
                      Text(
                        business.appName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      Text(
                        business.description ?? 'Sem descrição disponível',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          if (business.delivery == true) ...[
                            _buildInfoChip(
                              icon: Icons.delivery_dining,
                              label: 'Delivery',
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (business.deliveryTax != null)
                            _buildInfoChip(
                              icon: Icons.local_shipping,
                              label: 'R\$ ${business.deliveryTax!.toStringAsFixed(2)}',
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEACF9D).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.store,
        color: Color(0xFF8B7355),
        size: 32,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEACF9D).withOpacity(0.3),
                    const Color(0xFFF5E6C8).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum favorito ainda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione lojas aos seus favoritos\npara encontrá-las facilmente aqui!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32)
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Meus Favoritos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            if (_favorites.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEACF9D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_favorites.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        centerTitle: false,
        actions: [
          if (!_isLoading && _favorites.isNotEmpty)
            IconButton(
              onPressed: _loadFavorites,
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEACF9D)),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando favoritos...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : _errorMessage != null
          ? _buildErrorState()
          : _favorites.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadFavorites,
        color: const Color(0xFFEACF9D),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _favorites.length,
          itemBuilder: (context, index) {
            return _buildFavoriteCard(_favorites[index]);
          },
        ),
      ),
    );
  }
}