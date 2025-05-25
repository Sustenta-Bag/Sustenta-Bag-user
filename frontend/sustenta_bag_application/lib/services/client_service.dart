import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';
import '../utils/api_config.dart';

class ClientService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Client?> getClient(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Client.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar cliente: $e');
      return null;
    }
  }

  static Future<Client?> updateClient(String id, Map<String, dynamic> data, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clients/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        return Client.fromJson(updatedData);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar cliente: $e');
      return null;
    }
  }

  static Future<bool> deleteClient(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/clients/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao deletar cliente: $e');
      return false;
    }
  }

  static Future<bool> updateStatus(String id, int status, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/clients/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar status do cliente: $e');
      return false;
    }
  }
} 