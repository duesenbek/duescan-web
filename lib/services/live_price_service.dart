import 'dart:async';

import 'dex_data_service.dart';

/// Live price updater that periodically fetches current prices for a set of mints
/// and computes a rolling 5-minute percentage change per mint.
class LivePriceService {
  LivePriceService._internal();
  static final LivePriceService _instance = LivePriceService._internal();
  static LivePriceService get I => _instance;

  // Poll interval
  Duration interval = const Duration(seconds: 15);

  // Max age for 5m window
  static const Duration window = Duration(minutes: 5);

  // Registered mints to track
  final Set<String> _mints = {};

  // Historical price points: mint -> list of (timestamp, price)
  final Map<String, List<_P>> _history = {};

  Timer? _timer;

  // Stream of computed 5m change per mint
  final StreamController<Map<String, double>> _change5mController = StreamController.broadcast();
  Stream<Map<String, double>> get change5mStream => _change5mController.stream;

  /// Start polling; no-op if already running
  void start() {
    _timer ??= Timer.periodic(interval, (_) => _tick());
  }

  /// Stop polling and clear listeners (keeps history)
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Pause polling without clearing tracked state/history
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resume polling using current interval
  void resume() {
    start();
  }

  /// Register mints to track
  void registerMints(Iterable<String> mints) {
    _mints.addAll(mints.where((m) => m.isNotEmpty));
  }

  /// Unregister mints
  void unregisterMints(Iterable<String> mints) {
    for (final m in mints) {
      _mints.remove(m);
    }
  }

  /// Replace the entire tracked set atomically
  void setTrackedMints(Iterable<String> mints) {
    _mints
      ..clear()
      ..addAll(mints.where((m) => m.isNotEmpty));
  }

  /// Adjust polling interval; restarts timer if already running
  void setInterval(Duration newInterval) {
    if (newInterval == interval) return;
    interval = newInterval;
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      start();
    }
  }

  Future<void> _tick() async {
    if (_mints.isEmpty) return;
    try {
      final now = DateTime.now();
      final response = await DexscreenerService.instance.getTrendingPairs();

      // Append current point and prune old
      for (final entry in response.entries) {
        final mint = entry.key;
        final price = entry.value.price;
        final list = _history.putIfAbsent(mint, () => <_P>[]);
        list.add(_P(now, price));
        _prune(list, now);
      }

      // Compute 5m change
      final changes = <String, double>{};
      for (final mint in _mints) {
        final list = _history[mint];
        if (list == null || list.length < 2) continue;
        final old = _priceAtOrBefore(list, now.subtract(window));
        final latest = list.last.price;
        if (old != null && old > 0) {
          changes[mint] = ((latest - old) / old) * 100.0;
        }
      }

      if (changes.isNotEmpty) {
        _change5mController.add(changes);
      }
    } catch (_) {
      // swallow errors to avoid stream interruptions
    }
  }

  void _prune(List<_P> list, DateTime now) {
    final cutoff = now.subtract(window + const Duration(minutes: 1)); // keep a little extra
    while (list.isNotEmpty && list.first.t.isBefore(cutoff)) {
      list.removeAt(0);
    }
  }

  double? _priceAtOrBefore(List<_P> list, DateTime t) {
    // list is in chronological order
    double? lastSeen;
    for (final p in list) {
      if (p.t.isAfter(t)) break;
      lastSeen = p.price;
    }
    return lastSeen ?? (list.isNotEmpty ? list.first.price : null);
  }
}

class _P {
  final DateTime t;
  final double price;
  _P(this.t, this.price);
}
