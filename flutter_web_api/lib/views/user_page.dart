import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/model.dart';
import '../model/user_task_model.dart';
import '../model/journal_model.dart';
import '../theme/theme_controller.dart';
import 'login_page.dart';
import '../API/api_handler.dart'; 
// Make sure these imports match your actual file paths
import '../API/userTasks_api.dart'; 
import '../API/journal_service.dart';
import '../model/user_task_global_model.dart'; // importul tău corect
import '../API/userTasksGlobal_api.dart'; // importul tău corect
import 'settings_page.dart';
import 'global_activities_page.dart';

class UserPage extends StatefulWidget {
  final User user;
  final List<UserTasks> initialUserTasks;
  final List<Journal> initialJournals; 
  final List<String> nearbyActivities;

  const UserPage({
    super.key,
    required this.user,
    this.initialUserTasks = const [],
    this.initialJournals = const [],   
    this.nearbyActivities = const [],
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late List<UserTasks> _myTasks;
  late List<Journal> _journals; 
  bool _isLoading = true; // Set to true initially
final UserTasksGlobalService _globalTasksService = UserTasksGlobalService();
  final UserTasksService _userService = UserTasksService();
  final JournalService _journalService = JournalService(); 
  

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _myTasks = List.from(widget.initialUserTasks);
    _journals = List.from(widget.initialJournals); 
    
    // ✅ MUST CALL FETCH DATA HERE
    _fetchData(); 
  }

  // ✅ FETCH DATA USING YOUR METHODS
Future<void> _fetchData() async {
    final tasks = await _userService.getUserTasks(widget.user.id);
    final journals = await _journalService.getJournals(widget.user.id);


    if (mounted) {
      setState(() {
        _myTasks = tasks;
        _journals = journals;
        _isLoading = false; 
      });
    }
  }
  Future<void> _deleteTask(UserTasks task) async {
    final success = await _userService.deleteUserTask(task);

    if (success) {
      setState(() {
        _myTasks.remove(task); // Removes the task from the local list
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted successfully.")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete task.")),
        );
      }
    }
  }
  Future<void> _deleteJournal(Journal journal) async {
    final success = await _journalService.deleteJournal(journal);

    if (success) {
      setState(() {
        _journals.remove(journal); // Șterge jurnalul din listă
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Journal deleted successfully.")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete journal.")),
        );
      }
    }
    
  }

  // ---------------- ADD TASK DIALOG ----------------
void _showTaskDialog({UserTasks? existingTask}) {
    final nameController = TextEditingController(text: existingTask?.nameOfTask ?? "");
    final descController = TextEditingController(text: existingTask?.description ?? "");

    DateTime? selectedDate = existingTask?.date;
    TimeOfDay? selectedTime = existingTask?.time;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingTask == null ? "New Task" : "Edit Task"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Task Name", prefixIcon: Icon(Icons.task)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.description)),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(selectedDate == null ? "Pick a Date" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100),
                        );
                        if (picked != null) setDialogState(() => selectedDate = picked);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(selectedTime == null ? "Pick a Time" : selectedTime!.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context, initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) setDialogState(() => selectedTime = picked);
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
                    if (nameController.text.isEmpty || selectedDate == null || selectedTime == null) return;
                    setDialogState(() => isSubmitting = true);

                    final taskToSave = UserTasks(
                      userTaskId: existingTask?.userTaskId, // ✅ Păstrăm ID-ul pentru Update
                      userId: widget.user.id,
                      nameOfTask: nameController.text.trim(),
                      description: descController.text.trim(),
                      date: selectedDate!,
                      time: selectedTime!,
                    );

                    if (existingTask == null) {
                      // 🆕 CREATE TASK
                      List<String> success = await _userService.createUserTask(taskToSave);
                      if (success.isEmpty) {
                        final refreshedTasks = await _userService.getUserTasks(widget.user.id); // Re-fetch pt ID real
                        setState(() => _myTasks = refreshedTasks);
                        if (mounted) Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() => isSubmitting = false);
                      }
                    } else {
                      // ✏️ UPDATE TASK
                      bool success = await _userService.updateUserTask(taskToSave);
                      if (success) {
                        setState(() {
                          final index = _myTasks.indexWhere((t) => t.userTaskId == existingTask.userTaskId);
                          if (index != -1) _myTasks[index] = taskToSave;
                        });
                        if (mounted) Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() => isSubmitting = false);
                      }
                    }
                  },
                  child: isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // ---------------- GROUP TASKS BY DATE ----------------
  Map<DateTime, List<UserTasks>> _groupTasksByDate(List<UserTasks> tasks) {
    final Map<DateTime, List<UserTasks>> data = {};

    for (var task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      data.putIfAbsent(date, () => []);
      data[date]!.add(task);
    }

    return data;
  }

  // ---------------- SMALL CALENDAR ----------------
  Widget _buildSmallCalendar(BuildContext context, List<UserTasks> tasks, {required bool isUpcoming}) {
    final events = _groupTasksByDate(tasks);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TableCalendar<UserTasks>(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            rowHeight: 36,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              return events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: isUpcoming ? Theme.of(context).primaryColor : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedDay != null)
          ..._buildTasksForSelectedDay(
            events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [],
            isUpcoming: isUpcoming,
          ),
      ],
    );
  }

  void _openJournalManager() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Journal", style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("New Journal"),
                    onPressed: () {
                      Navigator.pop(context);
                      _openJournalEditor();
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _journals.isEmpty
                      ? const Center(child: Text("No journal entries yet."))
                      : ListView.builder(
                          itemCount: _journals.length,
                          itemBuilder: (context, index) {
                            final journal = _journals[index];

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  journal.journalName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  journal.jounralText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _openJournalEditor(existingJournal: journal);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

void _openJournalEditor({Journal? existingJournal}) {
    final nameController = TextEditingController(text: existingJournal?.journalName ?? "");
    final textController = TextEditingController(text: existingJournal?.jounralText ?? "");
    bool isSubmitting = false; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return StatefulBuilder( 
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      existingJournal == null ? "New Journal" : "Edit Journal",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Journal Name",
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: TextField(
                        controller: textController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          labelText: "Write your thoughts...",
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                        ElevatedButton(
                          onPressed: isSubmitting ? null : () async {
                            if (nameController.text.trim().isEmpty || textController.text.trim().isEmpty) return;

                            setDialogState(() => isSubmitting = true);

                            // ✅ 1. ADAUGĂ IdJournal PENTRU A SUPORTA EDITAREA
                            final newJournal = Journal(
                              IdJournal: existingJournal?.IdJournal, 
                              userId: widget.user.id,
                              journalName: nameController.text.trim(),
                              jounralText: textController.text.trim(),
                            );

                            if (existingJournal == null) {
                              // 🆕 CREATE JOURNAL
                              List<String> errors = await _journalService.addJournal(newJournal);

                              if (errors.isEmpty) {
                                final refreshedJournals = await _journalService.getJournals(widget.user.id);
                                
                                setState(() {
                                  _journals = refreshedJournals;
                                });
                                
                                if (mounted) Navigator.pop(dialogContext);
                              } else {
                                setDialogState(() => isSubmitting = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: ${errors.join(', ')}")),
                                  );
                                }
                              }
                            } else {
                              // ✏️ UPDATE EXISTING JOURNAL
                              String? errorMsg = await _journalService.updateJournal(newJournal);

                              if (errorMsg == null) { // null înseamnă Succes
                                setState(() {
                                  final index = _journals.indexWhere((j) => j.IdJournal == existingJournal.IdJournal);
                                  if (index != -1) {
                                    _journals[index] = newJournal; // Actualizăm vizual lista
                                  }
                                });
                                if (mounted) Navigator.pop(dialogContext);
                              } else {
                                setDialogState(() => isSubmitting = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Update failed: $errorMsg")),
                                  );
                                }
                              }
                            }
                          },
                          child: isSubmitting 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                              : const Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

Widget _buildJournalSection() {
    if (_journals.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text("No journal notes yet."),
        ),
      );
    }

    return Column(
      children: _journals.map((journal) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              journal.journalName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              journal.jounralText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // ✅ AICI S-A MODIFICAT: Row pentru a adăposti ambele butoane
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _openJournalEditor(existingJournal: journal),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteJournal(journal),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

List<Widget> _buildTasksForSelectedDay(List<UserTasks> tasks, {required bool isUpcoming}) {
    if (tasks.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            "No tasks for this day.",
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ),
      ];
    }

    return tasks.map((task) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ MODIFIED: Wrapped title and delete button in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.nameOfTask,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUpcoming ? null : Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _deleteTask(task), // ✅ Calls the delete logic
                  ),
                ],
              ),
              const SizedBox(height: 4),
           // Înlocuiește IconButton-ul de Delete cu acest Row:
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showTaskDialog(existingTask: task), // ✅ Deschide dialogul cu datele vechi
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _deleteTask(task), 
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUpcoming ? null : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final gradientColors = isDark
        ? [theme.scaffoldBackgroundColor, theme.cardColor]
        : [
            theme.scaffoldBackgroundColor.withOpacity(0.9),
            theme.scaffoldBackgroundColor,
          ];

    // ✅ SHOW SPINNER WHILE WAITING FOR API
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingTasks = _myTasks.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      return tDate.isAtSameMomentAs(today) || tDate.isAfter(today);
    }).toList();

    final pastTasks = _myTasks.where((t) {
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      return tDate.isBefore(today);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ThemeController.toggleTheme(),
        child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      ),
      body: Container(
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello,",
                        style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
                      ),
                      Text(
                        widget.user.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                "Actions",
                style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildMenuButton(context, "Add Your Activities", Icons.add_task, _showTaskDialog),
              const SizedBox(height: 16),
    
            
              _buildMenuButton(context, "My Journal", Icons.menu_book, () => _openJournalManager()),
              
              const SizedBox(height: 20),
              
      
               
              Text(
                "Upcoming Calendar",
                style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSmallCalendar(context, upcomingTasks, isUpcoming: true),
              const SizedBox(height: 30),
              Text(
                "History",
                style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSmallCalendar(context, pastTasks, isUpcoming: false),
              const SizedBox(height: 40),
              Text(
                "My Journal",
                style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildJournalSection(),
              const SizedBox(height: 40),
              _buildMenuButton(context, "Global Activities", Icons.public, () {
 Navigator.push(context, MaterialPageRoute(
   builder: (_) => GlobalActivitiesPage(user: widget.user),
 ));
}),

_buildMenuButton(context, "Settings", Icons.settings, () {
 Navigator.push(context, MaterialPageRoute(
   builder: (_) => SettingsPage(user: widget.user),
 ));
})
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildStringList(BuildContext context, String title, IconData icon, List<String> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.isEmpty
            ? [const Padding(padding: EdgeInsets.all(16), child: Text("No items found."))]
            : items.map((e) => ListTile(title: Text(e))).toList(),
      ),
    );
  }
}