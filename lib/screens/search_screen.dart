import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';
import '../providers/search_history_provider.dart';
import '../widgets/token_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/compact_token_card.dart';
import 'token_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Search header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Tokens',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find Solana tokens by name, symbol, or address',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tokens...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchProvider.notifier).clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (query) {
                    ref.read(searchProvider.notifier).search(query);
                    setState(() {}); // Update suffix icon
                  },
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 16),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('High Volume'),
                        selected: searchState.filters['highVolume'] ?? false,
                        onSelected: (selected) {
                          ref.read(searchProvider.notifier).toggleFilter('highVolume');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('New Tokens'),
                        selected: searchState.filters['newTokens'] ?? false,
                        onSelected: (selected) {
                          ref.read(searchProvider.notifier).toggleFilter('newTokens');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('High Liquidity'),
                        selected: searchState.filters['highLiquidity'] ?? false,
                        onSelected: (selected) {
                          ref.read(searchProvider.notifier).toggleFilter('highLiquidity');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Price Range'),
                        selected: searchState.filters['priceRange'] ?? false,
                        onSelected: (selected) {
                          ref.read(searchProvider.notifier).toggleFilter('priceRange');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Market Cap'),
                        selected: searchState.filters['marketCap'] ?? false,
                        onSelected: (selected) {
                          ref.read(searchProvider.notifier).toggleFilter('marketCap');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Search results
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.query.isEmpty) {
      final searchHistory = ref.watch(searchHistoryProvider);
      
      if (searchHistory.isEmpty) {
        return EmptyState(
          icon: Icons.search,
          title: 'Search Solana Tokens',
          message: 'Enter a token name, symbol, or contract address to start searching',
          action: FilledButton.icon(
            onPressed: () {
              _searchController.text = 'SOL';
              ref.read(searchProvider.notifier).search('SOL');
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Try "SOL"'),
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).clearHistory();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                final pair = searchHistory[index];
                return CompactTokenCard(
                  pair: pair,
                  heroTag: 'history-${pair.pairId}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TokenDetailScreen(
                          pair: pair,
                          heroTag: 'history-${pair.pairId}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    if (searchState.error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Search Error',
        message: searchState.error!,
        action: FilledButton.icon(
          onPressed: () {
            ref.read(searchProvider.notifier).search(searchState.query);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      );
    }

    if (searchState.results.isEmpty && searchState.isLoading) {
      return const TokenList(
        tokens: [],
        isLoading: true,
      );
    }

    if (searchState.results.isEmpty && !searchState.isLoading) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No Results',
        message: 'No tokens found for "${searchState.query}". Try a different search term.',
        action: OutlinedButton.icon(
          onPressed: () {
            _searchController.clear();
            ref.read(searchProvider.notifier).clear();
          },
          icon: const Icon(Icons.clear),
          label: const Text('Clear Search'),
        ),
      );
    }

    return TokenList(
      tokens: searchState.results,
      isLoading: searchState.isLoading,
      scrollController: _scrollController,
      showLoadingIndicator: searchState.hasMore,
      onTokenTap: (pair) {
        // Add to search history
        ref.read(searchHistoryProvider.notifier).addToHistory(pair);
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TokenDetailScreen(
              pair: pair,
              heroTag: 'search-${pair.pairId}',
            ),
          ),
        );
      },
    );
  }
}
