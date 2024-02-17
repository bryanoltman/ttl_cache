// ignore_for_file: prefer_const_constructors
import 'package:test/test.dart';
import 'package:ttl_cache/ttl_cache.dart';

void main() {
  group('TtlCache', () {
    test('can be instantiated', () {
      expect(TtlCache(), isNotNull);
    });
  });
}
