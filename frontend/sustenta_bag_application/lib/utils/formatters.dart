import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    final numbers = text.replaceAll(RegExp(r'[^0-9]'), '');

    final limitedNumbers =
        numbers.length > 11 ? numbers.substring(0, 11) : numbers;

    String formatted = '';
    for (int i = 0; i < limitedNumbers.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      } else if (i == 9) {
        formatted += '-';
      }
      formatted += limitedNumbers[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

