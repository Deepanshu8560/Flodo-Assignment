/// API constants for the Task Management application.
class ApiConstants {
  static const String baseUrl = 'http://localhost:8000';
  static const String tasksEndpoint = '/tasks';
  static const Duration timeoutDuration = Duration(seconds: 10);
}

/// Status constants matching the backend.
class TaskStatusConstants {
  static const String toDo = 'To-Do';
  static const String inProgress = 'In Progress';
  static const String done = 'Done';

  static const List<String> all = [toDo, inProgress, done];
}
