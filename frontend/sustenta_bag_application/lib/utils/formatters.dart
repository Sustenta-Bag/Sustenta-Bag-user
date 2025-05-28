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

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text =
        newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }


    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    var newText = StringBuffer();
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;

    if (text.length >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1 && oldValue.text.isEmpty) {
        selectionIndex++;
      }
    }

    if (text.length >= 3) {
      newText.write(text.substring(usedSubstringIndex, 2));
      newText.write(') ');
      usedSubstringIndex = 2;
      if (newValue.selection.end >= 2 && oldValue.text.length <= 3) {
        selectionIndex += 2;
      }
    } else if (text.length > usedSubstringIndex) {
      newText.write(text.substring(usedSubstringIndex));
    }

    if (text.length >= 8 && text.length <= 10) {
      newText.write(text.substring(usedSubstringIndex, text.length - 4));
      newText.write('-');
      newText.write(text.substring(text.length - 4));
      if (newValue.selection.end >= (text.length - 4) &&
          oldValue.text.length <= (newText.length - 1 - 1)) {
        selectionIndex++;
      }
    } else if (text.length == 11) {
      newText.write(text.substring(usedSubstringIndex, 7));
      newText.write('-');
      newText.write(text.substring(7));
      if (newValue.selection.end >= 7 &&
          oldValue.text.length <= (newText.length - 1 - 1)) {
        selectionIndex++;
      }
    } else if (text.length > usedSubstringIndex) {
      newText.write(text.substring(usedSubstringIndex));
    }
    selectionIndex = selectionIndex.clamp(0, newText.length);

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
