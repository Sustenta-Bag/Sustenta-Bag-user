import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'firebase_messaging_service.dart';

class AuthService {
  // Use 10.0.2.2 instead of localhost for Android emulators
  // For iOS simulator, localhost should work fine
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Login method
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Save user data to local database
        await DatabaseHelper.instance.saveUser(data['user']);
        
        // Save entity data to local database
        await DatabaseHelper.instance.saveEntity(data['entity']);
        
        // Save token to local database
        await DatabaseHelper.instance.saveToken(data['token']);
        
        // Tentar registrar o token FCM automaticamente após o login
        try {
          await FirebaseMessagingService.sendFCMTokenToServer();
        } catch (fcmError) {
          if (kDebugMode) {
            print('Erro ao registrar token FCM automaticamente: $fcmError');
          }
          // Não impede o login se o registro do FCM falhar
        }
        
        return data;
      } else {
        // Handle error responses
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['message'] ?? 'Failed to login'};
      }
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await DatabaseHelper.instance.getToken();
    return token != null;
  }
  
  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = await DatabaseHelper.instance.getUser();
    final entity = await DatabaseHelper.instance.getEntity();
    
    if (user != null && entity != null) {
      return {
        'user': user,
        'entity': entity,
      };
    }
    
    return null;
  }
  
  // Logout method
  static Future<void> logout() async {
    await DatabaseHelper.instance.clearAllData();
  }
}
