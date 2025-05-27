import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../utils/api_config.dart';
import 'address_service.dart';

class BusinessService {
  static const String baseUrl = ApiConfig.baseUrl;

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

  static Future<List<BusinessData>> getAllBusinesses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BusinessData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar empresas: $e');
      return [];
    }
  }

  static Future<List<BusinessData>> getActiveBusinesses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BusinessData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar empresas ativas: $e');
      return [];
    }
  }
}
