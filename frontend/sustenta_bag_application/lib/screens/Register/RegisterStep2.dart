import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sustenta_bag_application/utils/cep_service.dart';
import 'package:sustenta_bag_application/utils/validators.dart';

class RegisterStep2 extends StatefulWidget {
  const RegisterStep2({super.key});

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final _formKey = GlobalKey<FormState>();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _cepFocusNode = FocusNode();

  Map<String, dynamic> userData = {};
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      userData = args;
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
    _telefoneController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _cepFocusNode.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text;

    if (Validators.validateCep(cep) != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final endereco = await CepService.buscarEndereco(cep);      if (endereco != null) {
        setState(() {
          _ruaController.text = endereco['logradouro'] ?? '';
          userData['bairro'] = endereco['bairro'] ?? '';
          userData['cidade'] = endereco['cidade'] ?? '';
          userData['estado'] = endereco['estado'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar CEP')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                        controller: _telefoneController,
                        label: "Celular",
                        hint: "(99) 99999-9999",
                        validator: Validators.validateTelefone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _TelefoneInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                                FilteringTextInputFormatter.digitsOnly,
                                _CepInputFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _buscarCep,
                            icon: const Icon(Icons.search),
                            tooltip: 'Buscar CEP',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildTextFormField(
                        controller: _ruaController,
                        label: "Rua",
                        hint: "Nome da rua",
                        validator: Validators.validateNome,
                      ),
                      const SizedBox(height: 30),
                      _buildTextFormField(
                        controller: _numeroController,
                        label: "Número",
                        hint: "123",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Número é obrigatório';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              userData['telefone'] = _telefoneController.text;
                              userData['cep'] = _cepController.text;
                              userData['rua'] = _ruaController.text;
                              userData['numero'] = _numeroController.text;

                              Navigator.pushNamed(
                                context,
                                '/register3',
                                arguments: userData,
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      )
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
    required String? Function(String?) validator,
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

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    var formattedText = '';
    for (var i = 0; i < text.length; i++) {
      formattedText += text[i];
      if (i == 4 && i < text.length - 1) {
        formattedText += '-';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    text = text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    var formattedText = '';
    for (var i = 0; i < text.length; i++) {
      if (i == 0) {
        formattedText += '(';
      }
      formattedText += text[i];
      if (i == 1 && text.length > 2) {
        formattedText += ') ';
      } else if ((i == 6 && text.length > 7) || (i == 7 && text.length <= 10)) {
        formattedText += '-';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
