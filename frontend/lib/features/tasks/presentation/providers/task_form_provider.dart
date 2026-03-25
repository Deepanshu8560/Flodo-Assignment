import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/task_repository.dart';

/// State for task form operations (create/update).
class TaskFormState {
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  const TaskFormState({
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  TaskFormState copyWith({
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return TaskFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Manages create/update task form operations.
class TaskFormNotifier extends StateNotifier<TaskFormState> {
  final TaskRepository _repository;

  TaskFormNotifier(this._repository) : super(const TaskFormState());

  Future<bool> createTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    required String status,
    String? blockedBy,
  }) async {
    if (state.isSubmitting) return false; // Prevent duplicate

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      isSuccess: false,
    );
    try {
      await _repository.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        status: status,
        blockedBy: blockedBy,
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? blockedBy,
  }) async {
    if (state.isSubmitting) return false; // Prevent duplicate

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      isSuccess: false,
    );
    try {
      await _repository.updateTask(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        status: status,
        blockedBy: blockedBy,
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const TaskFormState();
  }
}
