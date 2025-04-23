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
}
