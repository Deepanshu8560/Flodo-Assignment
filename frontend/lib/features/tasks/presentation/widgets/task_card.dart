import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';

/// Task card widget displaying task info with blocked task UI states.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isDeleting;
  final String searchQuery;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    this.isDeleting = false,
    this.searchQuery = '',
  });

  Color _statusColor() {
    switch (task.status) {
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

  IconData _statusIcon() {
    switch (task.status) {
      case TaskStatusConstants.toDo:
        return Icons.radio_button_unchecked;
      case TaskStatusConstants.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatusConstants.done:
        return Icons.check_circle_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Widget _buildHighlightedText(
    String text,
    TextStyle style, {
    int? maxLines,
    TextOverflow? overflow,
  }) {
    if (searchQuery.isEmpty || !text.toLowerCase().contains(searchQuery.toLowerCase())) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    
    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + searchQuery.length),
        style: style.copyWith(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          color: Colors.white,
        ),
      ));
      
      start = indexOfMatch + searchQuery.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(style: style, children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = task.isBlocked;

    return AnimatedOpacity(
      opacity: isBlocked ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isBlocked
                ? AppTheme.darkCard.withValues(alpha: 0.5)
                : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isBlocked
                  ? AppTheme.blockedColor.withValues(alpha: 0.3)
                  : _statusColor().withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isBlocked ? AppTheme.blockedColor : _statusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isBlocked ? AppTheme.blockedColor : _statusColor())
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBlocked ? 'Blocked' : task.status,
                        style: TextStyle(
                          color: isBlocked ? AppTheme.blockedColor : _statusColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isBlocked)
                      const Icon(
                        Icons.lock_rounded,
                        color: AppTheme.blockedColor,
                        size: 18,
                      ),
                    isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            color: Colors.white38,
                            onPressed: () => _showDeleteConfirmation(context),
                            visualDensity: VisualDensity.compact,
                          ),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                _buildHighlightedText(
                  task.title,
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isBlocked ? Colors.white54 : Colors.white,
                    decoration: task.status == TaskStatusConstants.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildHighlightedText(
                    task.description,
                    TextStyle(
                      fontSize: 13,
                      color: isBlocked ? Colors.white30 : Colors.white60,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isBlocked && task.blockedByTitle != null) ...[
                      Icon(
                        Icons.block_rounded,
                        size: 13,
                        color: AppTheme.blockedColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Blocked by: ${task.blockedByTitle}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.blockedColor.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
