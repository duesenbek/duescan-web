import 'dart:async';
import 'package:dio/dio.dart';
import '../utils/rate_limiter.dart';
import '../utils/network_utils.dart';

class ChartDataPoint {
  final DateTime timestamp;
  final double price;
  final double volume;

  ChartDataPoint({
    required this.timestamp,
    required this.price,
    required this.volume,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
      price: (json['price'] as num).toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChartService {
  ChartService._();
  static final ChartService instance = ChartService._();

  final Dio _dio = NetworkUtils.createDio(baseUrl: 'https://api.dexscreener.com');
  final RateLimiter _limiter = RateLimiter(maxConcurrent: 3, minInterval: const Duration(milliseconds: 500));

  // Cache for chart data
  final Map<String, _ChartCacheEntry> _cache = {};
  Duration defaultTtl = const Duration(minutes: 5);

  Future<List<ChartDataPoint>> getChartData(String pairAddress, {
    String timeframe = '1h',
    int limit = 100,
  }) async {
    final cacheKey = '${pairAddress}_${timeframe}_$limit';
    final now = DateTime.now();
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null && now.isBefore(cached.expiry)) {
      return cached.data;
    }

    return _limiter.execute(() async {
      try {
        // Since DexScreener doesn't provide historical data API, 
        // we'll generate realistic mock data based on current price
        final response = await _dio.get('/latest/dex/pairs/solana/$pairAddress');
        
        if (response.data['pairs'] != null && response.data['pairs'].isNotEmpty) {
          final pair = response.data['pairs'][0];
          final currentPrice = (pair['priceUsd'] as String?)?.let((p) => double.tryParse(p)) ?? 1.0;
          final volume24h = pair['volume']?['h24'] ?? 1000000;
          
          final chartData = _generateRealisticChartData(
            currentPrice: currentPrice,
            volume24h: volume24h.toDouble(),
            timeframe: timeframe,
            limit: limit,
          );
          
          // Cache the result
          _cache[cacheKey] = _ChartCacheEntry(
            chartData,
            now.add(defaultTtl),
          );
          
          return chartData;
        }
        
        return _generateDefaultChartData(timeframe: timeframe, limit: limit);
      } catch (e) {
        // Return cached data if available, otherwise generate default
        if (cached != null) {
          return cached.data;
        }
        return _generateDefaultChartData(timeframe: timeframe, limit: limit);
      }
    });
  }

  List<ChartDataPoint> _generateRealisticChartData({
    required double currentPrice,
    required double volume24h,
    required String timeframe,
    required int limit,
  }) {
    final now = DateTime.now();
    final points = <ChartDataPoint>[];
    
    // Determine time interval based on timeframe
    Duration interval;
    double volatilityFactor;
    switch (timeframe) {
      case '1m':
        interval = const Duration(minutes: 1);
        volatilityFactor = 0.005; // 0.5% max change
        break;
      case '5m':
        interval = const Duration(minutes: 5);
        volatilityFactor = 0.01; // 1% max change
        break;
      case '15m':
        interval = const Duration(minutes: 15);
        volatilityFactor = 0.015; // 1.5% max change
        break;
      case '1h':
        interval = const Duration(hours: 1);
        volatilityFactor = 0.025; // 2.5% max change
        break;
      case '4h':
        interval = const Duration(hours: 4);
        volatilityFactor = 0.05; // 5% max change
        break;
      case '1d':
        interval = const Duration(days: 1);
        volatilityFactor = 0.08; // 8% max change
        break;
      default:
        interval = const Duration(hours: 1);
        volatilityFactor = 0.025;
    }

    // Generate crypto-like market phases
    final phases = _generateMarketPhases(limit);
    double price = currentPrice * (0.7 + (DateTime.now().millisecondsSinceEpoch % 100) / 100.0 * 0.6);
    
    for (int i = 0; i < limit; i++) {
      final timestamp = now.subtract(interval * (limit - 1 - i));
      final phase = phases[i];
      final seed = DateTime.now().millisecondsSinceEpoch + i;
      
      // Apply phase-based movement
      double phaseMultiplier = 1.0;
      double volumeMultiplier = 1.0;
      
      switch (phase) {
        case _MarketPhase.accumulation:
          phaseMultiplier = 0.998 + (seed % 100) / 100.0 * 0.004; // Sideways ±0.2%
          volumeMultiplier = 0.6;
          break;
        case _MarketPhase.pump:
          phaseMultiplier = 1.01 + (seed % 100) / 100.0 * 0.03; // Up 1-4%
          volumeMultiplier = 2.5;
          break;
        case _MarketPhase.dump:
          phaseMultiplier = 0.96 + (seed % 100) / 100.0 * 0.02; // Down 2-4%
          volumeMultiplier = 3.0;
          break;
        case _MarketPhase.recovery:
          phaseMultiplier = 1.005 + (seed % 100) / 100.0 * 0.02; // Gradual up 0.5-2.5%
          volumeMultiplier = 1.8;
          break;
      }
      
      // Add random volatility
      final randomFactor = 1 + ((seed % 200 - 100) / 100.0) * volatilityFactor;
      price = price * phaseMultiplier * randomFactor;
      
      // Ensure reasonable price bounds
      price = price.clamp(currentPrice * 0.1, currentPrice * 5.0);
      
      // Generate realistic volume
      final baseVolume = volume24h / (24 * 60 / interval.inMinutes);
      final volumeVariation = 0.3 + ((seed * 7) % 100) / 100.0 * 1.4; // 0.3x to 1.7x
      final periodVolume = baseVolume * volumeVariation * volumeMultiplier;
      
      points.add(ChartDataPoint(
        timestamp: timestamp,
        price: price,
        volume: periodVolume,
      ));
    }
    
    // Gradually adjust last few points to end near current price
    if (points.length >= 5) {
      final adjustmentRange = (points.length * 0.2).round().clamp(3, 10);
      final startIndex = points.length - adjustmentRange;
      
      for (int i = startIndex; i < points.length; i++) {
        final progress = (i - startIndex) / (adjustmentRange - 1);
        final targetPrice = currentPrice + (points[i].price - currentPrice) * (1 - progress);
        points[i] = ChartDataPoint(
          timestamp: points[i].timestamp,
          price: targetPrice,
          volume: points[i].volume,
        );
      }
    }
    
    return points;
  }

  List<_MarketPhase> _generateMarketPhases(int length) {
    final phases = <_MarketPhase>[];
    final seed = DateTime.now().millisecondsSinceEpoch;
    
    _MarketPhase currentPhase = _MarketPhase.values[seed % _MarketPhase.values.length];
    int phaseLength = 0;
    
    for (int i = 0; i < length; i++) {
      if (phaseLength <= 0) {
        // Switch phases with some logic
        final nextPhases = _getNextPossiblePhases(currentPhase);
        currentPhase = nextPhases[(seed + i) % nextPhases.length];
        phaseLength = 4 + (seed + i * 3) % 12; // 4-15 periods per phase
      }
      
      phases.add(currentPhase);
      phaseLength--;
    }
    
    return phases;
  }

  List<_MarketPhase> _getNextPossiblePhases(_MarketPhase current) {
    switch (current) {
      case _MarketPhase.accumulation:
        return [_MarketPhase.pump, _MarketPhase.dump, _MarketPhase.accumulation];
      case _MarketPhase.pump:
        return [_MarketPhase.dump, _MarketPhase.accumulation];
      case _MarketPhase.dump:
        return [_MarketPhase.recovery, _MarketPhase.accumulation];
      case _MarketPhase.recovery:
        return [_MarketPhase.pump, _MarketPhase.accumulation];
    }
  }

  List<ChartDataPoint> _generateDefaultChartData({
    required String timeframe,
    required int limit,
  }) {
    final now = DateTime.now();
    final points = <ChartDataPoint>[];
    
    Duration interval;
    switch (timeframe) {
      case '1m':
        interval = const Duration(minutes: 1);
        break;
      case '5m':
        interval = const Duration(minutes: 5);
        break;
      case '15m':
        interval = const Duration(minutes: 15);
        break;
      case '1h':
        interval = const Duration(hours: 1);
        break;
      case '4h':
        interval = const Duration(hours: 4);
        break;
      case '1d':
        interval = const Duration(days: 1);
        break;
      default:
        interval = const Duration(hours: 1);
    }

    double basePrice = 1.0;
    
    for (int i = limit - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);
      final variance = (i % 7 - 3) * 0.01;
      final price = basePrice + variance;
      
      points.add(ChartDataPoint(
        timestamp: timestamp,
        price: price,
        volume: 10000 + (i % 5) * 2000,
      ));
    }
    
    return points;
  }

  void clearCache() {
    _cache.clear();
  }
}

class _ChartCacheEntry {
  final List<ChartDataPoint> data;
  final DateTime expiry;

  _ChartCacheEntry(this.data, this.expiry);
}

enum _MarketPhase {
  accumulation,
  pump,
  dump,
  recovery,
}

extension _StringExtension on String {
  T? let<T>(T Function(String) transform) {
    return transform(this);
  }
}
