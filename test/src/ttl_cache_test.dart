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

          expect(cache['foo'], equals('bar'));
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), equals(fooExpiration));
          expect(cache.getExpiration('hello'), equals(helloExpiration));

          time = time.add(Duration(seconds: 1));
          // Both entries should still be in the cache. 'foo' is at but not past
          // its expiration time.
          expect(cache['foo'], equals('bar'));
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), equals(fooExpiration));
          expect(cache.getExpiration('hello'), equals(helloExpiration));

          time = time.add(Duration(seconds: 1));
          // 'foo' should be expired now, but 'hello' should still be in the
          // cache.
          expect(cache['foo'], isNull);
          expect(cache.get('hello'), equals('world'));
          expect(cache.getExpiration('foo'), isNull);
          expect(cache.getExpiration('hello'), equals(helloExpiration));

          time = time.add(Duration(seconds: 1));
          // Both keys should be expired now.
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
  });
}
