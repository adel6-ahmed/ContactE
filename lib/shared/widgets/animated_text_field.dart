import 'package:flutter/material.dart';

class AnimatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isHidden;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onToggleVisibility;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isHidden = true,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: isPassword && isHidden,
        style: TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isHidden ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.amber, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}