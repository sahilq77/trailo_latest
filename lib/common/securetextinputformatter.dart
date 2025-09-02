import 'package:flutter/services.dart';

class SecureTextInputFormatter extends TextInputFormatter {
  // Regular expression to match script tags and leading whitespace
  static final RegExp _deniedPattern = RegExp(
    r'(<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>|^[\s]+)',
    caseSensitive: false,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new input matches the denied pattern, reject it
    if (_deniedPattern.hasMatch(newValue.text)) {
      return oldValue; // Return old value to prevent update
    }
    return newValue; // Allow the input if it passes the check
  }

  // Static method for easy usage like FilteringTextInputFormatter.deny
  static TextInputFormatter deny() {
    return SecureTextInputFormatter();
  }
  
}
