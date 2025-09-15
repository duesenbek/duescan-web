import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tokens_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/token_list.dart';
import '../widgets/empty_state.dart';
import 'token_detail_screen.dart';

class TrendingTokensScreen extends ConsumerWidget {
  const TrendingTokensScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingTokensProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Tokens'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Auto-refresh interval',
            icon: const Icon(Icons.timer_outlined),
            onSelected: (seconds) {
              ref.read(settingsProvider.notifier).setPollingInterval(seconds);
              final text = seconds == 0 
                  ? 'Auto-refresh disabled'
                  : 'Auto-refresh: ${seconds}s';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(text)),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.timer_off, size: 18),
                    SizedBox(width: 8),
                    Text('Disable'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 30,
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 18),
                    SizedBox(width: 8),
                    Text('30 seconds'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 60,
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 18),
                    SizedBox(width: 8),
                    Text('1 minute'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 120,
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 18),
                    SizedBox(width: 8),
                    Text('2 minutes'),
                  ],
                ),
              ),
            ],
          ),
          // Theme toggle
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () {
              final mode = settings.themeMode;
              final next = mode == ThemeMode.dark
                  ? ThemeMode.light
                  : mode == ThemeMode.light
                      ? ThemeMode.system
                      : ThemeMode.dark;
              ref.read(settingsProvider.notifier).setThemeMode(next);
            },
            icon: Icon(
              switch (settings.themeMode) {
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.light => Icons.light_mode,
                _ => Icons.brightness_auto,
              },
            ),
          ),
        ],
      ),
      body: trendingAsync.when(
        data: (tokensState) {
          if (tokensState.trending.isEmpty) {
            return const EmptyState(
              icon: Icons.trending_up,
              title: 'No trending tokens',
              message: 'Pull to refresh to load trending tokens',
            );
          }

          return TokenList(
            tokens: tokensState.trending,
            onRefresh: () async {
              await ref.read(trendingTokensProvider.notifier).refresh();
            },
            onTokenTap: (pair) {
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
        loading: () => const TokenList(
          tokens: [],
          isLoading: true,
        ),
        error: (error, stack) => TokenList(
          tokens: const [],
          error: error.toString(),
          onRefresh: () async {
            await ref.read(trendingTokensProvider.notifier).refresh();
          },
        ),
      ),
    );
  }
}
