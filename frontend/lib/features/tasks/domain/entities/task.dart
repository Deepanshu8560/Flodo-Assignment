import 'package:equatable/equatable.dart';

/// Task entity - Domain layer representation of a Task.
class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String status;
  final String? blockedBy;
  final String? blockedByTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    required this.status,
    this.blockedBy,
    this.blockedByTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isBlocked => blockedBy != null && blockedBy!.isNotEmpty;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? blockedBy,
    String? blockedByTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedBy: blockedBy ?? this.blockedBy,
      blockedByTitle: blockedByTitle ?? this.blockedByTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, dueDate, status, blockedBy, blockedByTitle, createdAt, updatedAt];
}
