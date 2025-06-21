import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get monolitoBaseUrl => dotenv.env['API_MONOLITO_BASE_URL'] ?? 'http://localhost:4041/api';
  static String get monolitoStaticUrl => dotenv.env['API_MONOLITO_STATIC_URL'] ?? 'http://localhost:4041';
  static String get paymentBaseUrl => dotenv.env['API_PAYMENT_BASE_URL'] ?? 'http://localhost:3001/api';
}
