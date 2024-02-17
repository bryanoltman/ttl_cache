// ignore_for_file: avoid_print

import 'package:ttl_cache/ttl_cache.dart';

Future<void> main() async {
  print('creating cache with default TTL of 1 second');
  final cache = TtlCache<String, String>(
    defaultTtl: const Duration(seconds: 1),
  );

  print('inserting entries:');
  print('foo: bar (default TTL)');
  print('hello: world (2 second TTL)');
  print('');

  cache['foo'] = 'bar';
  cache.set('hello', 'world', ttl: const Duration(seconds: 2));

  print('initial state:');
  print('foo: ${cache['foo']}');
  print('hello: ${cache.get('hello')}');
  print('');

  await Future<void>.delayed(const Duration(seconds: 1));

  print('after 1 second:');
  print('foo: ${cache['foo']}');
  print('hello: ${cache.get('hello')}');
  print('');

  await Future<void>.delayed(const Duration(seconds: 1));

  print('after 2 seconds:');
  print('foo: ${cache['foo']}');
  print('hello: ${cache.get('hello')}');
}
