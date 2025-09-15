import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/dexscreener_service.dart';
import '../models/pair.dart';

class SearchState {
  final String query;
  final List<Pair> results;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final Map<String, bool> filters;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.filters = const {},
  });

  SearchState copyWith({
    String? query,
    List<Pair>? results,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    Map<String, bool>? filters,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filters: filters ?? this.filters,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    return const SearchState();
  }

  void search(String query) {
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true);
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final pairs = await DexscreenerService.instance.fetchPairsForChain(
        'solana',
        query: query,
        page: 1,
        pageSize: 50,
      );
      
      // Apply filters
      final filteredPairs = _applyFilters(pairs);
      
      state = state.copyWith(
        results: filteredPairs,
        isLoading: false,
        error: null,
        hasMore: pairs.length >= 50,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  List<Pair> _applyFilters(List<Pair> pairs) {
    var filteredPairs = pairs;

    // High Volume filter
    if (state.filters['highVolume'] == true) {
      filteredPairs = filteredPairs.where((pair) => 
        (pair.volume24h ?? 0) > 100000).toList();
    }

    // New Tokens filter (created within last 7 days)
    if (state.filters['newTokens'] == true) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      filteredPairs = filteredPairs.where((pair) => 
        pair.pairCreatedAt != null && pair.pairCreatedAt!.isAfter(weekAgo)).toList();
    }

    // High Liquidity filter
    if (state.filters['highLiquidity'] == true) {
      filteredPairs = filteredPairs.where((pair) => 
        (pair.liquidityUsd ?? 0) > 50000).toList();
    }

    // Price Range filter (tokens under $1)
    if (state.filters['priceRange'] == true) {
      filteredPairs = filteredPairs.where((pair) => 
        (pair.priceUsd ?? 0) < 1.0).toList();
    }

    // Market Cap filter (over $1M)
    if (state.filters['marketCap'] == true) {
      filteredPairs = filteredPairs.where((pair) => 
        (pair.marketCapUsd ?? 0) > 1000000).toList();
    }

    return filteredPairs;
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);

    try {
      final morePairs = await DexscreenerService.instance.fetchPairsForChain(
        'solana',
        query: state.query,
        page: nextPage,
        pageSize: 50,
      );

      state = state.copyWith(
        results: [...state.results, ...morePairs],
        isLoading: false,
        hasMore: morePairs.length >= 50,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more: $e',
      );
    }
  }

  void toggleFilter(String filterKey) {
    final currentFilters = Map<String, bool>.from(state.filters);
    currentFilters[filterKey] = !(currentFilters[filterKey] ?? false);
    
    state = state.copyWith(filters: currentFilters);
    
    // Re-apply search with new filters
    if (state.query.isNotEmpty) {
      _performSearch(state.query);
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
