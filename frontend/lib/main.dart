import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/domain/entities/task.dart';
import 'features/tasks/presentation/screens/task_list_screen.dart';
import 'features/tasks/presentation/screens/task_form_screen.dart';

void main() {
  runApp(const ProviderScope(child: TaskManagerApp()));
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const TaskListScreen(),
            );
          case '/create':
            return MaterialPageRoute(
              builder: (_) => const TaskFormScreen(),
            );
          case '/edit':
            final task = settings.arguments as Task?;
            return MaterialPageRoute(
              builder: (_) => TaskFormScreen(task: task),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const TaskListScreen(),
            );
        }
      },
    );
  }
}
