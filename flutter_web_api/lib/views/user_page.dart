import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/model.dart';
import '../model/user_task_model.dart';
import '../model/journal_model.dart';
import '../theme/theme_controller.dart';
import 'login_page.dart';
import '../API/api_handler.dart';
import '../API/userTasks_api.dart';
import '../API/journal_service.dart';
import '../API/optimization_service.dart';
import '../model/user_task_global_model.dart';
import '../API/userTasksGlobal_api.dart';
import 'settings_page.dart';
import 'global_activities_page.dart';
import '../services/signal_r_service.dart';

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
  bool _isLoading = true;

  final UserTasksGlobalService _globalTasksService = UserTasksGlobalService();
  final UserTasksService _userService = UserTasksService();
  final JournalService _journalService = JournalService();
  final OptimizationService _optimizationService = OptimizationService();

  List<UserTasks> _ghostTasks = [];
  bool _isOptimizing = false;
  double _dailyLoad = 0.0;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _myTasks = List.from(widget.initialUserTasks);
    _journals = List.from(widget.initialJournals);
    final SignalRService signalRService = SignalRService();
    
    _fetchData();

    signalRService.initSignalR(widget.user.id, (message) {
      _showNotificationDialog(message);
    });
  }

  void _showNotificationDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.orange),
            SizedBox(width: 10),
            Text("Task alert!"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    final tasks = await _userService.getUserTasks(widget.user.id);
    final journals = await _journalService.getJournals(widget.user.id);

    if (mounted) {
      setState(() {
        _myTasks = tasks;
        _journals = journals;
        _ghostTasks = [];
        _isLoading = false;
        if (_selectedDay != null) {
          _updateDailyLoadState(_selectedDay!);
        }
      });
    }
  }

  void _updateDailyLoadState(DateTime date) {
    final tasksForDay = _myTasks.where((t) => 
      t.date.year == date.year && 
      t.date.month == date.month && 
      t.date.day == date.day
    ).toList();

    setState(() {
      _dailyLoad = tasksForDay.fold(0, (sum, item) => sum + (item.taskWeight ?? 0));
    });
  }

  Future<void> _runOptimization() async {
    setState(() => _isOptimizing = true);
    
    final suggestions = await _optimizationService.getOptimizationSuggestions(widget.user.id);
    
    setState(() {
      _ghostTasks = suggestions;
      _isOptimizing = false;
    });

    if (suggestions.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Programul este deja optimizat conform priorităților."))
      );
    }
  }

Future<void> _acceptSuggestion(UserTasks task) async {
    
    final updatedTask = task.copyWith(
      nameOfTask: task.nameOfTask.replaceAll(" (Suggested)", ""),
    );
    
    
    final success = await _userService.updateUserTask(updatedTask);
    
    if (success) {
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task rescheduled successfully!")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to reschedule task.")),
        );
      }
    }
  }

  Future<void> _deleteTask(UserTasks task) async {
    final success = await _userService.deleteUserTask(task);

    if (success) {
      setState(() {
        _myTasks.remove(task);
      });
      if (_selectedDay != null) {
        _updateDailyLoadState(_selectedDay!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted successfully.")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete task."))
        );
      }
    }
  }

  Future<void> _deleteJournal(Journal journal) async {
    final success = await _journalService.deleteJournal(journal);

    if (success) {
      setState(() {
        _journals.remove(journal);
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

  void _showTaskDialog({UserTasks? existingTask}) {
    final nameController = TextEditingController(
      text: existingTask?.nameOfTask ?? "",
    );
    final descController = TextEditingController(
      text: existingTask?.description ?? "",
    );
    final lengthController = TextEditingController(
      text: existingTask?.taskLength?.toString() ?? "",
    );

    DateTime? selectedDate = existingTask?.date;
    TimeOfDay? selectedTime = existingTask?.time;

    int selectedDifficulty = existingTask?.taskDifficulty ?? 1;
    double selectedUrgency = (existingTask?.taskUrgency ?? 1).toDouble();

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
                      decoration: const InputDecoration(labelText: "Task Name"),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<int>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: "Difficulty",
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Easy (1)")),
                        DropdownMenuItem(value: 3, child: Text("Medium (3)")),
                        DropdownMenuItem(value: 5, child: Text("Hard (5)")),
                      ],
                      onChanged: (val) =>
                          setDialogState(() => selectedDifficulty = val!),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Urgency: ${selectedUrgency.toInt()}/5",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Slider(
                          value: selectedUrgency,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (val) =>
                              setDialogState(() => selectedUrgency = val),
                        ),
                      ],
                    ),

                    TextField(
                      controller: lengthController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Duration (Hours)",
                        hintText: "e.g. 1.5",
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      title: Text(
                        selectedDate == null
                            ? "Pick Date"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: Colors.orange,
                      ),
                      title: Text(
                        selectedTime == null
                            ? "Pick Time"
                            : selectedTime!.format(context),
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
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
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (nameController.text.isEmpty ||
                              selectedDate == null ||
                              selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill in Name, Date and Time",
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          final taskToSave = UserTasks(
                            userTaskId: existingTask?.userTaskId,
                            userId: widget.user.id,
                            nameOfTask: nameController.text.trim(),
                            description: descController.text.trim(),
                            date: selectedDate!,
                            time: selectedTime!,
                            taskDifficulty: selectedDifficulty,
                            taskUrgency: selectedUrgency.toInt(),
                            taskLength: double.tryParse(lengthController.text),
                          );

                          bool isSuccess = false;

                          if (existingTask == null) {
                            final errors = await _userService.createUserTask(
                              taskToSave,
                            );
                            isSuccess = errors.isEmpty;
                          } else {
                            isSuccess = await _userService.updateUserTask(
                              taskToSave,
                            );
                          }

                          if (mounted) {
                            if (isSuccess) {
                              Navigator.pop(dialogContext);
                              _fetchData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    existingTask == null
                                        ? "Task created!"
                                        : "Task updated!",
                                  ),
                                ),
                              );
                            } else {
                              setDialogState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Operation failed. Check logs or server.",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<DateTime, List<UserTasks>> _groupTasksByDate(List<UserTasks> tasks) {
    final Map<DateTime, List<UserTasks>> data = {};

    for (var task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);
      data.putIfAbsent(date, () => []);
      data[date]!.add(task);
    }

    return data;
  }

  double _calculateDailyLoad(List<UserTasks> tasks) {
    double total = 0;
    for (var task in tasks) {
      total += task.taskWeight ?? 0.0;
    }
    return total;
  }

  Widget _buildDailyLoadIndicator(List<UserTasks> tasksForDay) {
    if (tasksForDay.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalWeight = _calculateDailyLoad(tasksForDay);
    Color color;
    String text;
    IconData icon;

    double progress = totalWeight / 60.0;

    if (totalWeight <= 15) {
      color = Colors.green;
      text = "Relaxing Day";
      icon = Icons.spa;
    } else if (totalWeight <= 35) {
      color = Colors.amber;
      text = "Productive Day";
      icon = Icons.bolt;
    } else if (totalWeight <= 45) {
      color = Colors.orange;
      text = "Heavy Day";
      icon = Icons.fitness_center;
    } else {
      color = Colors.red;
      text = "Extreme Burnout Risk!";
      icon = Icons.warning_amber_rounded;
    }

    if (progress > 1.0) progress = 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Daily Load: $text",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                "${totalWeight.toStringAsFixed(1)} pts",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              color: color,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationBanner() {
    if (_dailyLoad <= 45) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200)
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          const Expanded(child: Text("High stress detected for this day!")),
          ElevatedButton(
            onPressed: _isOptimizing ? null : _runOptimization,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: _isOptimizing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Optimize"),
          )
        ],
      ),
    );
  }

  Widget _buildSmallCalendar(
    BuildContext context,
    List<UserTasks> tasks, {
    required bool isUpcoming,
  }) {
    final events = _groupTasksByDate(tasks);

    final tasksForSelectedDay = _selectedDay != null
        ? (events[DateTime(
                _selectedDay!.year,
                _selectedDay!.month,
                _selectedDay!.day,
              )] ??
              [])
        : <UserTasks>[];

    final ghostsForSelectedDay = _ghostTasks.where((t) => 
      _selectedDay != null && 
      t.date.year == _selectedDay!.year && 
      t.date.month == _selectedDay!.month && 
      t.date.day == _selectedDay!.day
    ).toList();

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
              _updateDailyLoadState(selectedDay);
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: isUpcoming
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        if (_selectedDay != null) ...[
          _buildDailyLoadIndicator(tasksForSelectedDay),
          _buildOptimizationBanner(),
          ..._buildTasksForSelectedDay(
            tasksForSelectedDay,
            ghostsForSelectedDay,
          ),
        ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
    final nameController = TextEditingController(
      text: existingJournal?.journalName ?? "",
    );
    final textController = TextEditingController(
      text: existingJournal?.jounralText ?? "",
    );
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (nameController.text.trim().isEmpty ||
                                      textController.text.trim().isEmpty) {
                                    return;
                                  }

                                  setDialogState(() => isSubmitting = true);

                                  final newJournal = Journal(
                                    IdJournal: existingJournal?.IdJournal,
                                    userId: widget.user.id,
                                    journalName: nameController.text.trim(),
                                    jounralText: textController.text.trim(),
                                  );

                                  if (existingJournal == null) {
                                    List<String> errors = await _journalService
                                        .addJournal(newJournal);

                                    if (errors.isEmpty) {
                                      final refreshedJournals =
                                          await _journalService.getJournals(
                                            widget.user.id,
                                          );

                                      setState(() {
                                        _journals = refreshedJournals;
                                      });

                                      if (mounted) Navigator.pop(dialogContext);
                                    } else {
                                      setDialogState(
                                        () => isSubmitting = false,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Error: ${errors.join(', ')}",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    String? errorMsg = await _journalService
                                        .updateJournal(newJournal);

                                    if (errorMsg == null) {
                                      setState(() {
                                        final index = _journals.indexWhere(
                                          (j) =>
                                              j.IdJournal ==
                                              existingJournal.IdJournal,
                                        );
                                        if (index != -1) {
                                          _journals[index] = newJournal; 
                                        }
                                      });
                                      if (mounted) Navigator.pop(dialogContext);
                                    } else {
                                      setDialogState(
                                        () => isSubmitting = false,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Update failed: $errorMsg",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
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

  List<Widget> _buildTasksForSelectedDay(
    List<UserTasks> tasks,
    List<UserTasks> ghosts,
  ) {
    if (tasks.isEmpty && ghosts.isEmpty) {
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

    List<Widget> items = [];

    items.addAll(tasks.map((task) => _buildTaskCard(task, false)));
    items.addAll(ghosts.map((ghost) => _buildTaskCard(ghost, true)));

    return items;
  }

  Widget _buildTaskCard(UserTasks task, bool isGhost) {
    return Opacity(
      opacity: isGhost ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isGhost 
            ? const BorderSide(color: Colors.blue, width: 2, strokeAlign: BorderSide.strokeAlignInside) 
            : BorderSide.none,
        ),
        elevation: isGhost ? 0 : 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.nameOfTask,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isGhost) 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showTaskDialog(existingTask: task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _deleteTask(task),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text("Accept"),
                      onPressed: () => _acceptSuggestion(task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white
                      ),
                    )
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    "Scheduled at: ${task.time.format(context)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Wrap(
                spacing: 10,
                children: [
                  if (task.taskDifficulty != null)
                    _buildBadge(
                      "Difficulty: ${_getDifficultyLabel(task.taskDifficulty!)}",
                      Colors.purple,
                    ),
                  if (task.taskUrgency != null)
                    _buildBadge(
                      "Urgency: ${task.taskUrgency}/5",
                      Colors.redAccent,
                    ),
                  if (task.taskLength != null)
                    _buildBadge("Duration: ${task.taskLength}h", Colors.green),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  task.description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyLabel(int val) {
    if (val <= 1) return "Easy";
    if (val <= 3) return "Medium";
    return "Hard";
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                      widget.user.name.isNotEmpty
                          ? widget.user.name[0].toUpperCase()
                          : "?",
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
              Text(
                "Actions",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildMenuButton(
                context,
                "Add Your Activities",
                Icons.add_task,
                _showTaskDialog,
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                context,
                "My Journal",
                Icons.menu_book,
                () => _openJournalManager(),
              ),

              const SizedBox(height: 20),

              Text(
                "Upcoming Calendar",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSmallCalendar(context, upcomingTasks, isUpcoming: true),
              const SizedBox(height: 30),
              Text(
                "History",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildSmallCalendar(context, pastTasks, isUpcoming: false),
              const SizedBox(height: 40),
              Text(
                "My Journal",
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildJournalSection(),
              const SizedBox(height: 40),
              _buildMenuButton(context, "Global Activities", Icons.public, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GlobalActivitiesPage(user: widget.user),
                  ),
                );
              }),

              _buildMenuButton(context, "Settings", Icons.settings, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(user: widget.user),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildStringList(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No items found."),
                ),
              ]
            : items.map((e) => ListTile(title: Text(e))).toList(),
      ),
    );
  }
}