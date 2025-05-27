import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/address.dart';
import '../models/user.dart';
import '../services/client_service.dart';
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

    print("Carregando dados do usuário...");

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

      print(jsonData["entity"]["idAddress"]);
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
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirmar Saída'),
          content: const Text('Tem certeza que deseja sair do aplicativo?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
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
  }

  void _showFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidade de Favoritos em desenvolvimento')),
    );
  }

  void _goToUserData() {
    Navigator.pushNamed(context, '/user_data');
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidade de Edição em desenvolvimento')),
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE8514C),
                      child: Text(
                        (jsonData["entity"]["name"] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      jsonData["entity"]["name"] ?? 'Usuário',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jsonData["entity"]["email"] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildMenuButton(
                icon: Icons.favorite,
                title: 'Favoritos',
                subtitle: 'Seus itens favoritos',
                onTap: _showFavorites,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                icon: Icons.person,
                title: 'Meus Dados',
                subtitle: 'Visualizar e editar informações pessoais',
                onTap: _goToUserData,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                icon: Icons.exit_to_app,
                title: 'Sair do Aplicativo',
                subtitle: 'Fazer logout da conta',
                onTap: _logout,
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildSection(String title, List<Widget> children) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20.0),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
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
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
