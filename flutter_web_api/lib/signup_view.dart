import 'package:flutter/material.dart';
import 'model.dart';
import 'user_service.dart';
import 'password_field_with_rules.dart';
import 'verify_message_service.dart';
import 'verification_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final UserService _userService = UserService();
  final VerifyService _verifyService = VerifyService();

  List<String> errors = [];

  Future<String?> _showVerificationDialog(BuildContext context) async {
    final TextEditingController codeController = TextEditingController();
    final theme = Theme.of(context);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "Enter Verification Code",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(
              labelText: "Verification Code",
              labelStyle: TextStyle(color: theme.colorScheme.onSurface),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onPressed: () => Navigator.pop(context, null),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context, code);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Sign Up"), centerTitle: true),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(_nameController, "Name"),
            const SizedBox(height: 16),
            _buildTextField(
              _emailController,
              "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            PasswordFieldWithRules(controller: _passwordController),
            const SizedBox(height: 16),
            _buildTextField(
              _confirmPasswordController,
              "Confirm Password",
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _phoneController,
              "Phone Number",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final user = User(
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                    phoneNumber: _phoneController.text.trim(),
                  );

                  final result = await _userService.registerUser(user);
                  setState(() {
                    errors = result;
                  });

                  if (errors.isEmpty) {
                    final code = await _showVerificationDialog(context);

                    if (code != null && code.isNotEmpty) {
                      final verifyMessage = VerifyMessage(message: code);
                      await _verifyService.registerMessage(verifyMessage);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User registered!")),
                        );
                        Navigator.pop(context); // Go back to FrontPage
                      }
                    }
                  } else {
                    // Show popup with errors
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Registration Errors"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: errors.length,
                              itemBuilder: (context, int index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    "• ${errors[index]}",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "CREATE ACCOUNT",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor:
            theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
      ),
      style: TextStyle(color: theme.colorScheme.onSurface),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        if (label == "Confirm Password" && value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
