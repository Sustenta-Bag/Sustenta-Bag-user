import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/client.dart';
import 'api_config.dart';
import 'database_helper.dart';
import 'firebase_messaging_service.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Login method
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        print("entrou");
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Converter dados para modelos
       // final user = User.fromJson(data['user']);
        //final entity = data['entity'] != null ? Client.fromJson(data['entity']) : null;
        
        // Save entity data to local database

        await DatabaseHelper.instance.saveUser(data['user']);
        await DatabaseHelper.instance.saveEntity(data['entity']);
        
        // Save token to local database
        await DatabaseHelper.instance.saveToken(data['token']);
        
        print("token: ${data['token']}");
        // Registrar token FCM
        try {
          await FirebaseMessagingService.sendFCMTokenToServer();
        } catch (fcmError) {
          if (kDebugMode) {
            print('Erro ao registrar token FCM: $fcmError');
          }
        }
        
        return data;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['message'] ?? 'Falha no login'};
      }
    } catch (e) {
      return {'error': 'Erro de rede: ${e.toString()}'};
    }
  }

  // Registro de novo usuário
  static Future<Map<String, dynamic>?> register(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['message'] ?? 'Falha no registro'};
      }
    } catch (e) {
      return {'error': 'Erro de rede: ${e.toString()}'};
    }
  }

  // Alterar senha
  static Future<bool> changePassword(String currentPassword, String newPassword, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      
      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao alterar senha: $e');
      return false;
    }
  }
  
  // Verificar se usuário está logado
  static Future<bool> isLoggedIn() async {
    final token = await DatabaseHelper.instance.getToken();
    return token != null;
  }
  
  // Obter usuário atual
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final userJson = await DatabaseHelper.instance.getUser();
    final entityJson = await DatabaseHelper.instance.getEntity();
    if (userJson != null) {
      return {
        'user': userJson,
        'entity': entityJson,
      };
    }
    
    return null;
  }
  
  // Logout
  static Future<void> logout() async {
    await DatabaseHelper.instance.clearAllData();
  }
}
