import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../widgets/empty_state.dart';
import '../widgets/compact_token_card.dart';
import '../widgets/new_filter_bar.dart';
import '../providers/tokens_provider.dart';
import '../providers/trending_filters_provider.dart';
import '../models/pair.dart';
import 'token_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingTokensProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DueScan'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // New Filter Bar
          const NewFilterBar(),
          
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
                      icon: IconlyLight.arrowUp,
                      title: 'No trending tokens',
                      message: 'Pull to refresh to load trending tokens',
                    );
                  }

                  // Apply new filters
                  final filters = ref.watch(trendingFiltersProvider);
                  List<Pair> filteredTokens = List.from(tokensState.trending);

                  // Apply filter type logic (now always has a default filter)
                  switch (filters.activeFilter!) {
                      case FilterType.trending:
                        // Apply trending logic with time interval
                        if (filters.timeInterval != null) {
                          filteredTokens = filteredTokens.where((token) {
                            switch (filters.timeInterval!) {
                              case TimeInterval.min5:
                                return (token.change5m ?? 0) > 0;
                              case TimeInterval.hour1:
                                return (token.change1h ?? 0) > 0;
                              case TimeInterval.hour6:
                                return (token.change1h ?? 0) > 0;
                              case TimeInterval.hour24:
                                return (token.change24h ?? 0) > 0;
                            }
                          }).toList();
                        }
                        break;
                        
                      case FilterType.new_:
                        // Filter by time interval first (show newest tokens)
                        final now = DateTime.now();
                        if (filters.timeInterval != null) {
                          filteredTokens = filteredTokens.where((token) {
                            if (token.pairCreatedAt == null) return true; // Include tokens without creation date
                            final diff = now.difference(token.pairCreatedAt!);
                            switch (filters.timeInterval!) {
                              case TimeInterval.min5:
                                return diff.inMinutes <= 5;
                              case TimeInterval.hour1:
                                return diff.inHours <= 1;
                              case TimeInterval.hour6:
                                return diff.inHours <= 6;
                              case TimeInterval.hour24:
                                return diff.inHours <= 24;
                            }
                          }).toList();
                        }
                        
                        // Always sort by creation time (newest first)
                        filteredTokens.sort((a, b) {
                          final aCreated = a.pairCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                          final bCreated = b.pairCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                          return bCreated.compareTo(aCreated);
                        });
                        break;
                        
                      case FilterType.top:
                        // Sort by volume (top performers)
                        if (filters.timeInterval != null) {
                          switch (filters.timeInterval!) {
                            case TimeInterval.min5:
                              filteredTokens.sort((a, b) => (b.change5m ?? 0).compareTo(a.change5m ?? 0));
                              break;
                            case TimeInterval.hour1:
                              filteredTokens.sort((a, b) => (b.change1h ?? 0).compareTo(a.change1h ?? 0));
                              break;
                            case TimeInterval.hour6:
                              filteredTokens.sort((a, b) => (b.change1h ?? 0).compareTo(a.change1h ?? 0));
                              break;
                            case TimeInterval.hour24:
                              filteredTokens.sort((a, b) => (b.change24h ?? 0).compareTo(a.change24h ?? 0));
                              break;
                          }
                        } else {
                          filteredTokens.sort((a, b) => (b.volume24h ?? 0).compareTo(a.volume24h ?? 0));
                        }
                        break;
                        
                      case FilterType.sort:
                        // Apply advanced sorting with null safety
                        if (filters.sortOption != null) {
                          // First filter by time interval if specified
                          if (filters.sortTimeInterval != null) {
                            filteredTokens = filteredTokens.where((token) {
                              switch (filters.sortTimeInterval!) {
                                case TimeInterval.min5:
                                  return token.change5m != null;
                                case TimeInterval.hour1:
                                  return token.change1h != null;
                                case TimeInterval.hour6:
                                  return token.change1h != null; // Using change1h as fallback since change6h doesn't exist
                                case TimeInterval.hour24:
                                  return token.change24h != null;
                              }
                            }).toList();
                          }

                          // Then apply the selected sort
                          switch (filters.sortOption!) {
                            case SortOption.rankPairs:
                              // Default sort by market cap if available, otherwise by volume
                              filteredTokens.sort((a, b) => 
                                (b.marketCapUsd ?? b.volume24h ?? 0)
                                .compareTo(a.marketCapUsd ?? a.volume24h ?? 0)
                              );
                              break;
                              
                            case SortOption.mostVolume:
                              filteredTokens.sort((a, b) => 
                                (b.volume24h ?? 0).compareTo(a.volume24h ?? 0)
                              );
                              break;
                              
                            case SortOption.mostTxns:
                              filteredTokens.sort((a, b) => 
                                (b.txns24h ?? 0).compareTo(a.txns24h ?? 0)
                              );
                              break;
                              
                            case SortOption.mostLiquidity:
                              filteredTokens.sort((a, b) => 
                                (b.liquidityUsd ?? 0).compareTo(a.liquidityUsd ?? 0)
                              );
                              break;
                              
                            case SortOption.pairAgeNewest:
                              filteredTokens.sort((a, b) => 
                                (b.pairCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                                .compareTo(a.pairCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                              );
                              break;
                              
                            case SortOption.pairAgeOldest:
                              filteredTokens.sort((a, b) => 
                                (a.pairCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                                .compareTo(b.pairCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                              );
                              break;
                              
                            case SortOption.marketCapHighest:
                              filteredTokens.sort((a, b) => 
                                (b.marketCapUsd ?? 0).compareTo(a.marketCapUsd ?? 0)
                              );
                              break;
                              
                            case SortOption.trending:
                              // Sort by price change based on selected time interval
                              if (filters.sortTimeInterval != null) {
                                switch (filters.sortTimeInterval!) {
                                  case TimeInterval.min5:
                                    filteredTokens.sort((a, b) => 
                                      (b.change5m ?? 0).compareTo(a.change5m ?? 0)
                                    );
                                    break;
                                    
                                  case TimeInterval.hour1:
                                    filteredTokens.sort((a, b) => 
                                      (b.change1h ?? 0).compareTo(a.change1h ?? 0)
                                    );
                                    break;
                                    
                                  case TimeInterval.hour6:
                                    filteredTokens.sort((a, b) => 
                                      (b.change1h ?? 0).compareTo(a.change1h ?? 0) // Using change1h as fallback
                                    );
                                    break;
                                    
                                  case TimeInterval.hour24:
                                    filteredTokens.sort((a, b) => 
                                      (b.change24h ?? 0).compareTo(a.change24h ?? 0)
                                    );
                                    break;
                                }
                              }
                              break;
                              
                            case SortOption.priceChangeUp:
                              // Sort by price change in descending order (highest first)
                              if (filters.sortTimeInterval != null) {
                                switch (filters.sortTimeInterval!) {
                                  case TimeInterval.min5:
                                    filteredTokens.sort((a, b) => 
                                      (b.change5m ?? 0).compareTo(a.change5m ?? 0)
                                    );
                                    break;
                                    
                                  case TimeInterval.hour1:
                                    filteredTokens.sort((a, b) => 
                                      (b.change1h ?? 0).compareTo(a.change1h ?? 0)
                                    );
                                    break;
                                    
                                  case TimeInterval.hour6:
                                    filteredTokens.sort((a, b) => 
                                      (b.change1h ?? 0).compareTo(a.change1h ?? 0) // Using change1h as fallback
                                    );
                                    break;
                                    
                                  case TimeInterval.hour24:
                                    filteredTokens.sort((a, b) => 
                                      (b.change24h ?? 0).compareTo(a.change24h ?? 0)
                                    );
                                    break;
                                }
                              }
                              break;
                              
                            case SortOption.priceChangeDown:
                              // Sort by price change in ascending order (lowest/most negative first)
                              if (filters.sortTimeInterval != null) {
                                switch (filters.sortTimeInterval!) {
                                  case TimeInterval.min5:
                                    filteredTokens.sort((a, b) => 
                                      (a.change5m ?? 0).compareTo(b.change5m ?? 0)
                                    );
                                    break;
                                    
                                  case TimeInterval.hour1:
                                    filteredTokens.sort((a, b) => 
                                      (a.change1h ?? 0).compareTo(b.change1h ?? 0)
                                    );
                                    break;
                                    
                                  case TimeInterval.hour6:
                                    filteredTokens.sort((a, b) => 
                                      (a.change1h ?? 0).compareTo(b.change1h ?? 0) // Using change1h as fallback
                                    );
                                    break;
                                    
                                  case TimeInterval.hour24:
                                    filteredTokens.sort((a, b) => 
                                      (a.change24h ?? 0).compareTo(b.change24h ?? 0)
                                    );
                                    break;
                                }
                              }
                              break;
                          }
                        }
                        break;
                        
                      case FilterType.search:
                        // Already handled above
                        break;
                    }

                  if (filteredTokens.isEmpty) {
                    return const EmptyState(
                      icon: IconlyLight.filter,
                      title: 'No tokens match filters',
                      message: 'Try adjusting your filters or pull to refresh',
                    );
                  }

                  return LiveList.options(
                    options: LiveOptions(
                      delay: Duration(milliseconds: 100),
                      showItemInterval: Duration(milliseconds: 150),
                      showItemDuration: Duration(milliseconds: 400),
                      visibleFraction: 0.025,
                      reAnimateOnVisibility: false,
                    ),
                    itemCount: filteredTokens.length,
                    itemBuilder: (context, index, animation) {
                      final pair = filteredTokens[index];
                      return FadeTransition(
                        opacity: Tween<double>(
                          begin: 0,
                          end: 1,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: CompactTokenCard(
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
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => const EmptyState(
                  icon: IconlyLight.dangerTriangle,
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
