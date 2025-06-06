import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/business.dart';

class FavoriteService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<bool> isFavorite(int businessId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/check/$businessId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorite'] ?? false;
      }
      return false;
    } catch (e) {
      print('Erro ao verificar favorito: $e');
      return false;
    }
  }

  static Future<bool> addFavorite(
      int businessId, int idClient, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: ApiConfig.getHeaders(token)
          ..['Content-Type'] = 'application/json',
        body: jsonEncode({'idBusiness': businessId, 'idClient': idClient}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
            'Erro ao adicionar favorito: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao adicionar favorito: $e');
      return false;
    }
  }

  static Future<bool> removeFavorite(int businessId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$businessId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print(
            'Erro ao remover favorito: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao remover favorito: $e');
      return false;
    }
  }

  static Future<List<BusinessData>> getFavorites(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => BusinessData.fromJson(json['business'] ?? json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
      return [];
    }
  }

  static Future<bool> toggleFavorite(
      int businessId, int clientId, String token) async {
    try {
      final isFav = await isFavorite(businessId, token);

      if (isFav) {
        return await removeFavorite(businessId, token);
      } else {
        return await addFavorite(businessId, clientId, token);
      }
    } catch (e) {
      print('Erro ao alternar favorito: $e');
      return false;
    }
  }

  static Future<int> getFavoritesCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/count'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Erro ao contar favoritos: $e');
      return 0;
    }
  }
}
