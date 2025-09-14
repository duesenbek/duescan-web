import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/empty_state.dart';
import '../widgets/compact_token_card.dart';
import '../providers/favorites_provider.dart';
import '../providers/tokens_provider.dart';
import 'token_detail_screen.dart';

class MySpaceScreen extends ConsumerWidget {
  const MySpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Space',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your favorite tokens and watchlist',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
          
          // Content - Show favorites
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final favorites = ref.watch(favoritesProvider);
                final tokensState = ref.watch(trendingTokensProvider);
                
                if (favorites.isEmpty) {
                  return const EmptyState(
                    icon: Icons.favorite_outline,
                    title: 'No Favorites Yet',
                    message: 'Add tokens to your favorites by tapping the heart icon on any token card',
                  );
                }
                
                return tokensState.when(
                  data: (state) {
                    // Filter tokens that are in favorites
                    final favoriteTokens = state.trending
                        .where((token) => favorites.contains(token.pairId))
                        .toList();
                    
                    if (favoriteTokens.isEmpty) {
                      return const EmptyState(
                        icon: Icons.favorite_outline,
                        title: 'Favorites Not Found',
                        message: 'Your favorite tokens are not in the current trending list',
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: favoriteTokens.length,
                      itemBuilder: (context, index) {
                        final pair = favoriteTokens[index];
                        return CompactTokenCard(
                          pair: pair,
                          heroTag: 'favorite-${pair.pairId}',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TokenDetailScreen(
                                  pair: pair,
                                  heroTag: 'favorite-${pair.pairId}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => const EmptyState(
                    icon: Icons.error_outline,
                    title: 'Error Loading Favorites',
                    message: 'Unable to load your favorite tokens',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
