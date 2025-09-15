import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/dexscreener_service.dart';
import '../services/ai_service.dart';
import '../models/pair.dart';

enum SortMode { volumeDesc, marketCapDesc, liquidityDesc, priceChangeDesc }

class TokensState {
  final List<Pair> trending;
  final List<Pair> allTokens;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final SortMode sortMode;

  const TokensState({
    this.trending = const [],
    this.allTokens = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.sortMode = SortMode.volumeDesc,
  });

  TokensState copyWith({
    List<Pair>? trending,
    List<Pair>? allTokens,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    SortMode? sortMode,
  }) {
    return TokensState(
      trending: trending ?? this.trending,
      allTokens: allTokens ?? this.allTokens,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sortMode: sortMode ?? this.sortMode,
    );
  }
}

class TrendingTokensState {
  final List<Pair> trending;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const TrendingTokensState({
    this.trending = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });
}

class TrendingTokensNotifier extends AsyncNotifier<TrendingTokensState> {
  Timer? _refreshTimer;
  final _aiService = const AiService();

  @override
  TrendingTokensState build() {
    _loadCachedData();
    refresh();
    startLiveUpdates(); // Always start live updates
    return const TrendingTokensState();
  }

  void _setupAutoRefresh() {
    _refreshTimer?.cancel();
    // Auto-refresh every 60 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      refresh();
    });
  }

  Future<List<Pair>> _fetchTrending() async {
    try {
      // Load cached snapshot first
      final cached = await _loadCachedTrending();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(TrendingTokensState(trending: cached));
      }

      // Fetch fresh data
      final tokens = await DexscreenerService.instance.getSolanaPairs(limit: 100);
      final pairs = tokens.map((t) => Pair(
        chainId: 'solana',
        pairId: t.pairAddress ?? t.address,
        baseAddress: t.address,
        baseToken: Token(
          address: t.address,
          symbol: t.symbol,
          name: t.name,
          imageUrl: t.logoUri,
        ),
        quoteToken: const Token(
          address: '',
          symbol: 'SOL',
          name: 'Solana',
        ),
        baseImageUrl: t.logoUri,
        quoteAddress: '',
        quoteSymbol: 'SOL',
        quoteName: 'Solana',
        priceUsd: t.priceUsd,
        change5m: t.change5m,
        change1h: t.change1h,
        change24h: t.change24h,
        volume24h: t.volume24h,
        liquidityUsd: t.liquidityUsd,
        marketCap: t.marketCap,
        fdv: t.marketCap,
      )).toList();

      // Cache the result
      await _cacheTrending(pairs);
      
      return pairs;
    } catch (e) {
      throw Exception('Failed to fetch trending tokens: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final tokens = await _fetchTrending();
      await _cacheTrending(tokens);
      state = AsyncValue.data(TrendingTokensState(
        trending: tokens,
        lastUpdated: DateTime.now(),
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('trending_snapshot');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
        
        // Use cache if less than 5 minutes old
        if (DateTime.now().difference(timestamp).inMinutes < 5) {
          final tokensData = data['tokens'] as List;
          final tokens = tokensData.map((t) => Pair.fromDex(t, chainId: 'solana')).toList();
          state = AsyncValue.data(TrendingTokensState(trending: tokens));
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<List<Pair>> _loadCachedTrending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('trending_snapshot');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
        // Use cache if less than 5 minutes old
        if (DateTime.now().difference(timestamp).inMinutes < 5) {
          final items = (data['pairs'] as List).cast<Map<String, dynamic>>();
          return items.map((e) => Pair.fromDex(e, chainId: 'solana')).toList();
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    return [];
  }

  Future<void> _cacheTrending(List<Pair> pairs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'pairs': pairs.map((p) => {
          'chainId': p.chainId,
          'pairAddress': p.pairId,
          'baseToken': {
            'address': p.baseAddress,
            'symbol': p.baseToken.symbol,
            'name': p.baseToken.name,
            'imageUrl': p.baseToken.imageUrl,
          },
          'quoteToken': {
            'address': p.quoteAddress,
            'symbol': p.quoteSymbol,
            'name': p.quoteName,
          },
          'priceUsd': p.priceUsd,
          'priceChange': {
            'm5': p.change5m,
            'h1': p.change1h,
            'h24': p.change24h,
          },
          'volume': {'h24': p.volume24h},
          'liquidity': {'usd': p.liquidityUsd},
          'marketCap': p.marketCap,
          'fdv': p.fdv,
        }).toList(),
      };
      await prefs.setString('trending_snapshot', jsonEncode(data));
    } catch (e) {
      // Ignore cache errors
    }
  }

  void startLiveUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60), // Always on live updates
      (_) => refresh(),
    );
  }

  void stopLiveUpdates() {
    _refreshTimer?.cancel();
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
}

class AllTokensNotifier extends AsyncNotifier<List<Pair>> {
  @override
  Future<List<Pair>> build() async {
    return [];
  }

  Future<void> search(String query, {int page = 1, int pageSize = 50}) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pairs = await DexscreenerService.instance.fetchPairsForChain(
        'solana',
        query: query,
        page: page,
        pageSize: pageSize,
      );
      return pairs;
    });
  }

  Future<void> loadMore(String query, int nextPage) async {
    final current = state.value ?? [];
    try {
      final morePairs = await DexscreenerService.instance.fetchPairsForChain(
        'solana',
        query: query,
        page: nextPage,
        pageSize: 50,
      );
      state = AsyncValue.data([...current, ...morePairs]);
    } catch (e) {
      // Keep current state on error
    }
  }
}

final trendingTokensProvider = AsyncNotifierProvider<TrendingTokensNotifier, TrendingTokensState>(() {
  return TrendingTokensNotifier();
});

final allTokensProvider = AsyncNotifierProvider<AllTokensNotifier, List<Pair>>(() {
  return AllTokensNotifier();
});
