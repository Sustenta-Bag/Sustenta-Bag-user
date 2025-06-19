import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sustenta_bag_application/utils/validators.dart';
import 'package:sustenta_bag_application/services/client_service.dart';

import '../../utils/formatters.dart';

class EditUserStep1 extends StatefulWidget {
  const EditUserStep1({super.key});

  @override
  State<EditUserStep1> createState() => _EditUserStep1State();
}

class _EditUserStep1State extends State<EditUserStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  Map<String, dynamic> userData = {};
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userData = args;


      _nomeController.text = userData['nome'] ?? '';
      _cpfController.text = _formatCpf(userData['cpf'] ?? '');
      _emailController.text = userData['email'] ?? '';
      _telefoneController.text = _formatPhone(userData['telefone'] ?? '');
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  String _formatCpf(String cpf) {
    if (cpf.replaceAll(RegExp(r'[^0-9]'), '').length == 11) {
      final digitsOnly = cpf.replaceAll(RegExp(r'[^0-9]'), '');
      return '${digitsOnly.substring(0, 3)}.${digitsOnly.substring(3, 6)}.${digitsOnly.substring(6, 9)}-${digitsOnly.substring(9)}';
    }
    return cpf;
  }

  String _formatPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length == 11) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    } else if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
    }
    return phone;
  }

  String _removeFormatting(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String id = userData['id']?.toString() ?? '';
        final String token = userData['token']?.toString() ?? '';

        if (id.isEmpty || token.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Erro: ID do usuário ou token não fornecido para atualização.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        final dadosAtualizados = {
          'name': _nomeController.text,
          'cpf': _removeFormatting(_cpfController.text),
          'email': _emailController.text,
          'phone': _removeFormatting(_telefoneController.text),
        };


        final updatedClient =
            await ClientService.updateClient(id, dadosAtualizados, token);

        if (updatedClient != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados pessoais atualizados com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Erro ao atualizar dados pessoais. Verifique os dados ou tente mais tarde.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Editar Dados Pessoais",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildTextFormField(
                      controller: _nomeController,
                      label: "Nome",
                      hint: "Seu nome completo",
                      validator: Validators.validateNome,
                    ),
                    const SizedBox(height: 30),
                    _buildTextFormField(
                      controller: _cpfController,
                      label: "CPF",
                      hint: "000.000.000-00",
                      validator: Validators.validateCpf,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                      enabled: false,
                    ),
                    const SizedBox(height: 30),
                    _buildTextFormField(
                      controller: _emailController,
                      label: "Email",
                      hint: "email@exemplo.com",
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 30),
                    _buildTextFormField(
                      controller: _telefoneController,
                      label: "Telefone",
                      hint: "(99) 99999-9999",
                      validator: Validators.validateTelefone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _salvarAlteracoes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8514C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Salvar Alterações",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? const Color(0xFFF2F2F2) : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}


