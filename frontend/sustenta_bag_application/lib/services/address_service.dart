import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address.dart';
import '../utils/api_config.dart';

class AddressService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Address>> getAddresses(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Address.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar endereços: $e');
      return [];
    }
  }

  static Future<Address?> getAddress(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Address.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar endereço: $e');
      return null;
    }
  }

  static Future<Address?> createAddress(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final createdData = jsonDecode(response.body);
        return Address.fromJson(createdData);
      }
      return null;
    } catch (e) {
      print('Erro ao criar endereço: $e');
      return null;
    }
  }

  static Future<Address?> updateAddress(
      String id, Map<String, dynamic> data, String token) async {
    final url = Uri.parse('$baseUrl/addresses/$id');
    print('--- ATUALIZANDO ENDEREÇO ---');
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
          return Address.fromJson(updatedData);
        } catch (e) {
          print('Erro ao decodificar JSON da resposta do endereço: $e');
          return null;
        }
      } else {
        print(
            'Falha ao atualizar endereço. Status: ${response.statusCode}, Motivo: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exceção ao tentar atualizar endereço: $e');
      return null;
    }
  }

  static Future<bool> deleteAddress(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao deletar endereço: $e');
      return false;
    }
  }
}
