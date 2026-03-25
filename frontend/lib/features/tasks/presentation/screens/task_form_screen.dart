import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// Screen for creating or editing a task.
class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task; // null = create, non-null = edit

  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  late String _status;
  String? _blockedBy;
  bool _isSubmitting = false;
  late String _draftId;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _draftId = widget.task?.id ?? 'new';

    final draftService = ref.read(draftServiceProvider);
    final draft = draftService.loadDraft(_draftId);

    _titleController = TextEditingController(
      text: draft?['title'] ?? widget.task?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: draft?['description'] ?? widget.task?.description ?? '',
    );

    if (draft != null && draft['due_date'] != null) {
      _dueDate = DateTime.parse(draft['due_date']);
    } else {
      _dueDate = widget.task?.dueDate;
    }

    _status =
        draft?['status'] ?? widget.task?.status ?? TaskStatusConstants.toDo;
    _blockedBy = draft?['blocked_by'] ?? widget.task?.blockedBy;

    _titleController.addListener(_saveDraft);
    _descriptionController.addListener(_saveDraft);
  }

  void _saveDraft() {
    final draftService = ref.read(draftServiceProvider);
    draftService.saveDraft(_draftId, {
      'title': _titleController.text,
      'description': _descriptionController.text,
      if (_dueDate != null) 'due_date': _dueDate!.toIso8601String(),
      'status': _status,
      if (_blockedBy != null) 'blocked_by': _blockedBy,
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveDraft);
    _descriptionController.removeListener(_saveDraft);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _saveDraft();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(taskRepositoryProvider);

      if (_isEditing) {
        await repository.updateTask(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          status: _status,
          blockedBy: _blockedBy ?? '',
        );
      } else {
        await repository.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          status: _status,
          blockedBy: _blockedBy,
        );
      }

      // Clear draft on success
      await ref.read(draftServiceProvider).clearDraft(_draftId);

      // Refresh task list
      ref.read(taskListProvider.notifier).loadTasks();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Task updated successfully!'
                  : 'Task created successfully!',
            ),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskListProvider);
    final availableTasks = taskState.tasks
        .where((t) => t.id != widget.task?.id)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text(
          _isEditing ? 'Edit Task' : 'Create Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              _buildLabel('Title *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter task title...',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length > 200) {
                    return 'Title must be under 200 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description field
              _buildLabel('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter task description...',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              // Due date picker
              _buildLabel('Due Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: _dueDate != null
                            ? AppTheme.primaryColor
                            : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _dueDate != null
                            ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                            : 'Select due date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? Colors.white
                              : Colors.white38,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white38,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status dropdown
              _buildLabel('Status'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  dropdownColor: AppTheme.darkCard,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: TaskStatusConstants.all.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                      _saveDraft();
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Blocked by selector
              _buildLabel('Blocked By'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String?>(
                  initialValue: availableTasks.any((t) => t.id == _blockedBy)
                      ? _blockedBy
                      : null,
                  dropdownColor: AppTheme.darkCard,
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint: const Text(
                    'None (not blocked)',
                    style: TextStyle(color: Colors.white38),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        'None',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ...availableTasks.map(
                      (task) => DropdownMenuItem<String?>(
                        value: task.id,
                        child: Text(
                          task.title,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _blockedBy = value);
                    _saveDraft();
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Color _getStatusColor(String status) {
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
