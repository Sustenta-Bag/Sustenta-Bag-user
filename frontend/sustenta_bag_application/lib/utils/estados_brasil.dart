import 'package:flutter/material.dart';

class EstadosBrasil {
  static const Map<String, String> estados = {
    'Acre': 'AC',
    'Alagoas': 'AL',
    'Amapá': 'AP',
    'Amazonas': 'AM',
    'Bahia': 'BA',
    'Ceará': 'CE',
    'Distrito Federal': 'DF',
    'Espírito Santo': 'ES',
    'Goiás': 'GO',
    'Maranhão': 'MA',
    'Mato Grosso': 'MT',
    'Mato Grosso do Sul': 'MS',
    'Minas Gerais': 'MG',
    'Pará': 'PA',
    'Paraíba': 'PB',
    'Paraná': 'PR',
    'Pernambuco': 'PE',
    'Piauí': 'PI',
    'Rio de Janeiro': 'RJ',
    'Rio Grande do Norte': 'RN',
    'Rio Grande do Sul': 'RS',
    'Rondônia': 'RO',
    'Roraima': 'RR',
    'Santa Catarina': 'SC',
    'São Paulo': 'SP',
    'Sergipe': 'SE',
    'Tocantins': 'TO',
  };  static List<DropdownMenuItem<String>> getDropdownItems() {
    return estados.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.value, 
        child: Text('${entry.key} (${entry.value})'),
      );
    }).toList();
  }  static String? getEstadoNome(String uf) {
    return estados.entries
        .where((entry) => entry.value == uf.toUpperCase())
        .map((entry) => entry.key)
        .firstOrNull;
  }
}
