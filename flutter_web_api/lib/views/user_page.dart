import 'package:flutter/material.dart';
import 'model.dart'; // Import your User class
import 'theme_controller.dart'; // Import your ThemeController
import 'login_page.dart'; // Used for logout navigation

class UserPage extends StatelessWidget {
  final User user;

  const UserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Access the current theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Text Color Fix:
    // Your dark theme defines text as Black, which is hard to see on the dark background.
    // We override this locally to White for Dark Mode so it looks good.
    final Color textColor = isDark ? Colors.white : Colors.black87;
    
    // 2. Gradient Logic (Matches your Login Page):
    final gradientColors = isDark
        ? [theme.scaffoldBackgroundColor, theme.cardColor]
        : [
            theme.scaffoldBackgroundColor.withOpacity(0.9),
            theme.scaffoldBackgroundColor
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              // Navigate back to Login and remove stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      // THEME TOGGLE BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => ThemeController.toggleTheme(),
        // Use primaryColor from your AppThemes (PurpleAccent or DeepOrange)
        backgroundColor: theme.primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // --- BIG AVATAR ---
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    // Display first letter of name
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- WELCOME TEXT ---
              Text(
                "Hello,",
                style: TextStyle(
                  fontSize: 20,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 40),

              // --- STATUS CARD ---
              // Shows if the user is active, but hides the email
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user, 
                        color: user.active ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        user.active ? "Account Active" : "Account Inactive",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          // Your theme forces black text in cards, which is fine
                          // if the card background is light enough.
                          color: theme.textTheme.bodyMedium?.color ?? Colors.black, 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}