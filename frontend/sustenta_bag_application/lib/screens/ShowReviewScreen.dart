import 'package:flutter/material.dart';

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> productNames;
  final bool isVerified;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.productNames,
    this.isVerified = false,
  });
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}

class ShowReviewScreen extends StatefulWidget {
  final String storeId;
  final String storeName;

  const ShowReviewScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<ShowReviewScreen> createState() => _ShowReviewScreenState();
}

class _ShowReviewScreenState extends State<ShowReviewScreen> {
  List<Review> reviews = [];
  ReviewStats? stats;
  bool isLoading = true;
  String selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    reviews = _getMockReviews();
    stats = _calculateStats(reviews);

    setState(() => isLoading = false);
  }

  List<Review> _getMockReviews() {
    return [
      Review(
        id: '1',
        userName: 'Maria Silva',
        rating: 5.0,
        comment: 'Excelente! O hambúrguer estava perfeito e chegou quentinho. O molho especial é incrível!',
        date: DateTime.now().subtract(const Duration(days: 1)),
        productNames: ['Sacola Salgada'],
        isVerified: true,
      ),
      Review(
        id: '2',
        userName: 'João Santos',
        rating: 4.0,
        comment: 'Muito bom! A pizza estava saborosa, mas demorou um pouco para chegar.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        productNames: ['Sacola Salgada'],
        isVerified: false,
      ),
      Review(
        id: '3',
        userName: 'Ana Costa',
        rating: 5.0,
        comment: 'Perfeito! Comida deliciosa e entrega rápida. Recomendo!',
        date: DateTime.now().subtract(const Duration(days: 3)),
        productNames: ['Sacola Salgada'],
        isVerified: true,
      ),
      Review(
        id: '4',
        userName: 'Pedro Lima',
        rating: 3.0,
        comment: 'Razoável. A comida estava ok.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        productNames: ['Sacola Salgada'],
        isVerified: false,
      ),
      Review(
        id: '5',
        userName: 'Carla Oliveira',
        rating: 4.5,
        comment: 'Muito bom! O sushi estava fresco e bem preparado.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        productNames: ['Sacola Salgada'],
        isVerified: true,
      ),
    ];
  }

  ReviewStats _calculateStats(List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewStats(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {},
      );
    }

    double sum = reviews.fold(0, (sum, review) => sum + review.rating);
    double average = sum / reviews.length;

    Map<int, int> distribution = {};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = reviews.where((r) => r.rating.round() == i).length;
    }

    return ReviewStats(
      averageRating: average,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
    );
  }

  List<Review> get filteredReviews {
    switch (selectedFilter) {
      case '5 estrelas':
        return reviews.where((r) => r.rating >= 4.5).toList();
      case '4 estrelas':
        return reviews.where((r) => r.rating >= 3.5 && r.rating < 4.5).toList();
      case '3 estrelas':
        return reviews.where((r) => r.rating >= 2.5 && r.rating < 3.5).toList();
      case '2 estrelas':
        return reviews.where((r) => r.rating >= 1.5 && r.rating < 2.5).toList();
      case '1 estrela':
        return reviews.where((r) => r.rating < 1.5).toList();
      default:
        return reviews;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliações - ${widget.storeName}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadReviews,
        child: CustomScrollView(
          slivers: [
            // Cabeçalho com estatísticas
            SliverToBoxAdapter(
              child: _buildStatsHeader(),
            ),

            // Filtros
            SliverToBoxAdapter(
              child: _buildFilters(),
            ),

            // Lista de avaliações
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final filteredList = filteredReviews;
                  if (index >= filteredList.length) return null;

                  return _buildReviewCard(filteredList[index]);
                },
                childCount: filteredReviews.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    if (stats == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    stats!.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  _buildStarRating(stats!.averageRating),
                  const SizedBox(height: 4),
                  Text(
                    '${stats!.totalReviews} avaliações',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 80,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: List.generate(5, (index) {
                      int stars = 5 - index;
                      int count = stats!.ratingDistribution[stars] ?? 0;
                      double percentage = stats!.totalReviews > 0
                          ? count / stats!.totalReviews
                          : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$stars'),
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$count', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Todas', '5 estrelas', '4 estrelas', '3 estrelas', '2 estrelas', '1 estrela'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.orange.withOpacity(0.2),
              checkmarkColor: Colors.amber,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do usuário
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ],
                    ),
                    Text(
                      _formatDate(review.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStarRating(review.rating),
            ],
          ),

          const SizedBox(height: 12),

          // Produtos avaliados
          if (review.productNames.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: review.productNames.map((product) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

