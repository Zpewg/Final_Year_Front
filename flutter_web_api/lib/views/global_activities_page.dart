import 'package:flutter/material.dart';
import '../model/model.dart';
import '../model/user_task_global_model.dart';
import '../API/userTasksGlobal_api.dart';

class GlobalActivitiesPage extends StatefulWidget {
  final User user;
  const GlobalActivitiesPage({super.key, required this.user});

  @override
  State<GlobalActivitiesPage> createState() => _GlobalActivitiesPageState();
}

class _GlobalActivitiesPageState extends State<GlobalActivitiesPage> {
  final UserTasksGlobalService _service = UserTasksGlobalService();
  List<UserTasksGlobal> items = [];
  List<UserTasksGlobal> usersGlobalTasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => loading = true);
    final results = await Future.wait([
      _service.getGlobalTasksByKm(widget.user),
      _service.getGlobalTasksByUserId(widget.user),
    ]);
    if (mounted) {
      setState(() {
        items = results[0];
        usersGlobalTasks = results[1];
        loading = false;
      });
    }
  }

  Future<void> _deleteTask(UserTasksGlobal task) async {
    final success = await _service.deleteUserTaskGlobal(task);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task deleted!")));
      loadAllData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete task.")));
    }
  }

  Future<void> _showEditDialog(UserTasksGlobal task) async {
    final nameCtrl = TextEditingController(text: task.nameOfTask);
    final descCtrl = TextEditingController(text: task.description ?? "");
    DateTime? selectedDate = task.date;
    TimeOfDay? selectedTime = task.time;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Global Activity"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text("${selectedDate!.toLocal()}".split(' ')[0]),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate!,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setStateDialog(() => selectedDate = date);
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime!.format(context)),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime!,
                            );
                            if (time != null) setStateDialog(() => selectedTime = time);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;

                  final updatedTask = UserTasksGlobal(
                    userTaskId: task.userTaskId,
                    userId: widget.user.id,
                    nameOfTask: nameCtrl.text,
                    description: descCtrl.text,
                    date: selectedDate!,
                    time: selectedTime!,
                    location: task.location,
                  );

                  final errors = await _service.updateUserTaskGlobal(updatedTask);
                  
                  if (mounted) {
                    if (errors.isEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task updated successfully!"))
                      );
                      loadAllData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errors.join(', '))),
                      );
                    }
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Add Global Activity"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text("${selectedDate!.toLocal()}".split(' ')[0]),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate!,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setStateDialog(() => selectedDate = date);
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime!.format(context)),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime!,
                            );
                            if (time != null) setStateDialog(() => selectedTime = time);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;

                  final newTask = UserTasksGlobal(
                    userTaskId: 0,
                    userId: widget.user.id,
                    nameOfTask: nameCtrl.text,
                    description: descCtrl.text,
                    date: selectedDate!,
                    time: selectedTime!,
                    location: null,
                  );

                  final errors = await _service.createUserTaskGlobal(newTask, widget.user);
                  
                  if (mounted) {
                    if (errors.isEmpty) {
                      Navigator.pop(context);
                      loadAllData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errors.join(', '))),
                      );
                    }
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Global Activities"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Activities"),
              Tab(text: "Your Activities"),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(items, canEdit: false),
                  _buildList(usersGlobalTasks, canEdit: true),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<UserTasksGlobal> list, {required bool canEdit}) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (canEdit) ...[
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Global Activity"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("No activities found.")),
          ),

        ...list.map((e) => Card(
              child: ListTile(
                leading: const Icon(Icons.public),
                title: Text(e.nameOfTask),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.description != null && e.description!.trim().isNotEmpty)
                      Text(e.description!),
                    const SizedBox(height: 4),
                    Text(
                      "📅 ${e.date.toLocal().toString().split(' ')[0]} ⏰ ${e.time.format(context)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: canEdit
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(e),
                          ),
                        ],
                      )
                    : null,
              ),
            )),
      ],
    );
  }
}