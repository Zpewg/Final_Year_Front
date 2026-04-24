import '../model/user_task_global_model.dart'; 
import '../model/model.dart'; 

class GlobalTaskRequestDto {
  final UserTasksGlobal task;
  final User user;

  GlobalTaskRequestDto({required this.task, required this.user});

  Map<String, dynamic> toJson() => {
        // Asigură-te că ambele clase au metoda toJson() definită
        'task': task.toJson(),
        'user': user.toJson(),
      };
}