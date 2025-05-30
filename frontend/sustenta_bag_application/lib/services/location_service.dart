import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nearby_bag.dart';
import '../utils/api_config.dart';

class LocationService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<NearbyBagsResponse?> getNearbyBags({
    required String token,
    double radius = 10.0,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'radius': radius.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/locations/nearby/client/bags')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NearbyBagsResponse.fromJson(data);
      } else if (response.statusCode == 400) {
        print('Cliente não possui endereço cadastrado');
        return null;
      } else if (response.statusCode == 401) {
        print('Token de autorização inválido');
        return null;
      } else if (response.statusCode == 403) {
        print('Acesso negado - apenas clientes podem acessar esta rota');
        return null;
      } else {
        print('Erro ao buscar sacolas próximas: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar sacolas próximas: $e');
      return null;
    }
  }

  static List<Map<String, dynamic>> convertToHomeFormat(
      NearbyBagsResponse response) {
    return response.data.map((bag) => bag.toBagCardFormat()).toList();
  }

  static List<Map<String, dynamic>> filterBagsByCategory(
    List<Map<String, dynamic>> bags,
    String category,
  ) {
    if (category == 'Ver tudo') return bags;
    return bags.where((bag) => bag['category'] == category).toList();
  }

  static String mapApiTypeToCategory(String type) {
    switch (type.toLowerCase()) {
      case 'doce':
      case 'doces':
        return 'Doces';
      case 'salgado':
      case 'salgados':
        return 'Salgados';
      case 'mista':
      case 'mistas':
      case 'mixta':
        return 'Mistas';
      default:
        return 'Mistas';
    }
  }
}
