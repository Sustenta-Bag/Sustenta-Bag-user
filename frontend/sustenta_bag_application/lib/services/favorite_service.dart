import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/business.dart';
import '../utils/database_helper.dart';

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

  static Future<bool> isFavorite(int businessId, String token) async {
    try {
      final idClient = await DatabaseHelper.instance.getEntityId();
      if (idClient == null) {
        print('Erro: idClient não encontrado no banco local');
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites?idClient=$idClient'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .any((favoriteItem) => favoriteItem['idBusiness'] == businessId);
      } else {
        print(
            'Erro ao verificar favorito: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao verificar favorito: $e');
      return false;
    }
  }

  static Future<bool> addFavorite(int businessId, String token) async {
    try {
      final idClient = await DatabaseHelper.instance.getEntityId();
      if (idClient == null) {
        print('Erro: idClient não encontrado no banco local');
        return false;
      }

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
        Uri.parse('$baseUrl/favorites/business/$businessId'),
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
      final idClient = await DatabaseHelper.instance.getEntityId();
      if (idClient == null) {
        print('Erro: idClient não encontrado no banco local');
        return [];
      }

      final favsResponse = await http.get(
        Uri.parse('$baseUrl/favorites?idClient=$idClient'),
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

  static Future<bool> toggleFavorite(int businessId, String token) async {
    try {
      final isFav = await isFavorite(businessId, token);

      if (isFav) {
        return await removeFavorite(businessId, token);
      } else {
        return await addFavorite(businessId, token);
      }
    } catch (e) {
      print('Erro ao alternar favorito: $e');
      return false;
    }
  }
  static Future<int> getFavoritesCount(String token) async {
    try {
      final idClient = await DatabaseHelper.instance.getEntityId();
      if (idClient == null) {
        print('Erro: idClient não encontrado no banco local');
        return 0;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/count?idClient=$idClient'),
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
