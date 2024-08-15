import 'package:flutter/widgets.dart';

class InputFieldModel {
  final void Function(String)? onChange;
  String error;
  final String label;
  final String placeholder;
  final TextInputType inputType;

  InputFieldModel(
      {this.onChange,
      this.error = '',
      this.placeholder = '',
      this.inputType = TextInputType.text,
      this.label = ''});
}
