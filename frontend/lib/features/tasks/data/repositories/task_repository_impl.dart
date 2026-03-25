import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using remote data source.
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Task>> getTasks({String? search, String? status}) async {
    return await remoteDataSource.getTasks(search: search, status: status);
  }

  @override
  Future<Task> getTaskById(String id) async {
    final tasks = await remoteDataSource.getTasks();
    return tasks.firstWhere((t) => t.id == id);
  }

  @override
  Future<Task> createTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    required String status,
    String? blockedBy,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
    };
    if (dueDate != null) {
      data['due_date'] = dueDate.toIso8601String().split('T').first;
    }
    if (blockedBy != null && blockedBy.isNotEmpty) {
      data['blocked_by'] = blockedBy;
    }
    return await remoteDataSource.createTask(data);
  }

  @override
  Future<Task> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? blockedBy,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (dueDate != null) data['due_date'] = dueDate.toIso8601String().split('T').first;
    if (status != null) data['status'] = status;
    if (blockedBy != null) data['blocked_by'] = blockedBy.isEmpty ? null : blockedBy;
    return await remoteDataSource.updateTask(id, data);
  }

  @override
  Future<void> deleteTask(String id) async {
    await remoteDataSource.deleteTask(id);
  }
}
