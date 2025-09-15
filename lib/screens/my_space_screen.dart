import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';

import '../widgets/empty_state.dart';
import '../widgets/compact_token_card.dart';
import '../providers/favorites_provider.dart';
import '../providers/tokens_provider.dart';
import '../providers/settings_provider.dart';
import 'token_detail_screen.dart';

class MySpaceScreen extends ConsumerWidget {
  const MySpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Space'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            final settings = ref.read(settingsProvider);
            final newTheme = settings.themeMode == ThemeMode.light 
                ? ThemeMode.dark 
                : ThemeMode.light;
            ref.read(settingsProvider.notifier).setThemeMode(newTheme);
          },
          icon: Consumer(
            builder: (context, ref, child) {
              final settings = ref.watch(settingsProvider);
              return Icon(
                settings.themeMode == ThemeMode.light 
                    ? IconlyLight.sun 
                    : IconlyLight.moon,
              );
            },
          ),
          tooltip: 'Toggle theme',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
            icon: const Icon(IconlyLight.setting),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          
          // Content - Show favorites
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final favorites = ref.watch(favoritesProvider);
                final tokensState = ref.watch(trendingTokensProvider);
                
                if (favorites.isEmpty) {
                  return const EmptyState(
                    icon: IconlyLight.heart,
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
                        icon: IconlyLight.heart,
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
                    icon: IconlyLight.danger,
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
