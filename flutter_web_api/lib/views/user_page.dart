import 'package:flutter/material.dart';
import 'package:flutter_web_api/API/userTasks_api.dart';
import '../model/model.dart';
import '../model/user_task_model.dart'; // Ensure this imports your UserTasks class
import '../theme/theme_controller.dart';
import 'login_page.dart';

class UserPage extends StatefulWidget {
  final User user;
  
  // These are initial lists (optional)
  final List<UserTasks> initialUserTasks; // Changed to List<UserTasks>
  final List<String> nearbyActivities;

  const UserPage({
    super.key, 
    required this.user,
    this.initialUserTasks = const [], 
    this.nearbyActivities = const [],
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Local state to manage the list in real-time
  late List<UserTasks> _myTasks;
  final UserTasksService _userService = UserTasksService();

  @override
  void initState() {
    super.initState();
    // Initialize local list with passed data
    _myTasks = List.from(widget.initialUserTasks);
  }

  // ==========================================
  // SHOW ADD TASK DIALOG
  // ==========================================
  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("New Task"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NAME INPUT
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Task Name",
                        prefixIcon: Icon(Icons.task),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // DESCRIPTION INPUT (Optional)
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: "Description (Optional)",
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // DATE PICKER
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        selectedDate == null 
                          ? "Pick a Date" 
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),

                    // TIME PICKER
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        selectedTime == null 
                          ? "Pick a Time" 
                          : selectedTime!.format(context)
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    // VALIDATION
                    if (nameController.text.isEmpty || selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill Name, Date and Time."))
                      );
                      return;
                    }

                    setDialogState(() => isSubmitting = true);

                    // CREATE MODEL
                    // Assuming widget.user has an 'id' or 'userId' field. 
                    // Adjust 'widget.user.userId' to match your User model.
                    final newTask = UserTasks(
                      userId: widget.user.id, // <--- MAKE SURE THIS MATCHES YOUR USER MODEL
                      nameOfTask: nameController.text.trim(),
                      description: descController.text.trim(),
                      date: selectedDate!,
                      time: selectedTime!,
                    );

                    // API CALL
                    List<String> success = await _userService.createUserTask(newTask);

                    if (success.isEmpty) {
                      // UPDATE UI REAL-TIME
                      setState(() {
                        _myTasks.add(newTask);
                      });
                      
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Task added successfully!"))
                        );
                      }
                    } else {
                      setDialogState(() => isSubmitting = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to create task."))
                        );
                      }
                    }
                  },
                  child: isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

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
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ThemeController.toggleTheme(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // --- HEADER ---
              Row(
                children: [
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
                      radius: 35,
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello,",
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        widget.user.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ==============================
              // 1. BUTOANELE (BUTTONS)
              // ==============================
              Text("Actions", style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _buildMenuButton(
                context, 
                "Add Your Activities", 
                Icons.add_task, // Changed Icon
                _showAddTaskDialog // Calls the dialog
              ),
              
              const SizedBox(height: 16),
              
              _buildMenuButton(
                context, 
                "Add Nearby Activities", 
                Icons.map, 
                () => print("Button 2 Pressed")
              ),

              const SizedBox(height: 40),

              // ==============================
              // 2. LISTELE DROPDOWN (EXPANSION TILES)
              // ==============================
              Text("Lists", style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // YOUR ACTIVITIES (Using UserTasks objects)
              _buildUserTasksList(
                context, 
                "Your Activities List", 
                Icons.list_alt, 
                _myTasks
              ),

              const SizedBox(height: 16),

              // NEARBY ACTIVITIES (Still Strings for now)
              _buildStringList(
                context, 
                "Nearby Activities List", 
                Icons.location_on_outlined, 
                widget.nearbyActivities
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PENTRU BUTOANE ---
  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.cardColor,
          foregroundColor: theme.textTheme.bodyLarge?.color,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENTRU LISTA DE TASK-URI (COMPLEX OBJECTS) ---
  Widget _buildUserTasksList(BuildContext context, String title, IconData icon, List<UserTasks> tasks) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: ExpansionTile(
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          if (tasks.isEmpty)
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text("No tasks added yet.", style: TextStyle(color: theme.disabledColor)),
             )
          else
            SizedBox(
              height: 200, // Slightly taller for detailed items
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tasks.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.nameOfTask, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "${task.date.day}/${task.date.month} - ${task.time.format(context)}\n${task.description.isEmpty ? '' : task.description}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET PENTRU LISTA SIMPLĂ (STRINGS) ---
  Widget _buildStringList(BuildContext context, String title, IconData icon, List<String> items) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: ExpansionTile(
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          if (items.isEmpty)
             Padding(
               padding: const EdgeInsets.all(16.0),
               child: Text("No activities found.", style: TextStyle(color: theme.disabledColor)),
             )
          else
            SizedBox(
              height: 150,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index]),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}