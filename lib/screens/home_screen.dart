import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tokens_provider.dart';
import '../providers/trending_filters_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/compact_token_card.dart';
import 'token_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingTokensProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header section with filters
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              children: [
                // Time filters
                Consumer(
                  builder: (context, ref, child) {
                    final filters = ref.watch(trendingFiltersProvider);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('5min'),
                            selected: filters.timeFilter == TimeFilter.min5,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setTimeFilter(
                                selected ? TimeFilter.min5 : null
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('1hour'),
                            selected: filters.timeFilter == TimeFilter.hour1,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setTimeFilter(
                                selected ? TimeFilter.hour1 : null
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('6hour'),
                            selected: filters.timeFilter == TimeFilter.hour6,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setTimeFilter(
                                selected ? TimeFilter.hour6 : null
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('24hour'),
                            selected: filters.timeFilter == TimeFilter.hour24,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setTimeFilter(
                                selected ? TimeFilter.hour24 : null
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Category filters
                Consumer(
                  builder: (context, ref, child) {
                    final filters = ref.watch(trendingFiltersProvider);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Trending'),
                            selected: filters.categoryFilter == CategoryFilter.trending,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setCategoryFilter(
                                selected ? CategoryFilter.trending : null
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Newest'),
                            selected: filters.categoryFilter == CategoryFilter.newest,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setCategoryFilter(
                                selected ? CategoryFilter.newest : null
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Top Volume'),
                            selected: filters.categoryFilter == CategoryFilter.topVolume,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setCategoryFilter(
                                selected ? CategoryFilter.topVolume : null
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Top Liquidity'),
                            selected: filters.categoryFilter == CategoryFilter.topLiquidity,
                            onSelected: (selected) {
                              ref.read(trendingFiltersProvider.notifier).setCategoryFilter(
                                selected ? CategoryFilter.topLiquidity : null
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Tokens list with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(trendingTokensProvider.notifier).refresh();
              },
              child: trendingAsync.when(
                data: (tokensState) {
                  if (tokensState.trending.isEmpty) {
                    return const EmptyState(
                      icon: Icons.trending_up,
                      title: 'No trending tokens',
                      message: 'Pull to refresh to load trending tokens',
                    );
                  }

                  // Apply filters
                  final filters = ref.watch(trendingFiltersProvider);
                  var filteredTokens = tokensState.trending;
                  
                  // Apply category filter
                  if (filters.categoryFilter != null) {
                    switch (filters.categoryFilter!) {
                      case CategoryFilter.newest:
                        filteredTokens = filteredTokens.where((token) => 
                          token.pairCreatedAt != null && 
                          DateTime.now().difference(token.pairCreatedAt!).inHours < 24
                        ).toList();
                        break;
                      case CategoryFilter.topVolume:
                        filteredTokens.sort((a, b) => (b.volume24h ?? 0).compareTo(a.volume24h ?? 0));
                        break;
                      case CategoryFilter.topLiquidity:
                        filteredTokens.sort((a, b) => (b.liquidityUsd ?? 0).compareTo(a.liquidityUsd ?? 0));
                        break;
                      case CategoryFilter.trending:
                        // Default trending order
                        break;
                    }
                  }
                  
                  // Apply time filter for price changes
                  if (filters.timeFilter != null) {
                    filteredTokens = filteredTokens.where((token) {
                      switch (filters.timeFilter!) {
                        case TimeFilter.min5:
                          return (token.change5m ?? 0) > 0;
                        case TimeFilter.hour1:
                          return (token.change1h ?? 0) > 0;
                        case TimeFilter.hour6:
                          return (token.change1h ?? 0) > 0; // Use 1h as proxy
                        case TimeFilter.hour24:
                          return (token.change24h ?? 0) > 0;
                      }
                    }).toList();
                  }

                  if (filteredTokens.isEmpty) {
                    return const EmptyState(
                      icon: Icons.filter_list_off,
                      title: 'No tokens match filters',
                      message: 'Try adjusting your filters or pull to refresh',
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTokens.length,
                    itemBuilder: (context, index) {
                      final pair = filteredTokens[index];
                      return CompactTokenCard(
                        pair: pair,
                        heroTag: 'trending-${pair.pairId}',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TokenDetailScreen(
                                pair: pair,
                                heroTag: 'trending-${pair.pairId}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => const EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error Loading Tokens',
                  message: 'Pull to refresh to try again',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
