import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pair.dart';
import '../widgets/token_detail_card.dart';
import '../widgets/mini_sparkline.dart';
import '../utils/formatters.dart';
import '../providers/favorites_provider.dart';

/// Detailed token screen (full screen)
/// Shows token details with AI assessment and charts
class TokenDetailScreen extends ConsumerWidget {
  const TokenDetailScreen({super.key, required this.pair, required this.heroTag});

  final Pair pair;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(pair.pairId);

    return Scaffold(
      appBar: AppBar(
        title: Text(pair.baseToken.symbol),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(pair.pairId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite ? 'Removed from favorites' : 'Added to favorites',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TokenDetailCard(
          pair: pair,
          heroTag: 'token_${pair.baseAddress}',
        ),
      ),
    );
  }
}
