import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../models/reviews_response.dart';
import '../utils/api_config.dart';

class ReviewService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Review?> createReview(Review review, String token) async {
    try {
      print(
          'DEBUG: Enviando avaliação para $baseUrl/reviews com payload: ${jsonEncode(review.toCreatePayload())}');
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(review.toCreatePayload()),
      );


      if (response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            print('DEBUG: JSON decodificado: $data');
            return Review.fromJson(data);
          } catch (jsonError) {
            print(
                'ERRO DE PARSING JSON: O servidor retornou 201, mas falhou ao decodificar/parsear o JSON de resposta: $jsonError');
            print('Corpo da resposta que causou o erro: "${response.body}"');
            return null;
          }
        } else {
          print(
              'DEBUG: Review criada com sucesso (201) mas sem corpo de resposta JSON. Assumindo sucesso.');
          return review;
        }
      } else {
        print(
            'ERRO: Falha na requisição para criar avaliação. Status Code: ${response.statusCode}, Body: "${response.body}"');
        return null;
      }
    } catch (e) {
      print(
          'ERRO INESPERADO: Erro ao criar avaliação (provavelmente problema de rede ou formato da requisição): $e');
      return null;
    }
  }

  static Future<Review?> getReviewByOrder(
      int orderId, int clientId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews?idOrder=$orderId&idClient=$clientId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final reviewsResponse = ReviewsResponse.fromJson(responseData);

        if (reviewsResponse.reviews.isNotEmpty) {
          return reviewsResponse.reviews.first;
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print(
            'Erro ao buscar avaliação do pedido $orderId: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar avaliação do pedido $orderId: $e');
      return null;
    }
  }

  static Future<ReviewsResponse> getReviews({
    required String token,
    String? idBusiness,
    String? idClient,
    int page = 1,
    int limit = 20,
    String? rating,
  }) async {
    try {
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (idBusiness != null) {
        queryParameters['idBusiness'] = idBusiness;
      }
      if (idClient != null) {
        queryParameters['idClient'] = idClient;
      }
      if (rating != null && rating.isNotEmpty) {
        queryParameters['rating'] = rating;
      }

      final uri = Uri.parse('$baseUrl/reviews')
          .replace(queryParameters: queryParameters);

      print('Fetching reviews from: $uri');
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Raw API response: $responseData');
        final reviewsResponse = ReviewsResponse.fromJson(responseData);
        print(
            'Reviews fetched: ${reviewsResponse.reviews.length}, Total: ${reviewsResponse.total}, AvgRating: ${reviewsResponse.avgRating}');
        return reviewsResponse;
      } else {
        print(
            'Erro ao buscar reviews: ${response.statusCode} - ${response.body}');
        return ReviewsResponse(reviews: [], total: 0, avgRating: 0.0);
      }
    } catch (e) {
      print('Erro ao buscar reviews: $e');
      return ReviewsResponse(reviews: [], total: 0, avgRating: 0.0);
    }
  }
}
