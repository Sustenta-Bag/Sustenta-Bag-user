import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/business.dart';

class FavoriteService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<BusinessData?> _fetchBusinessDetails(
      int businessId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/$businessId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Detalhes da empresa $businessId recebidos: $data'); // Log de sucesso
        return BusinessData.fromJson(data);
      } else {
        print(
            'Erro ao buscar detalhes da empresa $businessId: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro de rede ao buscar detalhes da empresa $businessId: $e');
      return null;
    }
  }

  static Future<int?> _getFavoriteIdForBusiness(
      int businessId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final favoriteItem = data.firstWhere(
              (item) => item['idBusiness'] == businessId,
          orElse: () => null,
        );
        if (favoriteItem != null && favoriteItem['idFavorite'] != null) {
          return favoriteItem['idFavorite'] as int;
        }
      } else {
        print(
            'Erro ao buscar ID do favorito para o negócio $businessId: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro de rede ao buscar ID do favorito para o negócio $businessId: $e');
    }
    return null;
  }

  static Future<bool> isFavorite(int businessId, String token) async {
    final favoriteId = await _getFavoriteIdForBusiness(businessId, token);
    return favoriteId != null;
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
        print('Favorito adicionado com sucesso para businessId: $businessId');
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
        Uri.parse('$baseUrl/favorites/business/$businessId'),
        headers: ApiConfig.getHeaders(token),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Favorito $businessId removido com sucesso.');
        return true;
      } else {
        print(
            'Erro ao remover favorito $businessId: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao remover favorito $businessId: $e');
      return false;
    }
  }

  static Future<List<BusinessData>> getFavorites(String token) async {
    try {
      final favsResponse = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: ApiConfig.getHeaders(token),
      );

      if (favsResponse.statusCode != 200) {
        print(
            'Erro ao carregar IDs de favoritos: ${favsResponse.statusCode} - ${favsResponse.body}');
        return [];
      }

      final List<dynamic> favoriteIdObjects = jsonDecode(favsResponse.body);
      final List<int> businessIds = favoriteIdObjects
          .map<int>((item) => item['idBusiness'] as int)
          .toList();

      final List<Future<BusinessData?>> fetchFutures =
      businessIds.map((id) => _fetchBusinessDetails(id, token)).toList();

      final List<BusinessData?> results = await Future.wait(fetchFutures);
      return results.whereType<BusinessData>().toList();
    } catch (e) {
      print('Erro ao carregar favoritos (detalhes): $e');
      return [];
    }
  }

  static Future<bool> toggleFavorite(
      int businessId, int clientId, String token) async {
    try {
      final int? existingFavoriteId =
      await _getFavoriteIdForBusiness(businessId, token);

      if (existingFavoriteId != null) {
        print('Removendo favorito com idFavorite: $existingFavoriteId para businessId: $businessId');
        return await removeFavorite(existingFavoriteId, token);
      } else {
        print('Adicionando favorito para businessId: $businessId e clientId: $clientId');
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