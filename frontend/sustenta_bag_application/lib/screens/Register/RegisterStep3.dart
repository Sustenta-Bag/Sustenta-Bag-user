import 'package:flutter/material.dart';
import '../../utils/auth_service.dart';
import '../../utils/estados_brasil.dart';

class RegisterStep3 extends StatefulWidget {
  const RegisterStep3({super.key});

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final _formKey = GlobalKey<FormState>();
  final _bairroController = TextEditingController();
  String? _estadoSelecionado;
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController();

  Map<String, dynamic> userData = {};
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userData = args;

      _bairroController.text = userData['bairro'] ?? '';
      _estadoSelecionado = userData['estado'] ?? 'PE';
      _cidadeController.text = userData['cidade'] ?? '';
    }
  }

  @override
  void dispose() {
    _bairroController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _finalizarCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final dadosCompletos = {
          ...userData,
          'bairro': _bairroController.text,
          'estado': _estadoSelecionado,
          'complemento': _complementoController.text,
          'cidade': _cidadeController.text,
        };

        final payload = {
          "entityType": "client",
          "userData": {
            "email": dadosCompletos["email"],
            "password": dadosCompletos["password"]
          },
          "entityData": {
            "name": dadosCompletos["nome"],
            "cpf": retirarRegex(dadosCompletos["cpf"]),
            "phone": retirarRegex(dadosCompletos["telefone"]),
            "idAddress": {
              "zipCode": retirarRegex(dadosCompletos["cep"]),
              "state": dadosCompletos["estado"],
              "city": dadosCompletos["cidade"],
              "street": dadosCompletos["rua"],
              "number": dadosCompletos["numero"],
              "complement": dadosCompletos["complemento"]
            },
            "status": 1
          }
        };

        print("Payload: $payload");

        final result = await AuthService.register(payload);

        if (result != null && result['error'] == null) {
          final loginResult = await AuthService.login(
              dadosCompletos["email"], dadosCompletos["password"]);

          if (loginResult != null && loginResult['error'] == null) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(loginResult?['error'] ??
                      'Erro ao fazer login automático')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result?['error'] ?? 'Erro ao registrar')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
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

  String retirarRegex(String telefone) {
    return telefone.replaceAll(RegExp(r'[^0-9]'), '');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                      _buildDropdownField(),
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
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

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estado",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado?.isNotEmpty == true
              ? _estadoSelecionado
              : null,
          hint: const Text("Selecione um estado"),
          decoration: InputDecoration(
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
          items: EstadosBrasil.getDropdownItems(),
          onChanged: (String? newValue) {
            setState(() {
              print("Estado selecionado: $newValue");
              _estadoSelecionado = newValue;
              userData['estado'] = newValue;
              print("Estado selecionado atualizado: $_estadoSelecionado");
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Estado é obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }
}
