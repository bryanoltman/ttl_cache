# ttl_cache

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A simple Dart key-value store with optional entry expiration.

## Usage

A simple usage example:

```dart
import 'package:ttl_cache/ttl_cache.dart';

void main() {
  final cache = TtlCache<String, int>(defaultTtl: Duration(seconds: 1));

  // Set 'a' and 'b' with a default TTL of 1 second.
  // These lines are equivalent.
  cache['a'] = 1;
  cache.set('b', 2);

  // Set 'c' with a TTL of 3 seconds.
  cache.set('c', 3, ttl: Duration(seconds: 3));

  // Set 'd' with no TTL. This entry will remain in the cache until it is
  // manually removed.
  cache.set('d', 4, ttl: null);

  print(cache['a']); // 1
  print(cache['b']); // 2
  print(cache['c']); // 3
  print(cache['d']); // 4

  // Entries with the default TTL will have expired. 'c' has a TTL of 3 seconds
  // and will still be available.
  Future.delayed(Duration(seconds: 2), () {
    print(cache['a']); // null
    print(cache['b']); // null
    print(cache['c']); // 3
    print(cache['d']); // 4
  });

  // All entries from above with TTLs will have expired. 'd' has no TTL and will
  // still be available.
  Future.delayed(Duration(seconds: 4), () {
    // 'a' and 'b' will still be null
    print(cache['c']); // null
    print(cache['d']); // 4
  });
}
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[mason_link]: https://github.com/felangel/mason
