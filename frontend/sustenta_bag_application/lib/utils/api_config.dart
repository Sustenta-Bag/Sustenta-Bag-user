import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Use variáveis de ambiente para configurar as URLs base
  static String get baseUrl => dotenv.env['API_MONOLITO_BASE_URL'] ?? 'http://10.0.2.2:4041/api';

  // Headers padrão para requisições
  static Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
