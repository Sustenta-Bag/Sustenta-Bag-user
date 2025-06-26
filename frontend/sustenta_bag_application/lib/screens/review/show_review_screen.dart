import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../models/reviews_response.dart';
import '../../services/review_service.dart';
import '../../utils/database_helper.dart';

class ReviewStats {
  final Map<int, int> ratingDistribution;

  ReviewStats({
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
  double _averageRating = 0.0;
  int _totalReviews = 0;

  bool isLoading = true;
  bool isPaginating = false;
  String selectedFilter = 'Todas';

  String? _token;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMoreReviews = true;

  @override
  void initState() {
    super.initState();
    _initDataAndLoadReviews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initDataAndLoadReviews() async {
    _token = await DatabaseHelper.instance.getToken();
    if (_token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Token de autenticação não encontrado. Faça login novamente.')),
        );
      }
      setState(() => isLoading = false);
      return;
    }
    _loadReviews(clearExisting: true);
  }

  Future<void> _loadReviews({bool clearExisting = false}) async {
    if (_token == null) return;

    if (clearExisting) {
      setState(() {
        isLoading = true;
        _currentPage = 1;
        _hasMoreReviews = true;
        reviews.clear();
        stats = null;
        _averageRating = 0.0;
        _totalReviews = 0;
      });
    } else {
      if (isPaginating || !_hasMoreReviews) return;
      setState(() {
        isPaginating = true;
      });
    }

    try {
      final ReviewsResponse responseData = await ReviewService.getReviews(
        token: _token!,
        idBusiness: widget.storeId,
        page: _currentPage,
        limit: _limit,
        rating: _getRatingValueForApi(selectedFilter),
      );

      if (mounted) {
        setState(() {
          reviews.addAll(responseData.reviews);
          _totalReviews = responseData.total;
          _averageRating = responseData.avgRating;

          stats = _calculateStatsDistribution(reviews);

          _hasMoreReviews = responseData.reviews.length == _limit;
          if (!clearExisting) {
            _currentPage++;
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar reviews: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar avaliações: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isPaginating = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadReviews(clearExisting: false);
    }
  }

  String? _getRatingValueForApi(String filterText) {
    switch (filterText) {
      case '5 estrelas':
        return '5';
      case '4 estrelas':
        return '4';
      case '3 estrelas':
        return '3';
      case '2 estrelas':
        return '2';
      case '1 estrela':
        return '1';
      default:
        return null;
    }
  }

  ReviewStats _calculateStatsDistribution(List<Review> reviews) {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      }
    }
    return ReviewStats(ratingDistribution: distribution);
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
      body: isLoading && reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => _loadReviews(clearExisting: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildStatsHeader(),
            ),

            /*
                  SliverToBoxAdapter(
                    child: _buildFilters(),
                  ),
                  */

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == reviews.length && isPaginating) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (index >= reviews.length) return null;

                  return _buildReviewCard(reviews[index]);
                },
                childCount: reviews.length + (isPaginating ? 1 : 0),
              ),
            ),
            if (reviews.isEmpty && !isLoading && !isPaginating)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    selectedFilter == 'Todas'
                        ? 'Nenhuma avaliação encontrada para esta loja.'
                        : 'Nenhuma avaliação encontrada com este filtro.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
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
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  _buildStarRating(_averageRating),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalReviews avaliações',
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
                      double percentage =
                      _totalReviews > 0 ? count / _totalReviews : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$stars'),
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.amber),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$count',
                                style: const TextStyle(fontSize: 12)),
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
    final filters = [
      'Todas',
      '5 estrelas',
      '4 estrelas',
      '3 estrelas',
      '2 estrelas',
      '1 estrela'
    ];

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
                if (selected) {
                  setState(() {
                    selectedFilter = filter;
                    _loadReviews(clearExisting: true);
                  });
                }
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
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName ?? 'Cliente Anônimo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStarRating(review.rating.toDouble()),
            ],
          ),
          const SizedBox(height: 12),
          if (review.comment.isNotEmpty)
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