import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';
import '../widgets/token_list.dart';
import '../widgets/empty_state.dart';
import 'token_detail_screen.dart';

class AllTokensScreenNew extends ConsumerStatefulWidget {
  const AllTokensScreenNew({super.key});

  @override
  ConsumerState<AllTokensScreenNew> createState() => _AllTokensScreenNewState();
}

class _AllTokensScreenNewState extends ConsumerState<AllTokensScreenNew> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tokens'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search tokens by name, symbol, or address',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (query) {
                ref.read(searchProvider.notifier).search(query);
              },
            ),
          ),
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState searchState) {
    if (searchState.query.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Search Solana Tokens',
        message: 'Enter a token name, symbol, or address to search',
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
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No Results',
        message: 'No tokens found for your search query',
      );
    }

    return TokenList(
      tokens: searchState.results,
      isLoading: searchState.isLoading,
      scrollController: _scrollController,
      showLoadingIndicator: searchState.hasMore,
      onTokenTap: (pair) {
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
