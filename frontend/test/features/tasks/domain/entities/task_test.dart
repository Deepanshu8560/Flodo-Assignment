import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/tasks/domain/entities/task.dart';

void main() {
  group('Task mapping & properties', () {
    test('fromJson & toJson handle blocked_by properly', () {
      final json = {
        'id': '123',
        'title': 'Test title',
        'description': '',
        'status': 'To-Do',
        'blocked_by': '456',
        'is_blocked': true,
        'blocked_by_title': 'Other Task',
      };

      final task = Task.fromJson(json);

      expect(task.id, '123');
      expect(task.title, 'Test title');
      expect(task.blockedBy, '456');
      expect(task.isBlocked, true);
      expect(task.blockedByTitle, 'Other Task');

      final outputJson = task.toJson();
      expect(outputJson['title'], 'Test title');
      expect(outputJson['blocked_by'], '456');
    });

    test('isBlocked gets correctly parsed from missing fields', () {
      final json = {
        'id': '123',
        'title': 'Test title',
        'description': '',
        'status': 'To-Do',
      };

      final task = Task.fromJson(json);

      expect(task.blockedBy, null);
      expect(task.isBlocked, false);
      expect(task.blockedByTitle, null);
    });
  });
}
