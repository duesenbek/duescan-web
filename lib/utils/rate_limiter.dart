import 'dart:async';

/// Simple concurrent + interval rate limiter.
class RateLimiter {
  final int maxConcurrent;
  final Duration minInterval;

  int _current = 0;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  final _queue = <_Job>[];

  RateLimiter({this.maxConcurrent = 6, this.minInterval = const Duration(milliseconds: 200)});

  Future<T> execute<T>(Future<T> Function() task) {
    final job = _Job<T>(task);
    _queue.add(job);
    _pump();
    return job.c.future;
  }

  Future<T> schedule<T>(Future<T> Function() task) {
    return execute(task);
  }

  void _pump() {
    if (_queue.isEmpty) return;
    if (_current >= maxConcurrent) return;
    final now = DateTime.now();
    if (now.difference(_last) < minInterval) {
      final wait = minInterval - now.difference(_last);
      Timer(wait, _pump);
      return;
    }
    final job = _queue.removeAt(0);
    _current++;
    _last = DateTime.now();
    job.run().whenComplete(() {
      _current--;
      _pump();
    });
  }
}

class _Job<T> {
  final Completer<T> c = Completer<T>();
  final Future<T> Function() task;
  _Job(this.task);
  Future<void> run() async {
    try {
      c.complete(await task());
    } catch (e, st) {
      c.completeError(e, st);
    }
  }
}
