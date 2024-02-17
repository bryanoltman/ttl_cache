import 'package:clock/clock.dart';

/// {@template ttl_cache}
/// A simple key-value store with entry expiration
/// {@endtemplate}
class TtlCache<K, V> {
  /// {@macro ttl_cache}
  TtlCache({this.defaultTtl});

  /// The amount of time before entries are removed from the cache if no TTL is
  /// provided.
  final Duration? defaultTtl;

  /// The backing key-value store.
  final _cache = <K, V>{};

  /// Maps keys to their expiration times.
  final _expirations = <K, DateTime>{};

  /// Associates [key] with [value] in the cache, using [ttl] as the TTL. If
  /// [ttl] is not provided, this cache's [defaultTtl] will be used. Entires
  /// having a null TTL will never expire.
  void set(K key, V value, {Duration? ttl}) {
    _cache[key] = value;

    final effectiveTtl = ttl ?? defaultTtl;
    if (effectiveTtl != null) {
      _expirations[key] = clock.now().add(effectiveTtl);

      // Clean up expired entries after [ttl] has elapsed if needed.
      Future.delayed(effectiveTtl, () => _removeIfExpired(key));
    }
  }

  /// Retrieves the value associated with [key] if it exists and has not
  /// expired.
  V? get(K key) {
    _removeIfExpired(key);
    return _cache[key];
  }

  /// Removes the entry for [key] if it exists.
  void remove(K key) {
    _cache.remove(key);
    _expirations.remove(key);
  }

  /// All entries in the cache.
  Iterable<MapEntry<K, V>> get entries =>
      _cache.entries.where((entry) => !_isExpired(entry.key));

  /// All keys in the cache.
  Iterable<K> get keys => entries.map((entry) => entry.key);

  /// All values in the cache.
  Iterable<V> get values => entries.map((entry) => entry.value);

  /// Returns the expiration time of the entry associated with [key] if the key
  /// exists and has a TTL.
  DateTime? getExpiration(K key) {
    _removeIfExpired(key);
    return _expirations[key];
  }

  /// Looks up the value associated with [key] if it exists and has not expired.
  V? operator [](K key) => get(key);

  /// Associates [key] with [value] in the cache, using [defaultTtl] as the TTL.
  void operator []=(K key, V value) => set(key, value);

  /// Returns true if the entry for [key] exists and has an expiration date in
  /// the past.
  bool _isExpired(K key) {
    final expiration = _expirations[key];
    return expiration != null && clock.now().isAfter(expiration);
  }

  /// Removes the entry for [key] if it exists and has an expiration date in the
  /// past.
  void _removeIfExpired(K key) {
    if (_isExpired(key)) {
      _cache.remove(key);
      _expirations.remove(key);
    }
  }
}
