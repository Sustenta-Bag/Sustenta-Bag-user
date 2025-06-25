import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bag.dart';
import '../utils/api_config.dart';

class BagService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<Bag>> getAllBags(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bags'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);

        final List<dynamic> bagData = apiResponse['data'] as List<dynamic>;

        return bagData.map((json) => Bag.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar sacolas: $e');
      return [];
    }
  }

  static Future<Bag?> getBag(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bags/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Bag.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar sacola: $e');
      return null;
    }
  }

  static Future<List<Bag>> getBagsByBusiness(String businessId, String token) async {
    try {
      final uri = Uri.parse('$baseUrl/bags').replace(
          queryParameters: {
            'idBusiness': businessId,
          },
      );
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);

        final List<dynamic> bagData = apiResponse['data'] as List<dynamic>;

        return bagData.map((json) => Bag.fromJson(json)).toList();
      } else {
        print('Erro ao buscar sacolas da empresa: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar sacolas da empresa: $e');
      return [];
    }
  }

}