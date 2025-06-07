// lib/services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../utils/api_config.dart'; // Assumo que ApiConfig existe e está configurado

class ReviewService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Envia uma nova avaliação para o servidor.
  static Future<Review?> createReview(Review review, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(review.toCreatePayload()),
      );

      if (response.statusCode == 201) {
        // Avaliação criada com sucesso
        final data = jsonDecode(response.body);
        return Review.fromJson(data);
      } else {
        // Erro na requisição
        print('Erro ao criar avaliação: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao criar avaliação: $e');
      return null;
    }
  }


  static Future<Review?> getReviewByOrder(int orderId, int clientId, String token) async {
    try {
      // Tentativa de buscar por idOrder e idClient. Se o backend suportar, ótimo.
      // Se não, o backend pode retornar um 404 ou uma lista vazia.
      final response = await http.get(
        // Exemplo de URL com query parameters para filtrar
        Uri.parse('$baseUrl/reviews?idOrder=$orderId&idClient=$clientId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          // A rota GET /api/reviews retorna uma lista, então pegamos o primeiro item se houver.
          // Se sua API garantir que haverá apenas um por orderId/idClient, isso é seguro.
          return Review.fromJson(data.first);
        }
        return null; // Nenhuma avaliação encontrada para este pedido/cliente
      } else if (response.statusCode == 404) {
        return null; // Nenhuma avaliação encontrada (se o backend retornar 404 para não encontrado)
      } else {
        print('Erro ao buscar avaliação do pedido $orderId: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar avaliação do pedido $orderId: $e');
      return null;
    }
  }
}