import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/settings_provider.dart';
import '../models/pair.dart';
import '../utils/formatters.dart';
import 'mini_sparkline.dart';

class TokenCard extends ConsumerWidget {
  const TokenCard({
    super.key,
    required this.pair,
    required this.heroTag,
    this.onTap,
  });

  final Pair pair;
  final String heroTag;
  final VoidCallback? onTap;

  Color _getChangeColor(double? value) {
    if (value == null) return Colors.grey;
    return value >= 0 ? Colors.green : Colors.red;
  }

  String get _shortAddress => pair.baseAddress.length > 8 
      ? '${pair.baseAddress.substring(0, 4)}...${pair.baseAddress.substring(pair.baseAddress.length - 4)}'
      : pair.baseAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final priceConverted = settings.convertFromUsd(pair.priceUsd ?? 0);
    final currencySymbol = settings.currencySymbol;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Token logo
                  Hero(
                    tag: heroTag,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: ClipOval(
                        child: (pair.baseImageUrl != null && pair.baseImageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: pair.baseImageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => _fallbackIcon(pair.baseSymbol),
                                placeholder: (context, url) => _fallbackIcon(pair.baseSymbol),
                              )
                            : _fallbackIcon(pair.baseSymbol),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Token info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pair.baseSymbol,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$currencySymbol${Formatters.price(priceConverted)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pair.baseName.isNotEmpty ? pair.baseName : pair.baseSymbol,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _shortAddress,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Price changes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (pair.change24h != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getChangeColor(pair.change24h).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '24h ${Formatters.pct(pair.change24h)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getChangeColor(pair.change24h),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Vol: ${Formatters.fiat(pair.volume24h)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Sparkline
              MiniSparkline(
                pairId: pair.pairId,
                color: _getChangeColor(pair.change24h ?? 0),
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon(String symbol) => Center(
        child: Text(
          (symbol.isNotEmpty ? symbol[0] : '?').toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
}