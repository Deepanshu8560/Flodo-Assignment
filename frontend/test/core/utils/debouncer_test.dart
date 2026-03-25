import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('executes action after specified delay', () async {
      final debouncer = Debouncer(milliseconds: 100);
      bool didExecute = false;

      debouncer.run(() {
        didExecute = true;
      });

      expect(didExecute, isFalse);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(didExecute, isTrue);
    });

    test('cancels previous action if called again within delay', () async {
      final debouncer = Debouncer(milliseconds: 100);
      int executionCount = 0;

      debouncer.run(() {
        executionCount++;
      });

      // Call again immediately
      debouncer.run(() {
        executionCount++;
      });

      await Future.delayed(const Duration(milliseconds: 150));

      // Should have only executed once
      expect(executionCount, equals(1));
    });
  });
}
