import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../utils/auth_service.dart';
import '../utils/database_helper.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  bool _isLoading = true;
  Address? _address;
  String? _token;
  Map<String, dynamic> jsonData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar token
      _token = await DatabaseHelper.instance.getToken();
      if (_token == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Carregar dados do usuário
      final userData = await AuthService.getCurrentUser();
      if (userData == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        jsonData = userData;
      });

      final address = await AddressService.getAddress(
          jsonData["entity"]["idAddress"].toString(), _token!);
      if (mounted) {
        setState(() {
          _address = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editPersonalData() {
    Navigator.pushNamed(
      context,
      '/edit_step1',
      arguments: {
        'nome': jsonData["entity"]["name"],
        'cpf': jsonData["entity"]["cpf"],
        'email': jsonData["entity"]["email"],
        'telefone': jsonData["entity"]["phone"],
      },
    );
  }

  void _editAddressData() {
    Navigator.pushNamed(
      context,
      '/edit_step2',
      arguments: {
        'cep': _address?.zipCode,
        'rua': _address?.street,
        'numero': _address?.number,
        'complemento': _address?.complement,
        'cidade': _address?.city,
        'estado': _address?.state,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meus Dados',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE8514C),
                    child: Text(
                      (jsonData["entity"]["name"] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jsonData["entity"]["name"] ?? 'Usuário',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          jsonData["entity"]["email"] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDataSection(
              title: 'Dados Pessoais',
              icon: Icons.person,
              onEdit: _editPersonalData,
              children: [
                _buildInfoRow('Nome', jsonData["entity"]["name"] ?? 'N/A'),
                _buildInfoRow(
                    'CPF', _formatCpf(jsonData["entity"]["cpf"] ?? 'N/A')),
                _buildInfoRow('Telefone',
                    _formatPhone(jsonData["entity"]["phone"] ?? 'N/A')),
                _buildInfoRow('Email', jsonData["entity"]["email"] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 24),
            _buildDataSection(
              title: 'Endereço',
              icon: Icons.location_on,
              onEdit: _editAddressData,
              children: [
                _buildInfoRow('CEP', _formatCep(_address?.zipCode ?? 'N/A')),
                _buildInfoRow('Rua', _address?.street ?? 'N/A'),
                _buildInfoRow('Número', _address?.number ?? 'N/A'),
                _buildInfoRow('Complemento', _address?.complement ?? 'N/A'),
                _buildInfoRow('Cidade', _address?.city ?? 'N/A'),
                _buildInfoRow('Estado', _address?.state ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header da seção
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  child: Icon(
                    icon,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo da seção
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCpf(String cpf) {
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }

  String _formatPhone(String phone) {
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  String _formatCep(String cep) {
    if (cep.length == 8) {
      return '${cep.substring(0, 5)}-${cep.substring(5)}';
    }
    return cep;
  }
}
