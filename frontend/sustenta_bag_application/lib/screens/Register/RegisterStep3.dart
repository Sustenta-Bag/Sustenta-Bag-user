import 'package:flutter/material.dart';

class RegisterStep3 extends StatefulWidget {
  const RegisterStep3({super.key});

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final _formKey = GlobalKey<FormState>();
  final _bairroController = TextEditingController();
  final _estadoController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController();

  Map<String, dynamic> userData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userData = args;

      _bairroController.text = userData['bairro'] ?? '';
      _estadoController.text = userData['estado'] ?? '';
      _cidadeController.text = userData['cidade'] ?? '';
    }
  }

  @override
  void dispose() {
    _bairroController.dispose();
    _estadoController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _finalizarCadastro() {
    if (_formKey.currentState!.validate()) {
      final dadosCompletos = {
        ...userData,
        'bairro': _bairroController.text,
        'estado': _estadoController.text,
        'complemento': _complementoController.text,
        'cidade': _cidadeController.text,
      };

      // Usar os dados do cadastro (exemplo para resolver warning)
      print('Cadastro finalizado com os dados: $dadosCompletos');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Crie sua Conta",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(
                  controller: _bairroController,
                  label: "Bairro",
                  hint: "Nome do bairro",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bairro é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _buildTextFormField(
                  controller: _estadoController,
                  label: "Estado",
                  hint: "UF",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Estado é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _buildTextFormField(
                  controller: _complementoController,
                  label: "Complemento",
                  hint: "Casa, Apto, etc.",
                  validator: null,
                ),
                const SizedBox(height: 30),
                _buildTextFormField(
                  controller: _cidadeController,
                  label: "Cidade",
                  hint: "Nome da cidade",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cidade é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _finalizarCadastro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8514C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Criar Conta",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
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
