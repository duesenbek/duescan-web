import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tokens_provider.dart';
import '../widgets/compact_token_card.dart';
import '../widgets/empty_state.dart';
import 'token_detail_screen.dart';

class AllTokensScreen extends ConsumerWidget {
  const AllTokensScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(trendingTokensProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tokens'),
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
        child: tokensAsync.when(
          data: (tokensState) {
            final allTokens = tokensState.trending;
            
            if (allTokens.isEmpty) {
              return const EmptyState(
                icon: Icons.token,
                title: 'No tokens available',
                message: 'Pull to refresh to load tokens',
              );
            }

            return ListView.builder(
              itemCount: allTokens.length,
              itemBuilder: (context, index) {
                final pair = allTokens[index];
                return CompactTokenCard(
                  pair: pair,
                  heroTag: 'all-${pair.pairId}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TokenDetailScreen(
                          pair: pair,
                          heroTag: 'all-${pair.pairId}',
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
