import '../../domain/entities/task.dart';

/// Task model - Data layer representation with JSON serialization.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description = '',
    super.dueDate,
    required super.status,
    super.blockedBy,
    super.blockedByTitle,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      status: json['status'] as String,
      blockedBy: json['blocked_by'] as String?,
      blockedByTitle: json['blocked_by_title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'status': status,
      'blocked_by': blockedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
    };
    if (dueDate != null) {
      map['due_date'] = dueDate!.toIso8601String().split('T').first;
    }
    if (blockedBy != null) {
      map['blocked_by'] = blockedBy;
    }
    return map;
  }
}
