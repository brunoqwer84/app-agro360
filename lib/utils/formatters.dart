import 'package:intl/intl.dart';

/// Formatadores de dados
class Formatters {
  /// Formata data para exibição (dd/MM/yyyy)
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formata data e hora para exibição (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Formata apenas hora (HH:mm)
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formata CPF (000.000.000-00)
  static String formatCpf(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 11) return cpf;

    return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
  }

  /// Formata CNPJ (00.000.000/0000-00)
  static String formatCnpj(String cnpj) {
    final numbers = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 14) return cnpj;

    return '${numbers.substring(0, 2)}.${numbers.substring(2, 5)}.${numbers.substring(5, 8)}/${numbers.substring(8, 12)}-${numbers.substring(12)}';
  }

  /// Formata CPF ou CNPJ automaticamente
  static String formatCpfCnpj(String value) {
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 11) {
      return formatCpf(numbers);
    } else if (numbers.length == 14) {
      return formatCnpj(numbers);
    }

    return value;
  }

  /// Formata telefone ((00) 00000-0000 ou (00) 0000-0000)
  static String formatPhone(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    }

    return phone;
  }

  /// Formata peso em kg (00.0 kg)
  static String formatWeight(double? weight) {
    if (weight == null) return '-';
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// Formata moeda brasileira (R$ 0.000,00)
  static String formatCurrency(double? value) {
    if (value == null) return 'R\$ 0,00';
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }
}
