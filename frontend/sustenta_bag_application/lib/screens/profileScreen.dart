import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../utils/auth_service.dart';
import '../utils/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Future<void> _logout() async {
    try {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer logout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Dados Pessoais',
              [
                _buildInfoRow('Nome', jsonData["entity"]["name"] ?? 'N/A'),
                _buildInfoRow('CPF', jsonData["entity"]["cpf"] ?? 'N/A'),
                _buildInfoRow('Telefone', jsonData["entity"]["phone"] ?? 'N/A'),
                _buildInfoRow('Email', jsonData["entity"]["email"] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Endereço',
              [
                _buildInfoRow('CEP', _address?.zipCode ?? 'N/A'),
                _buildInfoRow('Rua', _address?.street ?? 'N/A'),
                _buildInfoRow('Número', _address?.number ?? 'N/A'),
                _buildInfoRow('Complemento', _address?.complement ?? 'N/A'),
                _buildInfoRow('Bairro', 'N/A'),
                _buildInfoRow('Cidade', _address?.city ?? 'N/A'),
                _buildInfoRow('Estado', _address?.state ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar edição de perfil
                },
                child: const Text('Editar Perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
