import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sustenta_bag_application/services/cep_service.dart';
import 'package:sustenta_bag_application/services/auth_service.dart';
import 'package:sustenta_bag_application/utils/estados_brasil.dart';
import 'package:sustenta_bag_application/utils/validators.dart';

class RegisterAddressScreen extends StatefulWidget {
  const RegisterAddressScreen({super.key});

  @override
  State<RegisterAddressScreen> createState() => _RegisterAddressScreenState();
}

class _RegisterAddressScreenState extends State<RegisterAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> personalData = {};
  bool _isLoading = false;

  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  String? _estadoSelecionado;

  final _cepFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      personalData = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _cepFocusNode.addListener(() {
      if (!_cepFocusNode.hasFocus) {
        _buscarCep();
      }
    });
  }

  @override
  void dispose() {
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _cepFocusNode.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final endereco = await CepService.buscarEndereco(cep);
      if (mounted && endereco != null) {
        setState(() {
          _ruaController.text = endereco['logradouro'] ?? '';
          _bairroController.text = endereco['bairro'] ?? '';
          _cidadeController.text = endereco['cidade'] ?? '';
          _estadoSelecionado = endereco['estado'];
        });
      } else if (mounted) {
        _showSnackBar('CEP não encontrado. Por favor, preencha manualmente.');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao buscar CEP. Verifique sua conexão.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _finalizarCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String clean(String? value) =>
          value?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') ?? '';

      final payload = {
        "entityType": "client",
        "userData": {
          "email": personalData["email"],
          "password": personalData["password"]
        },
        "entityData": {
          "name": personalData["nome"],
          "cpf": clean(personalData["cpf"]),
          "phone": clean(personalData["telefone"]),
          "idAddress": {
            "zipCode": clean(_cepController.text),
            "state": _estadoSelecionado,
            "city": _cidadeController.text,
            "street": _ruaController.text,
            "number": _numeroController.text,
            "complement": _complementoController.text.isEmpty
                ? "None"
                : _complementoController.text
          },
          "status": 1
        }
      };

      final result = await AuthService.register(payload);

      if (!mounted) return;

      if (result != null && result['error'] == null) {
        _showSnackBar('Cadastro realizado com sucesso! Fazendo login...',
            isError: false);

        final loginResult = await AuthService.login(
            personalData["email"], personalData["password"]);

        if (!mounted) return;

        if (loginResult != null && loginResult['error'] == null) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          _showSnackBar(loginResult?['error'] ??
              'Erro no login automático. Por favor, tente logar.');
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else {
        _showSnackBar(result?['error'] ?? 'Erro desconhecido ao registrar.');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Ocorreu um erro inesperado: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
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
          "Endereço",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8514C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _cepController,
                            focusNode: _cepFocusNode,
                            label: "CEP",
                            hint: "00000-000",
                            validator: Validators.validateCep,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: IconButton(
                              onPressed: _buscarCep,
                              icon: const Icon(Icons.search)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextFormField(
                            controller: _ruaController,
                            label: "Rua",
                            hint: "Nome da rua",
                            validator: (v) => v == null || v.isEmpty
                                ? 'Rua é obrigatória'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildTextFormField(
                            controller: _numeroController,
                            label: "Nº",
                            hint: "123",
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Obrigatório' : null,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _bairroController,
                      label: "Bairro",
                      hint: "Nome do bairro",
                      validator: (v) => v == null || v.isEmpty
                          ? 'Bairro é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _complementoController,
                      label: "Complemento (Opcional)",
                      hint: "Apto, Bloco, Casa...",
                      validator: null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextFormField(
                            controller: _cidadeController,
                            label: "Cidade",
                            hint: "Nome da cidade",
                            validator: (v) => v == null || v.isEmpty
                                ? 'Cidade é obrigatória'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildDropdownField()),
                      ],
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
                              borderRadius: BorderRadius.circular(10)),
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
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?)? validator,
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Estado",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado,
          hint: const Text("UF"),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          items: EstadosBrasil.getDropdownItems(),
          onChanged: (String? newValue) {
            setState(() {
              _estadoSelecionado = newValue;
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Obrigatório' : null,
        ),
      ],
    );
  }
}
