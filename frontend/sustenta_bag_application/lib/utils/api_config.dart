class ApiConfig {
  // Use 10.0.2.2 para emulador Android e localhost para iOS
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Headers padrão para requisições
  static Map<String, String> getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
} 