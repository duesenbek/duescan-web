import 'dart:async';
import 'package:dio/dio.dart';
import '../utils/rate_limiter.dart';
import '../utils/network_utils.dart';

class TokenProfile {
  final String url;
  final String chainId;
  final String tokenAddress;
  final String? icon;
  final String? header;
  final String? description;
  final List<TokenLink> links;

  TokenProfile({
    required this.url,
    required this.chainId,
    required this.tokenAddress,
    this.icon,
    this.header,
    this.description,
    required this.links,
  });

  factory TokenProfile.fromJson(Map<String, dynamic> json) {
    return TokenProfile(
      url: json['url'] as String? ?? '',
      chainId: json['chainId'] as String? ?? '',
      tokenAddress: json['tokenAddress'] as String? ?? '',
      icon: json['icon'] as String?,
      header: json['header'] as String?,
      description: json['description'] as String?,
      links: (json['links'] as List<dynamic>?)
          ?.map((link) => TokenLink.fromJson(link as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class TokenLink {
  final String type;
  final String label;
  final String url;

  TokenLink({
    required this.type,
    required this.label,
    required this.url,
  });

  factory TokenLink.fromJson(Map<String, dynamic> json) {
    return TokenLink(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class TokenProfileService {
  TokenProfileService._();
  static final TokenProfileService instance = TokenProfileService._();

  final Dio _dio = NetworkUtils.createDio(baseUrl: 'https://api.dexscreener.com');
  final RateLimiter _limiter = RateLimiter(maxConcurrent: 3, minInterval: const Duration(seconds: 1));

  // Cache for token profiles
  final Map<String, _TokenProfileCacheEntry> _cache = {};
  Duration defaultTtl = const Duration(hours: 1);

  Future<List<TokenProfile>> getLatestTokenProfiles() async {
    const cacheKey = 'latest_profiles';
    final now = DateTime.now();
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null && now.isBefore(cached.expiry)) {
      return cached.data;
    }

    return _limiter.execute(() async {
      try {
        final response = await _dio.get('/token-profiles/latest/v1');
        
        if (response.data is List) {
          final profiles = (response.data as List)
              .map((item) => TokenProfile.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // Cache the result
          _cache[cacheKey] = _TokenProfileCacheEntry(
            profiles,
            now.add(defaultTtl),
          );
          
          return profiles;
        }
        
        return [];
      } catch (e) {
        // Return cached data if available
        if (cached != null) {
          return cached.data;
        }
        return [];
      }
    });
  }

  Future<String?> getTokenIcon(String tokenAddress, {String chainId = 'solana'}) async {
    final cacheKey = 'icon_${chainId}_$tokenAddress';
    final now = DateTime.now();
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null && now.isBefore(cached.expiry)) {
      return cached.data.isNotEmpty ? cached.data.first.icon : null;
    }

    return _limiter.execute(() async {
      try {
        // First try to get from latest profiles
        final profiles = await getLatestTokenProfiles();
        final profile = profiles.where((p) => 
          p.tokenAddress.toLowerCase() == tokenAddress.toLowerCase() &&
          p.chainId.toLowerCase() == chainId.toLowerCase()
        ).firstOrNull;
        
        if (profile?.icon != null) {
          // Cache the result
          _cache[cacheKey] = _TokenProfileCacheEntry(
            [profile!],
            now.add(defaultTtl),
          );
          return profile.icon;
        }

        // If not found in profiles, try to get from token pairs endpoint
        final response = await _dio.get('/latest/dex/pairs/$chainId/$tokenAddress');
        
        if (response.data['pairs'] != null && response.data['pairs'].isNotEmpty) {
          final pair = response.data['pairs'][0];
          final iconUrl = pair['info']?['imageUrl'] as String?;
          
          if (iconUrl != null) {
            // Create a temporary profile for caching
            final tempProfile = TokenProfile(
              url: '',
              chainId: chainId,
              tokenAddress: tokenAddress,
              icon: iconUrl,
              links: [],
            );
            
            _cache[cacheKey] = _TokenProfileCacheEntry(
              [tempProfile],
              now.add(defaultTtl),
            );
            
            return iconUrl;
          }
        }
        
        return null;
      } catch (e) {
        // Return cached data if available
        if (cached != null && cached.data.isNotEmpty) {
          return cached.data.first.icon;
        }
        return null;
      }
    });
  }

  Future<List<TokenProfile>> getBoostedTokens() async {
    const cacheKey = 'boosted_tokens';
    final now = DateTime.now();
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null && now.isBefore(cached.expiry)) {
      return cached.data;
    }

    return _limiter.execute(() async {
      try {
        final response = await _dio.get('/token-boosts/latest/v1');
        
        if (response.data is List) {
          final profiles = (response.data as List)
              .map((item) => TokenProfile.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // Cache the result
          _cache[cacheKey] = _TokenProfileCacheEntry(
            profiles,
            now.add(const Duration(minutes: 30)),
          );
          
          return profiles;
        }
        
        return [];
      } catch (e) {
        // Return cached data if available
        if (cached != null) {
          return cached.data;
        }
        return [];
      }
    });
  }

  Future<List<TokenProfile>> getTopBoostedTokens() async {
    const cacheKey = 'top_boosted_tokens';
    final now = DateTime.now();
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null && now.isBefore(cached.expiry)) {
      return cached.data;
    }

    return _limiter.execute(() async {
      try {
        final response = await _dio.get('/token-boosts/top/v1');
        
        if (response.data is List) {
          final profiles = (response.data as List)
              .map((item) => TokenProfile.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // Cache the result
          _cache[cacheKey] = _TokenProfileCacheEntry(
            profiles,
            now.add(const Duration(minutes: 30)),
          );
          
          return profiles;
        }
        
        return [];
      } catch (e) {
        // Return cached data if available
        if (cached != null) {
          return cached.data;
        }
        return [];
      }
    });
  }

  void clearCache() {
    _cache.clear();
  }
}

class _TokenProfileCacheEntry {
  final List<TokenProfile> data;
  final DateTime expiry;

  _TokenProfileCacheEntry(this.data, this.expiry);
}

extension _ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
