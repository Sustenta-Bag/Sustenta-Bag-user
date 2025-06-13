import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/address_service.dart';
import '../../utils/estados_brasil.dart';

class EditUserStep2 extends StatefulWidget {
  const EditUserStep2({Key? key}) : super(key: key);

  @override
  _EditUserStep2State createState() => _EditUserStep2State();
}

class _EditUserStep2State extends State<EditUserStep2> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController();
  String? _estadoSelecionado;
  bool _isLoading = false;

  late String _idAddress;
  late String _token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _idAddress = args['idAddress'] as String;
    _token = args['token'] as String;

    _cepController.text = args['cep'] ?? '';
    _ruaController.text = args['rua'] ?? '';
    _numeroController.text = args['numero']?.toString() ?? '';
    _complementoController.text = args['complemento'] ?? '';
    _cidadeController.text = args['cidade'] ?? '';
    _estadoSelecionado = args['estado'] ?? '';
  }

  @override
  void dispose() {
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvarEndereco() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final payload = {
      'zipCode': _cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      'street': _ruaController.text,
      'number': _numeroController.text,
      'complement': _complementoController.text,
      'city': _cidadeController.text,
      'state': _estadoSelecionado,
    };

    final success =
        await AddressService.updateAddress(_idAddress, payload, _token);

    setState(() => _isLoading = false);

    if (success != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endereço atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar endereço'),
          backgroundColor: Colors.red,
        ),
      );
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
          'Editar Endereço',
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
                    _buildField(
                      controller: _cepController,
                      label: 'CEP',
                      hint: '00000-000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'CEP é obrigatório' : null,
                    ),
                    const SizedBox(height: 30),
                    _buildField(
                      controller: _ruaController,
                      label: 'Rua',
                      hint: 'Nome da rua',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Rua é obrigatória' : null,
                    ),
                    const SizedBox(height: 30),
                    _buildField(
                      controller: _numeroController,
                      label: 'Número',
                      hint: '123',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Número é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    _buildField(
                      controller: _complementoController,
                      label: 'Complemento',
                      hint: 'Apto, Bloco, etc.',
                    ),
                    const SizedBox(height: 30),
                    _buildField(
                      controller: _cidadeController,
                      label: 'Cidade',
                      hint: 'Cidade',
                      validator: (v) => v == null || v.isEmpty
                          ? 'Cidade é obrigatória'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    _buildDropdown(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _salvarEndereco,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8514C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Salvar Endereço',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado,
          items: EstadosBrasil.getDropdownItems(),
          onChanged: (v) => setState(() => _estadoSelecionado = v),
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
          validator: (v) =>
              v == null || v.isEmpty ? 'Estado é obrigatório' : null,
        ),
      ],
    );
  }
}
