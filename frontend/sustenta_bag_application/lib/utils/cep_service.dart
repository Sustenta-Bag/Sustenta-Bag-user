import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static Future<Map<String, dynamic>?> buscarEndereco(String cep) async {
    final cleanedCep = cep.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://viacep.com.br/ws/$cleanedCep/json/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['erro'] == true) return null;
      return {
        'logradouro': data['logradouro'],
        'bairro': data['bairro'],
        'cidade': data['localidade'],
        'estado': data['uf'],
      };
    }
    return null;
  }
}
