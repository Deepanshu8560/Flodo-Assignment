import '../entities/task.dart';

/// Abstract repository interface for the domain layer.
abstract class TaskRepository {
  Future<List<Task>> getTasks({String? search, String? status});
  Future<Task> getTaskById(String id);
  Future<Task> createTask({
    required String title,
    String description,
    DateTime? dueDate,
    required String status,
    String? blockedBy,
  });
  Future<Task> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? blockedBy,
  });
  Future<void> deleteTask(String id);
}
