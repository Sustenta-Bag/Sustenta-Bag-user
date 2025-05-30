import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';
import '../utils/api_config.dart';

class ClientService {
  static String get baseUrl => ApiConfig.baseUrl;

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

  static Future<Client?> updateClient(
      String id, Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$baseUrl/clients/$id');
    print('--- ATUALIZANDO CLIENTE ---');
    print('URL de Requisição: $url');
    print('Token de Autorização: Bearer $token');
    print('Dados Enviados (Payload): ${jsonEncode(data)}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(data),
      );

      print('Status Code da Resposta: ${response.statusCode}');
      print('Corpo da Resposta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final updatedData = jsonDecode(response.body);
          return Client.fromJson(updatedData);
        } catch (e) {
          print('Erro ao decodificar JSON da resposta do cliente: $e');
          return null;
        }
      } else {
        print(
            'Falha ao atualizar cliente. Status: ${response.statusCode}, Motivo: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exceção ao tentar atualizar cliente: $e');
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
