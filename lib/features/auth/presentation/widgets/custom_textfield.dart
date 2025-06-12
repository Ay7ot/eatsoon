import 'package:flutter/material.dart';
import 'package:eat_soon/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                focusNode?.hasFocus == true
                    ? AppTheme.secondaryColor.withOpacity(0.2)
                    : Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        focusNode: focusNode,
        style: AppTheme.bodyStyle,
        decoration: AppTheme.textFieldDecoration(
          hintText,
          suffixIcon: suffixIcon,
          onSuffixIconPressed: onSuffixIconPressed,
        ),
      ),
    );
  }
}
