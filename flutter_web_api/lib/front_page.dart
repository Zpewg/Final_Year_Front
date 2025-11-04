import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'signup_view.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gradient adapts to theme
    final gradientColors = isDark
        ? [theme.scaffoldBackgroundColor, theme.cardColor]
        : [theme.scaffoldBackgroundColor.withOpacity(0.9), theme.scaffoldBackgroundColor];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Management"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  SizedBox(
                    height: 200,
                    child: SvgPicture.asset(
                      "assets/undraw_to-do-list_o3jf.svg",
                      fit: BoxFit.contain,
                      // Keep SVG original colors
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    "Task Management",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Stay organized, stay productive",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (Colors.black ),
                          fontWeight: FontWeight.bold,
                    ),

                  ),

                  const SizedBox(height: 60),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to Login View
                      },
                      style: theme.elevatedButtonTheme.style,
                      child: Text(
                        "Log In",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}) ??
                              theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpView()),
                        );
                      },
                      style: theme.outlinedButtonTheme.style,
                      child: Text(
                        "Sign Up",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: theme.outlinedButtonTheme.style?.foregroundColor?.resolve({}) ??
                              theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
