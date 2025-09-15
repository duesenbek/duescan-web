import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

import '../models/pair.dart';
import 'token_card.dart';
import 'empty_state.dart';

class TokenList extends StatelessWidget {
  final List<Pair> tokens;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final void Function(Pair)? onTokenTap;
  final ScrollController? scrollController;
  final bool showLoadingIndicator;

  const TokenList({
    super.key,
    required this.tokens,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onTokenTap,
    this.scrollController,
    this.showLoadingIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Error',
        message: error!,
        action: onRefresh != null
            ? FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              )
            : null,
      );
    }

    if (tokens.isEmpty && !isLoading) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No tokens found',
        message: 'Try adjusting your search or filters',
      );
    }

    if (tokens.isEmpty && isLoading) {
      return _buildLoadingList();
    }

    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        
        if (isWide) {
          return _buildGridView();
        } else {
          return _buildListView();
        }
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator.adaptive(
        onRefresh: () async { onRefresh!(); },
        child: child,
      );
    }

    return child;
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: scrollController,
      itemCount: tokens.length + (showLoadingIndicator ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tokens.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final token = tokens[index];
        return TokenCard(
          pair: token,
          heroTag: 'token-${token.pairId}-$index',
          onTap: onTokenTap != null ? () => onTokenTap!(token) : null,
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemCount: tokens.length + (showLoadingIndicator ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= tokens.length) {
          return const Card(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final token = tokens[index];
        return TokenCard(
          pair: token,
          heroTag: 'token-${token.pairId}-$index',
          onTap: onTokenTap != null ? () => onTokenTap!(token) : null,
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
