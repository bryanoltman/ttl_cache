// ignore_for_file: prefer_const_constructors

import 'package:clock/clock.dart';
import 'package:test/test.dart';
import 'package:ttl_cache/ttl_cache.dart';

void main() {
  group('TtlCache', () {
    group('with no TTL set', () {
      test('entries never expire', () {
        var time = DateTime(2021);
        withClock(Clock(() => time), () {
          final cache = TtlCache<String, String>();
          cache['foo'] = 'bar';
          cache.set('hello', 'world');

          expect(cache['foo'], equals('bar'));
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), isNull);
          expect(cache.getExpiration('hello'), isNull);

          time = time.add(Duration(days: 99999));
          // Advancing a long time into the future should not cause the entries
          // to expire.
          expect(cache['foo'], equals('bar'));
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), isNull);
          expect(cache.getExpiration('hello'), isNull);
        });
      });
    });

    group('with a TTL set', () {
      test('entries expire after the TTL', () {
        var time = DateTime(2021);
        withClock(Clock(() => time), () {
          final cache =
              TtlCache<String, String>(defaultTtl: Duration(seconds: 1));

          cache['foo'] = 'bar';
          cache.set('hello', 'world', ttl: Duration(seconds: 2));

          final fooExpiration = time.add(Duration(seconds: 1));
          final helloExpiration = time.add(Duration(seconds: 2));

          expect(cache.keys, equals(['foo', 'hello']));
          expect(cache.values, equals(['bar', 'world']));
          expect(cache['foo'], equals('bar'));
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), equals(fooExpiration));
          expect(cache.getExpiration('hello'), equals(helloExpiration));

          time = time.add(Duration(seconds: 1));
          // 'foo' is at its expiration time and should no longer in the cache.
          // 'hello' is not yet expired and should still be in the cache.
          expect(cache.keys, equals(['hello']));
          expect(cache.values, equals(['world']));
          expect(cache['foo'], isNull);
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), isNull);
          expect(cache.getExpiration('hello'), equals(helloExpiration));

          time = time.add(Duration(seconds: 1));
          // Both keys should be expired now.
          expect(cache.keys, isEmpty);
          expect(cache.values, isEmpty);
          expect(cache['foo'], isNull);
          expect(cache.get('hello'), isNull);
          expect(cache.getExpiration('foo'), isNull);
          expect(cache.getExpiration('hello'), isNull);
        });
      });

      test('can remove an entry with an expiration date in the future', () {
        final time = DateTime(2021);
        withClock(Clock.fixed(time), () {
          final cache = TtlCache<int, String>()
            ..set(1, 'one', ttl: Duration(seconds: 1));
          final expirationDate = time.add(Duration(seconds: 1));

          expect(cache.get(1), equals('one'));
          expect(cache.getExpiration(1), equals(expirationDate));

          cache.remove(1);

          expect(cache.get(1), isNull);
          expect(cache.getExpiration(1), isNull);
        });
      });
    });

    group('containsKey', () {
      test('returns true if entry exists and has not expired', () {
        var time = DateTime(2021);
        withClock(Clock(() => time), () {
          final cache = TtlCache<int, int>(defaultTtl: Duration(minutes: 1));
          cache[1] = 1;
          cache.set(2, 2, ttl: Duration(minutes: 2));

          expect(cache.containsKey(1), isTrue);
          expect(cache.containsKey(2), isTrue);
          expect(cache.containsKey(3), isFalse);

          time = time.add(Duration(minutes: 2));

          expect(cache.containsKey(1), isFalse);
          expect(cache.containsKey(2), isFalse);
          expect(cache.containsKey(3), isFalse);
        });
      });
    });

    group('clear', () {
      test('removes all entries', () {
        final cache = TtlCache<int, int>(defaultTtl: Duration(minutes: 1));
        cache[1] = 1;
        cache.set(2, 2, ttl: Duration(minutes: 2));

        expect(cache.entries, hasLength(2));

        cache.clear();

        expect(cache.entries, isEmpty);
      });
    });
  });
}
