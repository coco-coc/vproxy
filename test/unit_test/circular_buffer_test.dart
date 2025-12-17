import 'package:flutter_test/flutter_test.dart';
import 'package:vx/common/circuler_buffer.dart';

void main() {
  group('CircularBuffer', () {
    test('should initialize empty', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      expect(buffer.length, equals(0));
      expect(buffer.isEmpty, isTrue);
      expect(buffer.toList(), isEmpty);
    });

    test('should add elements up to max size', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);

      expect(buffer.length, equals(3));
      expect(buffer.toList(), equals([1, 2, 3]));
    });

    test('should replace oldest elements when buffer is full', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(4);
      buffer.add(5);

      expect(buffer.length, equals(3));
      expect(buffer.toList(), equals([3, 4, 5]));
    });

    test('should return first element', () {
      final buffer = CircularBuffer<int>(maxSize: 3);

      expect(() => buffer.first, throwsStateError);

      buffer.add(1);
      buffer.add(2);

      expect(buffer.first, equals(1));

      buffer.add(3);
      buffer.add(4);

      expect(buffer.first, equals(2));
    });

    test('should access elements by index', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(4);

      expect(buffer[0], equals(2));
      expect(buffer[1], equals(3));
      expect(buffer[2], equals(4));
      expect(buffer[3], isNull);
      expect(buffer[-1], isNull);
    });

    test('should clear buffer', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);

      buffer.clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, equals(0));
      expect(buffer.toList(), isEmpty);
    });

    test('should find index backwards', () {
      final buffer = CircularBuffer<int>(maxSize: 5);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(2);
      buffer.add(1);

      expect(buffer.indexOfBackwards(1), equals(4));
      expect(buffer.indexOfBackwards(2), equals(3));
      expect(buffer.indexOfBackwards(3), equals(2));
      expect(buffer.indexOfBackwards(4), equals(-1));
    });

    test('should iterate over elements in order', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(4);

      final iterator = buffer.iterator;
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(2));
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(3));
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, equals(4));
      expect(iterator.moveNext(), isFalse);
    });

    test('should handle null elements', () {
      final buffer = CircularBuffer<int?>(maxSize: 3);
      buffer.add(null);
      buffer.add(1);
      buffer.add(null);

      expect(buffer.length, equals(3));
      expect(buffer.toList(), equals([null, 1, null]));
    });

    test('should maintain correct order when wrapping around', () {
      final buffer = CircularBuffer<int>(maxSize: 3);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(4);
      buffer.add(5);
      buffer.add(6);

      expect(buffer.toList(), equals([4, 5, 6]));
      expect(buffer[0], equals(4));
      expect(buffer[1], equals(5));
      expect(buffer[2], equals(6));
    });
  });
}
