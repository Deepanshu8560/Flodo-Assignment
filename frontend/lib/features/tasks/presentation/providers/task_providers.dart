import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

// HTTP client provider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Remote data source provider
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(client: ref.watch(httpClientProvider));
});

// Repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(remoteDataSource: ref.watch(taskRemoteDataSourceProvider));
});

// Task list state
class TaskListState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? statusFilter;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.statusFilter,
  });

  TaskListState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? statusFilter,
    bool clearError = false,
    bool clearStatusFilter = false,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

// Task list notifier
class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;

  TaskListNotifier(this._repository) : super(const TaskListState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _repository.getTasks(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.statusFilter,
      );
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> searchTasks(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadTasks();
  }

  Future<void> filterByStatus(String? status) async {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Providers
final taskListProvider = StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier(ref.watch(taskRepositoryProvider));
});

// Re-export form provider
export 'task_form_provider.dart';
