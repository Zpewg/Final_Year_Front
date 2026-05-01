import 'package:flutter/material.dart';
import '../model/model.dart';
import '../API/api_handler.dart';
import '../theme/theme_controller.dart';
import 'login_page.dart';
import '../API/notification_enabled_service.dart';
import '../model/notification_enabled_model.dart';
import '../model/notification_lead_time_model.dart';
import '../API/notification_lead_time_service.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  const SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  int? _currentNotificationId; // <-- SALVĂM ID-UL AICI
  final NotificationEnabledService _notificationService =
      NotificationEnabledService();
  final NotificationLeadTimeService _leadTimeService =
      NotificationLeadTimeService();
  List<NotificationLeadTime> _leadTimes = []; // Lista noastră de alerte
  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  // Extragem statusul din baza de date la inițializare
  Future<void> _loadNotificationStatus() async {
    final notifications = await _notificationService.getNotificationEnabled(
      widget.user.id,
    );
    if (mounted) {
      if (notifications.isNotEmpty) {
        setState(() {
          _notificationsEnabled = notifications.first.isEnabled;
          _currentNotificationId = notifications.first.notificationId;
        });
        // Dacă notificările sunt active, încărcăm și timpii
        if (_notificationsEnabled) {
          _refreshLeadTimes();
        }
      }
    }
  }

  Future<void> _refreshLeadTimes() async {
    final times = await _leadTimeService.getNotificationLeadTime(
      widget.user.id,
    );
    setState(() => _leadTimes = times);
  }

  void _showAddLeadTimeDialog() {
    final TextEditingController valueController = TextEditingController();
    String selectedUnit = "Minutes";
    final units = ["Minutes", "Hours", "Days"];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Notification Alert"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Value"),
              ),
              DropdownButton<String>(
                value: selectedUnit,
                isExpanded: true,
                items: units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedUnit = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int value = int.tryParse(valueController.text) ?? 0;
                int minutes = 0;

                // Conversia în minute (Standardul nostru)
                if (selectedUnit == "Minutes") minutes = value;
                if (selectedUnit == "Hours") minutes = value * 60;
                if (selectedUnit == "Days") minutes = value * 1440;

                // Validarea discutată (1 min - 7 zile)
                if (minutes < 1 || minutes > 10080) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter a value between 1 minute and 7 days.",
                      ),
                    ),
                  );
                  return;
                }

                final newLead = NotificationLeadTime(
                  notificationId: _currentNotificationId!,
                  notificationTime: minutes,
                );

                final error = await _leadTimeService.addNotificationLeadTime(
                  newLead,
                );
                if (error == null) {
                  Navigator.pop(ctx);
                  _refreshLeadTimes();
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int totalMinutes) {
    if (totalMinutes >= 1440)
      return "${(totalMinutes / 1440).toStringAsFixed(0)} days";
    if (totalMinutes >= 60)
      return "${(totalMinutes / 60).toStringAsFixed(0)} hours";
    return "$totalMinutes mins";
  }

  void _promptShareLocation() {
    int selectedKm = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        // AM REDENUMIT AICI: din 'context' în 'dialogContext'
        builder: (dialogContext, setDialogState) {
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
                  onChanged: (v) =>
                      setDialogState(() => selectedKm = v.toInt()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 1. Salvăm referința la interfață ÎNAINTE de a închide dialogul și de apelul async
                  final messenger = ScaffoldMessenger.of(context);

                  Navigator.pop(ctx); // Închidem dialogul

                  bool success = await ApiHandler().updateLocation(
                    widget.user.id,
                    selectedKm,
                  );

                  // 2. Folosim referința salvată, care aparține paginii, nu dialogului distrus
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Location shared successfully"
                              : "Failed to share location",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Save"),
              ),
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
            // 1. Switch-ul principal pentru Enable/Disable
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text("Enable Notifications"),
              value: _notificationsEnabled,
              onChanged: (bool value) async {
                setState(() => _notificationsEnabled = value);

                final notification = NotificationEnabled(
                  notificationId: _currentNotificationId,
                  userId: widget.user.id,
                  isEnabled: value,
                );

                final error = value
                    ? await _notificationService.enableNotification(
                        notification,
                      )
                    : await _notificationService.disableNotification(
                        notification,
                      );

                if (error != null && mounted) {
                  setState(() => _notificationsEnabled = !value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to save: $error")),
                  );
                } else if (error == null && value == true) {
                  _loadNotificationStatus();
                }
              },
            ),

            // 2. Secțiunea de Active Alerts (Apare doar dacă switch-ul e TRUE)
            if (_notificationsEnabled) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text("Active Alerts"),
                subtitle: const Text("Tap + to add a new reminder"),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: _showAddLeadTimeDialog,
                ),
              ),
              // Afișăm alertele sub formă de Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: _leadTimes
                        .map(
                          (lt) => Chip(
                            label: Text(_formatMinutes(lt.notificationTime)),
                            onDeleted: () async {
                              bool deleted = await _leadTimeService
                                  .deleteNotificationLeadTime(lt);
                              if (deleted) _refreshLeadTimes();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],

            const Divider(),

            // 3. Restul setărilor (Location, Logout)
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
