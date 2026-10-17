/// Validadores customizados para formulários
class CustomValidators {
  /// Valida nome de usuário
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome de usuário é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome de usuário deve ter no mínimo 3 caracteres';
    }
    if (value.length > 20) {
      return 'Nome de usuário deve ter no máximo 20 caracteres';
    }
    return null;
  }

  /// Valida senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Valida CPF/CNPJ
  static String? validateCpfCnpj(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF/CNPJ é obrigatório';
    }

    // Remove caracteres não numéricos
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length != 11 && numbers.length != 14) {
      return 'CPF/CNPJ inválido';
    }

    return null;
  }

  /// Valida telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Telefone é opcional
    }

    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length < 10 || numbers.length > 11) {
      return 'Telefone inválido';
    }

    return null;
  }

  /// Valida campo obrigatório
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }
}
