import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tokens_provider.dart';
import '../widgets/compact_token_card.dart';
import '../widgets/empty_state.dart';
import 'token_detail_screen.dart';

class TrendingScreen extends ConsumerWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingTokensProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(trendingTokensProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
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

            return ListView.builder(
              itemCount: tokensState.trending.length,
              itemBuilder: (context, index) {
                final pair = tokensState.trending[index];
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
    );
  }
}
