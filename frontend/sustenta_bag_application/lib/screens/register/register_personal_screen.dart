import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sustenta_bag_application/utils/validators.dart';
import 'package:sustenta_bag_application/utils/formatters.dart';

class RegisterPersonalScreen extends StatefulWidget {
  const RegisterPersonalScreen({super.key});

  @override
  State<RegisterPersonalScreen> createState() => _RegisterPersonalScreenState();
}

class _RegisterPersonalScreenState extends State<RegisterPersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _prosseguir() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        '/register-address',
        arguments: {
          'nome': _nomeController.text,
          'cpf': _cpfController.text,
          'telefone': _phoneMaskFormatter.getUnmaskedText(),
          // Passa o número limpo
          'email': _emailController.text,
          'password': _senhaController.text,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Dados Pessoais",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextFormField(
                  controller: _nomeController,
                  label: "Nome",
                  hint: "Seu nome completo",
                  validator: Validators.validateNome,
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _cpfController,
                  label: "CPF",
                  hint: "000.000.000-00",
                  validator: Validators.validateCpf,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CpfInputFormatter()],
                ),
                const SizedBox(height: 24),

                _buildTextFormField(
                  controller: _telefoneController,
                  label: "Celular",
                  hint: "(99) 99999-9999",
                  validator: (value) {
                    if (value == null || value.length < 15) {
                      return 'Celular inválido';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMaskFormatter],
                ),

                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _emailController,
                  label: "Email",
                  hint: "email@exemplo.com",
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _senhaController,
                  label: "Senha",
                  hint: "Crie uma senha",
                  isPassword: true,
                  validator: Validators.validateSenha,
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _confirmarSenhaController,
                  label: "Confirmar Senha",
                  hint: "Repita a senha",
                  isPassword: true,
                  validator: (value) => Validators.validateConfirmarSenha(
                      _senhaController.text, value),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _prosseguir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8514C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Prosseguir",
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
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
