import 'package:flutter/material.dart';

import '../models/pair.dart';
import '../utils/formatters.dart';
import 'mini_sparkline.dart';
import 'token_icon.dart';

class CompactTokenCard extends StatelessWidget {
  final Pair pair;
  final VoidCallback? onTap;
  final String? heroTag;

  const CompactTokenCard({
    super.key,
    required this.pair,
    this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Token icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildTokenIcon(theme),
              ),
              const SizedBox(width: 12),
              
              // Token info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pair.baseToken.symbol,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/${pair.quoteSymbol}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pair.baseToken.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Mini chart
              SizedBox(
                width: 60,
                height: 30,
                child: MiniSparkline(
                  pairId: pair.pairId,
                  color: _getChangeColor(pair.change24h ?? 0),
                ),
              ),
              const SizedBox(width: 12),
              
              // Price and change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.fiat(pair.priceUsd),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (pair.change24h != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getChangeColor(pair.change24h!).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Formatters.pct(pair.change24h),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getChangeColor(pair.change24h!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenIcon(ThemeData theme) {
    return TokenIcon(
      imageUrl: pair.baseToken.imageUrl ?? pair.baseImageUrl,
      tokenAddress: pair.baseAddress,
      symbol: pair.baseToken.symbol,
      size: 32,
      chainId: pair.chainId,
    );
  }

  Color _getChangeColor(double change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }
}
