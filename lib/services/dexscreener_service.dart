import 'dart:async';
import 'package:dio/dio.dart';
import '../models/token.dart';
import '../models/pair.dart';
import '../utils/rate_limiter.dart';
import '../utils/network_utils.dart';

/// Dexscreener API client with caching, retries, and rate limiting.
class DexscreenerService {
  DexscreenerService._();
  static final DexscreenerService instance = DexscreenerService._();
  // Static wrappers for backward compatibility with existing code
  static Future<List<DexsToken>> getSolanaPairsStatic({int limit = 100}) => instance.getSolanaPairs(limit: limit);
  static Future<List<DexsToken>> searchStatic(String query, {String chainId = 'solana'}) => instance.search(query, chainId: chainId);

  final Dio _dio = NetworkUtils.createDio(baseUrl: 'https://api.dexscreener.com');
  final RateLimiter _limiter = RateLimiter(maxConcurrent: 6, minInterval: const Duration(milliseconds: 200));

  // In-memory cache with TTL
  final Map<String, _CacheEntry> _cache = {};
  Duration defaultTtl = const Duration(seconds: 60);

  Future<T> _get<T>(String path, {
    Map<String, dynamic>? query,
    Duration? ttl,
    required T Function(dynamic data) parser,
  }) async {
    final cacheKey = '$path?${(query ?? {}).entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final now = DateTime.now();
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null && now.isBefore(cached.expiry)) {
      return parser(cached.data);
    }

    return _limiter.execute(() async {
      try {
        final response = await _dio.get(path, queryParameters: query);
        final parsed = parser(response.data);
        
        // Cache the result
        _cache[cacheKey] = _CacheEntry(
          response.data,
          now.add(ttl ?? defaultTtl),
        );
        
        return parsed;
      } catch (e) {
        // If we have stale cache, return it on error
        if (cached != null) {
          return parser(cached.data);
        }
        rethrow;
      }
    });
  }

  // GET /token-profiles/latest/v1
  Future<List<TokenProfile>> fetchLatestTokenProfiles() async {
    return _get<List<TokenProfile>>(
      '/token-profiles/latest/v1',
      parser: (data) {
        final items = (data['profiles'] as List?) ?? const [];
        return items.map((e) => TokenProfile.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  // Search pairs by query using /latest/dex/search
  Future<List<Pair>> fetchPairsForChain(String chainId, {String? query, int page = 1, int pageSize = 50}) async {
    // Use different search strategies based on query
    String searchQuery;
    if (query?.isNotEmpty == true) {
      searchQuery = query!;
    } else {
      // For trending, search for multiple popular tokens to get variety
      final popularTokens = ['SOL', 'USDC', 'USDT', 'RAY', 'SRM', 'ORCA', 'MNGO'];
      searchQuery = popularTokens[DateTime.now().millisecondsSinceEpoch % popularTokens.length];
    }
    
    final res = await _get<List<Pair>>(
      '/latest/dex/search',
      query: {
        'q': searchQuery,
      },
      parser: (data) {
        final items = (data['pairs'] as List?) ?? const [];
        
        // Filter by chainId if specified
        final filteredItems = chainId.isNotEmpty 
            ? items.where((e) {
                final pair = e as Map<String, dynamic>;
                final pairChainId = pair['chainId'] as String?;
                return pairChainId == chainId;
              }).toList()
            : items;
        
        
        final list = <Pair>[];
        for (final item in filteredItems) {
          try {
            final pair = Pair.fromDex(item as Map<String, dynamic>, chainId: chainId);
            list.add(pair);
          } catch (e) {
          }
        }
        
        // Sort by volume for trending when no specific query
        if (query?.isEmpty != false) {
          list.sort((a, b) => (b.volume24h ?? 0).compareTo(a.volume24h ?? 0));
        }
        
        
        // pagination client-side
        final start = (page - 1) * pageSize;
        final end = (start + pageSize).clamp(0, list.length);
        if (start >= list.length) return <Pair>[];
        return list.sublist(start, end);
      },
    );
    return res;
  }

  // GET /latest/dex/pairs/{chainId}/{pairId}
  Future<Pair> fetchPairDetails(String chainId, String pairId) async {
    return _get<Pair>(
      '/latest/dex/pairs/$chainId/$pairId',
      parser: (data) {
        final pairs = (data['pairs'] as List?) ?? const [];
        if (pairs.isEmpty) {
          return Pair(
            chainId: chainId,
            pairId: pairId,
            baseAddress: '',
            baseToken: const Token(address: '', symbol: '', name: ''),
            quoteToken: const Token(address: '', symbol: '', name: ''),
            quoteAddress: '',
            quoteSymbol: '',
            quoteName: '',
          );
        }
        return Pair.fromDex(pairs.first as Map<String, dynamic>, chainId: chainId);
      },
    );
  }

  // GET /token-boosts/latest/v1 and /token-boosts/top/v1
  Future<List<TokenBoost>> fetchTokenBoosts({bool top = false}) async {
    final path = top ? '/token-boosts/top/v1' : '/token-boosts/latest/v1';
    return _get<List<TokenBoost>>(
      path,
      parser: (data) {
        final list = (data['boosts'] as List?) ?? (data as List? ?? const []);
        return list.map((e) => TokenBoost.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  // GET /token-pairs/v1/{chainId}/{tokenAddress}
  Future<List<Pair>> fetchTokenPairs(String chainId, String tokenAddress) async {
    return _get<List<Pair>>(
      '/token-pairs/v1/$chainId/$tokenAddress',
      parser: (data) {
        final items = (data['pairs'] as List?) ?? const [];
        return items.map((e) => Pair.fromDex(e as Map<String, dynamic>, chainId: chainId)).toList();
      },
    );
  }

  // ---------------------------
  // Backward-compatible helpers
  // ---------------------------
  /// Search tokens/pairs by symbol/name/address and adapt to DexsToken
  Future<List<DexsToken>> search(String query, {String chainId = 'solana'}) async {
    final pairs = await fetchPairsForChain(chainId, query: query, page: 1, pageSize: 400);
    final tokens = pairs.map(DexsToken.fromPair).toList();
    return _dedupeByAddress(tokens);
  }

  /// Get popular pairs on a chain and adapt to DexsToken
  Future<List<DexsToken>> getSolanaPairs({int limit = 100}) async {
    // Fetch multiple searches to get diverse tokens
    final allTokens = <DexsToken>[];
    final searchTerms = ['SOL', 'USDC', 'USDT', 'RAY', 'SRM', 'ORCA', 'MNGO', 'BONK', 'WIF'];
    
    for (final term in searchTerms) {
      try {
        final list = await fetchPairsForChain('solana', query: term, page: 1, pageSize: 50);
        final tokens = list.map(DexsToken.fromPair).toList();
        allTokens.addAll(tokens);
      } catch (e) {
      }
    }
    
    // Remove duplicates and sort by volume
    final uniqueTokens = _dedupeByAddress(allTokens);
    uniqueTokens.sort((a, b) => (b.volume24h ?? 0).compareTo(a.volume24h ?? 0));
    return uniqueTokens.take(limit).toList();
  }

  List<DexsToken> _dedupeByAddress(List<DexsToken> list) {
    final seen = <String>{};
    final out = <DexsToken>[];
    for (final t in list) {
      if (t.address.isEmpty) continue;
      if (seen.add(t.address)) out.add(t);
    }
    return out;
  }
}

class _CacheEntry {
  final Object data;
  final DateTime expiry;
  _CacheEntry(this.data, this.expiry);
}

class DexsToken {
  final String address; // base token address
  final String symbol;
  final String name;
  final String? logoUri;
  final double? priceUsd;
  final double? change5m;
  final double? change1h;
  final double? change24h;
  final double? liquidityUsd;
  final double? marketCap;
  final double? volume24h;
  final String? pairAddress; // primary pair

  DexsToken({
    required this.address,
    required this.symbol,
    required this.name,
    this.logoUri,
    this.priceUsd,
    this.change5m,
    this.change1h,
    this.change24h,
    this.liquidityUsd,
    this.marketCap,
    this.volume24h,
    this.pairAddress,
  });

  factory DexsToken.fromPair(Pair p) {
    return DexsToken(
      address: p.baseAddress,
      symbol: p.baseSymbol,
      name: p.baseName.isNotEmpty ? p.baseName : p.baseSymbol,
      logoUri: p.baseImageUrl,
      priceUsd: p.priceUsd,
      change5m: p.change5m,
      change1h: p.change1h,
      change24h: p.change24h,
      liquidityUsd: p.liquidityUsd,
      marketCap: p.fdv ?? p.marketCap,
      volume24h: p.volume24h,
      pairAddress: p.pairId,
    );
  }
}
