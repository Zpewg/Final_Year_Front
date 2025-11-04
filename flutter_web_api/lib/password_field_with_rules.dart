import 'package:flutter/material.dart';

class PasswordFieldWithRules extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const PasswordFieldWithRules({
    super.key,
    required this.controller,
    this.label = "Password",
  });

  @override
  State<PasswordFieldWithRules> createState() => _PasswordFieldWithRulesState();
}

class _PasswordFieldWithRulesState extends State<PasswordFieldWithRules> {
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasSpecialChar = false;
  bool hasValidLength = false;

  void _checkPassword(String password) {
    setState(() {
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      hasValidLength = password.length >= 8 && password.length <= 16;
    });
  }

  Widget _buildRequirement(bool condition, String text) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_circle : Icons.cancel,
          color: condition ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
              color: condition ? Colors.green : Colors.red,
              fontSize: 14,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: true,
          onChanged: _checkPassword,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ??
                theme.colorScheme.surface,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Password is required";
            }
            if (!(hasUppercase &&
                hasLowercase &&
                hasSpecialChar &&
                hasValidLength)) {
              return "Password does not meet the requirements";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        _buildRequirement(hasValidLength, "8–16 characters"),
        _buildRequirement(hasLowercase, "At least one lowercase letter"),
        _buildRequirement(hasUppercase, "At least one uppercase letter"),
        _buildRequirement(hasSpecialChar, "At least one special character"),
      ],
    );
  }
}
