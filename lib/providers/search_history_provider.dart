import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/pair.dart';

class SearchHistoryNotifier extends Notifier<List<Pair>> {
  static const String _storageKey = 'search_history';
  static const int _maxHistoryItems = 20;

  @override
  List<Pair> build() {
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_storageKey) ?? [];
      
      final history = historyJson.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return Pair.fromDex(json, chainId: json['chainId'] ?? 'solana');
      }).toList();
      
      state = history;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addToHistory(Pair pair) async {
    final currentHistory = List<Pair>.from(state);
    
    // Remove if already exists to avoid duplicates
    currentHistory.removeWhere((p) => p.pairId == pair.pairId);
    
    // Add to beginning
    currentHistory.insert(0, pair);
    
    // Limit history size
    if (currentHistory.length > _maxHistoryItems) {
      currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
    }
    
    state = currentHistory;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = currentHistory.map((pair) {
        return jsonEncode({
          'chainId': pair.chainId,
          'pairAddress': pair.pairId,
          'pairId': pair.pairId,
          'baseToken': {
            'address': pair.baseToken.address,
            'symbol': pair.baseToken.symbol,
            'name': pair.baseToken.name,
            'imageUrl': pair.baseToken.imageUrl,
          },
          'quoteToken': {
            'address': pair.quoteToken.address,
            'symbol': pair.quoteToken.symbol,
            'name': pair.quoteToken.name,
            'imageUrl': pair.quoteToken.imageUrl,
          },
          'priceUsd': pair.priceUsd?.toString(),
          'priceChange': {
            'h24': pair.change24h?.toString(),
          },
          'volume': {
            'h24': pair.volume24h?.toString(),
          },
          'liquidity': {
            'usd': pair.liquidityUsd?.toString(),
          },
          'marketCap': pair.marketCapUsd?.toString(),
          'pairCreatedAt': pair.pairCreatedAt?.millisecondsSinceEpoch,
        });
      }).toList();
      
      await prefs.setStringList(_storageKey, historyJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearHistory() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeFromHistory(String pairId) async {
    final currentHistory = List<Pair>.from(state);
    currentHistory.removeWhere((p) => p.pairId == pairId);
    state = currentHistory;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = currentHistory.map((pair) {
        return jsonEncode({
          'chainId': pair.chainId,
          'pairAddress': pair.pairId,
          'pairId': pair.pairId,
          'baseToken': {
            'address': pair.baseToken.address,
            'symbol': pair.baseToken.symbol,
            'name': pair.baseToken.name,
            'imageUrl': pair.baseToken.imageUrl,
          },
          'quoteToken': {
            'address': pair.quoteToken.address,
            'symbol': pair.quoteToken.symbol,
            'name': pair.quoteToken.name,
            'imageUrl': pair.quoteToken.imageUrl,
          },
          'priceUsd': pair.priceUsd?.toString(),
          'priceChange': {
            'h24': pair.change24h?.toString(),
          },
          'volume': {
            'h24': pair.volume24h?.toString(),
          },
          'liquidity': {
            'usd': pair.liquidityUsd?.toString(),
          },
          'marketCap': pair.marketCapUsd?.toString(),
          'pairCreatedAt': pair.pairCreatedAt?.millisecondsSinceEpoch,
        });
      }).toList();
      
      await prefs.setStringList(_storageKey, historyJson);
    } catch (e) {
      // Handle error silently
    }
  }
}

final searchHistoryProvider = NotifierProvider<SearchHistoryNotifier, List<Pair>>(() {
  return SearchHistoryNotifier();
});
