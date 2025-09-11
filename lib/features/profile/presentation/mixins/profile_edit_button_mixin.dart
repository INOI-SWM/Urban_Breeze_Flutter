import 'package:flutter/material.dart';

mixin ProfileEditButtonMixin<T extends StatefulWidget> on State<T> {
  bool _isButtonEnabled = false;

  bool get isButtonEnabled => _isButtonEnabled;

  String get currentValue;
  String? getCurrentInputValue();
  bool isValidInput(String? inputValue);
  Future<void> onSave();

  void checkButtonState() {
    final String? inputValue = getCurrentInputValue();
    final bool shouldEnable =
        isValidInput(inputValue) && inputValue != currentValue;

    if (_isButtonEnabled != shouldEnable) {
      setState(() {
        _isButtonEnabled = shouldEnable;
      });
    }
  }

  void saveValue() {
    final String? inputValue = getCurrentInputValue();

    if (isValidInput(inputValue) && inputValue != currentValue) {
      onSave();
    }
  }
}
