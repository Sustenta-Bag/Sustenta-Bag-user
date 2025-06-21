import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../utils/api_config.dart';
import 'address_service.dart';

class BusinessService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<BusinessData>> searchBusinesses(String token,
      {String? query}) async {
    try {
      var uri = Uri.parse('$baseUrl/businesses');

      if (query != null && query.isNotEmpty) {
        uri = uri.replace(queryParameters: {'name': query});
      }

      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        final List<dynamic> businessList = apiResponse['data'] as List<dynamic>;

        return businessList.map((json) => BusinessData.fromJson(json)).toList();
      } else {
        print('Erro ao buscar estabelecimentos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro de rede ao buscar estabelecimentos: $e');
      return [];
    }
  }

  // MÉTODO CORRIGIDO para entender a nova estrutura da API
  static Future<List<BusinessData>> getAllBusinesses(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses'),
        headers:
            ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        final List<dynamic> data = apiResponse['data'] as List<dynamic>;

        return data.map((json) => BusinessData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar empresas: $e');
      return [];
    }
  }

  static Future<BusinessData?> getBusiness(int id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/$id'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final business = BusinessData.fromJson(data);

        final address = await AddressService.getAddress(
            business.idAddress.toString(), token);

        if (address != null) {
          return BusinessData(
            id: business.id,
            legalName: business.legalName,
            cnpj: business.cnpj,
            appName: business.appName,
            cellphone: business.cellphone,
            description: business.description,
            delivery: business.delivery,
            deliveryTax: business.deliveryTax,
            idAddress: business.idAddress,
            deliveryTime: business.deliveryTime,
            logo: business.logo,
            status: business.status,
            createdAt: business.createdAt,
            updatedAt: business.updatedAt,
            address: BusinessDataAddress(
              id: address.id ?? 0,
              zipCode: address.zipCode,
              state: address.state,
              city: address.city,
              street: address.street,
              number: address.number,
              complement: address.complement,
            ),
          );
        }

        return business;
      } else {
        print(
            'Erro ao buscar empresa: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar empresa: $e');
      return null;
    }
  }
}
