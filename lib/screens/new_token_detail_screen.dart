import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pair.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/token_detail_card.dart';

class NewTokenDetailScreen extends ConsumerWidget {
  const NewTokenDetailScreen({
    super.key,
    required this.pair,
    required this.heroTag,
  });

  final Pair pair;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(pair.baseSymbol),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          // Refresh token data
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main token detail card
              TokenDetailCard(
                pair: pair,
                heroTag: heroTag,
              ),
              
              const SizedBox(height: 16),
              
              // Price chart section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Chart',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Timeframe selector
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: '5m', label: Text('5m')),
                          ButtonSegment(value: '1h', label: Text('1h')),
                          ButtonSegment(value: '24h', label: Text('24h')),
                          ButtonSegment(value: '7d', label: Text('7d')),
                        ],
                        selected: {'24h'},
                        onSelectionChanged: (selection) {
                          // Handle timeframe change
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Placeholder chart
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Chart coming soon',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
