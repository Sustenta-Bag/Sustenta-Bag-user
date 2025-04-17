import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sustenta_bag_application/utils/validators.dart';

class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({super.key});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
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
          "Crie sua Conta",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        elevation: 0,
      ),
      body: Padding(
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
                controller: _emailController,
                label: "Email",
                hint: "email@exemplo.com",
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              _buildTextFormField(
                controller: _senhaController,
                label: "Senha",
                hint: "Crie uma senha",
                isPassword: true,
                validator: Validators.validateSenha,
              ),
              const SizedBox(height: 30),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(
                        context,
                        '/register2',
                        arguments: {
                          'nome': _nomeController.text,
                          'email': _emailController.text,
                          'senha': _senhaController.text,
                        },
                      );
                    }
                  },
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
