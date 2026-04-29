import 'package:flutter/material.dart';
import '../model/model.dart';
import '../API/api_handler.dart';
import '../theme/theme_controller.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
 final User user;
 const SettingsPage({super.key, required this.user});

 @override
 State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
 void _promptShareLocation() {
   int selectedKm = 5;

   showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text("Share your location?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose activity range"),
              Slider(
                value: selectedKm.toDouble(),
                min: 1,
                max: 16,
                divisions: 15,
                label: "$selectedKm km",
                onChanged: (v) {
                  setDialogState(() => selectedKm = v.toInt());
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                bool success = await ApiHandler()
                    .updateLocation(widget.user.id, selectedKm);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success
                      ? "Location shared successfully"
                      : "Failed to share location")),
                  );
                }
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    ),
   );
 }

 @override
 Widget build(BuildContext context) {
   final theme = Theme.of(context);
   final isDark = theme.brightness == Brightness.dark;

   return Scaffold(
    appBar: AppBar(title: const Text("Settings")),
    floatingActionButton: FloatingActionButton(
      onPressed: ThemeController.toggleTheme,
      child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Share Location"),
            onTap: _promptShareLocation,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    ),
   );
 }
}