import 'dart:typed_data';

/// Global singleton cache for decoded DNG images.
/// Stores decoded JPG bytes so each image is only downloaded + decoded once.
class DngCache {
  DngCache._();
  static final DngCache instance = DngCache._();

  // Decoded bytes — ready to display
  final Map<String, Uint8List> _cache = {};

  // In-progress futures — shared so multiple callers wait on same download
  final Map<String, Future<Uint8List?>> _loading = {};

  bool hasCache(String url) => _cache.containsKey(url);
  bool isLoading(String url) => _loading.containsKey(url);
  Uint8List? getBytes(String url) => _cache[url];

  /// If already cached → returns bytes immediately.
  /// If already loading → joins the existing future (no duplicate download).
  /// Otherwise → starts a new load using [loader].
  Future<Uint8List?> getOrStartLoad(String url, Future<Uint8List?> Function() loader) async {
    // Already decoded — instant return
    if (_cache.containsKey(url)) return _cache[url];

    // Already downloading — share the same future
    if (_loading.containsKey(url)) return _loading[url];

    // Start new download
    final future = loader();
    _loading[url] = future;

    final result = await future;
    _loading.remove(url);

    if (result != null && result.isNotEmpty) {
      _cache[url] = result;
    }

    return result;
  }

  /// Remove a cached entry to free memory
  void removeCache(String url) {
    _cache.remove(url);
    _loading.remove(url);
  }

  void clear() {
    _cache.clear();
    _loading.clear();
  }
}