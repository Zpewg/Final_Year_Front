import 'package:flutter/material.dart';
import '../model/login_model.dart';
import '../API/login_service.dart';
import '../model/model.dart'; // Imports User class
import '../model/verification_model.dart'; // Imports VerifyMessage class
import '../API/verify_message_service.dart'; // Imports VerifyService class
import '../theme/theme_controller.dart';
import 'user_page.dart';

import '../model/new_password_from_user_model.dart';
import '../API/change_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Services
  final LoginService _loginService = LoginService();
  final VerifyService _verifyService = VerifyService();
  final ChangePasswordService _changePassService =
      ChangePasswordService(); // New Service

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOGIN LOGIC
  // ==========================================
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final login = Login(
      mail: _emailController.text.trim(),
      password: _passwordController.text,
    );

    try {
      final User? user = await _loginService.logInUser(login);

      setState(() => _isLoading = false);

      if (user != null) {
        print("✅ Logged in User: ${user.toJson()}");

        if (user.active) {
          // --- USER ACTIVE: GO TO USER PAGE ---
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserPage(user: user)),
            );
          }
        } else {
          // --- USER INACTIVE: SHOW VERIFICATION POPUP ---
          if (mounted) {
            _showVerificationDialog(context, _emailController.text.trim());
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid email or password")),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("🚨 Login exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
    }
  }

  // ==========================================
  // INACTIVE ACCOUNT VERIFICATION DIALOG
  // ==========================================
  void _showVerificationDialog(BuildContext context, String userMail) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Account Not Active"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Your account is inactive. Please enter the verification code.",
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: "Verification Code",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isEmpty) return;

                final message = VerifyMessage(
                  message: code,
                  userMail: userMail,
                );

                await _verifyService.registerMessage(message);

                if (mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification code sent!")),
                  );
                }
              },
              child: const Text("Send Code"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // FORGOT PASSWORD FLOW
  // ==========================================

  void _startForgotPasswordFlow() {
    _showEmailDialog();
  }

  // STEP 1: Insert Email
  void _showEmailDialog() {
    final emailInputController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Recover Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please enter your email address to receive a verification code.",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailInputController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final mail = emailInputController.text.trim();
              if (mail.isEmpty) return;

              Navigator.pop(context); // Close dialog
              setState(() => _isLoading = true); // Show loading on main screen

              bool success = await _changePassService.checkMailExist(mail);

              setState(() => _isLoading = false);

              if (success && mounted) {
                _showCodeDialog(mail); // Go to Step 2
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Email not found or error occurred."),
                  ),
                );
              }
            },
            child: const Text("Send Code"),
          ),
        ],
      ),
    );
  }

  // STEP 2: Insert Code
  void _showCodeDialog(String mail) {
    final codeInputController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verification"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Code sent to $mail"),
            const SizedBox(height: 10),
            TextField(
              controller: codeInputController,
              decoration: const InputDecoration(labelText: "Enter Code"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel flow
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeInputController.text.trim();
              if (code.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);

              final model = VerifyMessage(message: code, userMail: mail);
              bool success = await _changePassService.checkCodeExist(model);

              setState(() => _isLoading = false);

              if (success && mounted) {
                _showNewPasswordDialog(mail); // Go to Step 3
              } else if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Invalid Code.")));
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  void _showNewPasswordDialog(String mail) {
    final newPassController = TextEditingController();

    showDialog(
      context: context, // This uses the LoginPage context
      barrierDismissible: false,
      // FIX: Rename 'context' to 'dialogContext' to avoid confusion
      builder: (dialogContext) => AlertDialog(
        title: const Text("New Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter your new password."),
            const SizedBox(height: 10),
            TextField(
              controller: newPassController,
              decoration: const InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            // FIX: Use dialogContext to close the dialog
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final pass = newPassController.text;
              if (pass.isEmpty) return;

              // FIX: Pop using the dialog's context
              Navigator.pop(dialogContext);

              // Use the main class setState
              setState(() => _isLoading = true);

              // Ensure your model matches the one expected by the service
              final model = NewPasswordFromUser(
                userEmail: mail,
                newPassword: pass,
              );

              // Call the service
              bool success = await _changePassService.changePassword(model);

              setState(() => _isLoading = false);

              // FIX: Check 'mounted' to ensure LoginPage is still there
              if (success && mounted) {
                // FIX: Use 'context' (from LoginPage), NOT 'dialogContext'
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password changed successfully! Please log in.",
                    ),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to change password.")),
                );
              }
            },
            child: const Text("Change Password"),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? [theme.scaffoldBackgroundColor, theme.cardColor]
        : [
            theme.scaffoldBackgroundColor.withOpacity(0.9),
            theme.scaffoldBackgroundColor,
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log In"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        // --- ADDED BACK BUTTON HERE ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // This goes back to the previous screen (FrontPage)
            Navigator.pop(context);
          },
        ),
        // -----------------------------
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ThemeController.toggleTheme();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Welcome Back",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Log in to your account",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // EMAIL FIELD
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                "Log In",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FORGOT PASSWORD BUTTON (CONNECTED TO FLOW)
                    TextButton(
                      onPressed: _isLoading ? null : _startForgotPasswordFlow,
                      child: const Text("Forgot your password?"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
