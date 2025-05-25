class Validators {
  static String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
    if (value.trim().length < 3) return 'Nome muito curto';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email é obrigatório';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? validateSenha(String? value) {
    if (value == null || value.length < 6)
      return 'Senha deve ter no mínimo 6 caracteres';
    return null;
  }

  static String? validateConfirmarSenha(String? senha, String? confirmarSenha) {
    if (senha != confirmarSenha) return 'As senhas não coincidem';
    return null;
  }

  static String? validateCep(String? value) {
    if (value == null || value.trim().isEmpty) return 'CEP é obrigatório';
    final regex = RegExp(r'^\d{5}-?\d{3}$');
    if (!regex.hasMatch(value)) return 'CEP inválido';
    return null;
  }

  static String? validateTelefone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Celular é obrigatório';
    final regex = RegExp(r'^\(\d{2}\)\s?\d{4,5}-\d{4}$');
    if (!regex.hasMatch(value)) return 'Celular inválido';
    return null;
  }

  static String? validateCpf(String? value) {
    if (value == null || value.trim().isEmpty) return 'CPF é obrigatório';

    // Remove pontos e traços
    String cpf = value.replaceAll(RegExp(r'[.-]'), '');

    // Verifica se tem 11 dígitos
    if (cpf.length != 11) return 'CPF deve ter 11 dígitos';

    // TODO : DESCOMENTAR ESSE CÓDIGO QUANDO SUBIR PARA PRODUÇÃO
    // // Verifica se todos os dígitos são iguais
    // if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return 'CPF inválido';

    // // Validação do primeiro dígito verificador
    // int soma = 0;
    // for (int i = 0; i < 9; i++) {
    //   soma += int.parse(cpf[i]) * (10 - i);
    // }
    // int primeiroDigito = (soma * 10) % 11;
    // if (primeiroDigito == 10) primeiroDigito = 0;

    // if (primeiroDigito != int.parse(cpf[9])) return 'CPF inválido';

    // // Validação do segundo dígito verificador
    // soma = 0;
    // for (int i = 0; i < 10; i++) {
    //   soma += int.parse(cpf[i]) * (11 - i);
    // }
    // int segundoDigito = (soma * 10) % 11;
    // if (segundoDigito == 10) segundoDigito = 0;

    // if (segundoDigito != int.parse(cpf[10])) return 'CPF inválido';

    return null;
  }
}
