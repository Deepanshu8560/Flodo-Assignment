import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';
import '../widgets/task_search_bar.dart';

/// Main task list screen with search bar and status filter.
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text(
          'Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          // Status filter dropdown
          PopupMenuButton<String?>(
            icon: Icon(
              Icons.filter_list_rounded,
              color: taskState.statusFilter != null
                  ? AppTheme.primaryColor
                  : Colors.white70,
            ),
            tooltip: 'Filter by status',
            color: AppTheme.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              ref.read(taskListProvider.notifier).filterByStatus(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem<String?>(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 18, color: Colors.white70),
                    const SizedBox(width: 8),
                    const Text('All Tasks'),
                  ],
                ),
              ),
              ...TaskStatusConstants.all.map(
                (status) => PopupMenuItem<String?>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          const TaskSearchBar(),

          // Active filter chip
          if (taskState.statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      'Status: ${taskState.statusFilter}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      ref.read(taskListProvider.notifier).filterByStatus(null);
                    },
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.2,
                    ),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
          // Task list
          Expanded(child: _buildBody(context, ref, taskState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/create');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    TaskListState taskState,
  ) {
    if (taskState.isLoading && taskState.tasks.isEmpty) {
      return _buildLoadingShimmer();
    }

    if (taskState.error != null && taskState.tasks.isEmpty) {
      return _buildErrorState(ref, taskState.error!);
    }

    if (taskState.tasks.isEmpty) {
      return _buildEmptyState(taskState);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(),
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: taskState.tasks.length,
        itemBuilder: (context, index) {
          final task = taskState.tasks[index];
          return TaskCard(
            task: task,
            searchQuery: taskState.searchQuery,
            isDeleting: taskState.deletingTaskId == task.id,
            onTap: () {
              Navigator.of(context).pushNamed('/edit', arguments: task);
            },
            onDelete: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(taskListProvider.notifier).loadTasks(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TaskListState taskState) {
    final hasFilter =
        taskState.searchQuery.isNotEmpty || taskState.statusFilter != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? Icons.search_off_rounded : Icons.task_alt_rounded,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No results found' : 'No tasks yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try adjusting your search or filter'
                  : 'Tap the + button to create your first task',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case TaskStatusConstants.toDo:
        return AppTheme.todoColor;
      case TaskStatusConstants.inProgress:
        return AppTheme.inProgressColor;
      case TaskStatusConstants.done:
        return AppTheme.doneColor;
      default:
        return AppTheme.todoColor;
    }
  }
}
