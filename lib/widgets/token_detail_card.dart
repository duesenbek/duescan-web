import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pair.dart';
import '../utils/formatters.dart';
import 'price_chart.dart';
import 'token_icon.dart';

class TokenDetailCard extends StatelessWidget {
  final Pair pair;
  final String heroTag;

  const TokenDetailCard({
    super.key,
    required this.pair,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with token info
            Row(
              children: [
                Hero(
                  tag: heroTag,
                  child: TokenIcon(
                    imageUrl: pair.baseToken.imageUrl ?? pair.baseImageUrl,
                    tokenAddress: pair.baseAddress,
                    symbol: pair.baseToken.symbol,
                    size: 56,
                    chainId: pair.chainId,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair.baseName.isNotEmpty ? pair.baseName : pair.baseSymbol,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pair.baseSymbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pair.baseAddress,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.fiat(pair.priceUsd),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (pair.change24h != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getChangeColor(pair.change24h!).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          Formatters.pct(pair.change24h),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getChangeColor(pair.change24h!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price change chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (pair.change5m != null)
                  _buildChangeChip(context, '5m', pair.change5m!),
                if (pair.change1h != null)
                  _buildChangeChip(context, '1h', pair.change1h!),
                if (pair.change24h != null)
                  _buildChangeChip(context, '24h', pair.change24h!),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Metrics Section
            Text(
              'Market Metrics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Primary Metrics - Larger cards
            Row(
              children: [
                Expanded(
                  child: _buildLargeMetricCard(
                    'Volume 24h', 
                    Formatters.fiat(pair.volume24h ?? 0), 
                    theme,
                    icon: Icons.bar_chart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLargeMetricCard(
                    'Liquidity', 
                    Formatters.fiat(pair.liquidityUsd ?? 0), 
                    theme,
                    icon: Icons.water_drop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Secondary Metrics - Same style as primary
            Row(
              children: [
                Expanded(
                  child: _buildLargeMetricCard(
                    'Market Cap', 
                    Formatters.fiat(pair.marketCapUsd ?? 0), 
                    theme,
                    icon: Icons.account_balance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLargeMetricCard(
                    'FDV', 
                    Formatters.fiat((pair.marketCapUsd ?? 0) * 1.2), 
                    theme,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildLargeMetricCard(
                    '24h Transactions', 
                    '${pair.txns24h ?? 0}', 
                    theme,
                    icon: Icons.swap_horiz,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLargeMetricCard(
                    'Buy/Sell Ratio', 
                    '${pair.txnsBuy24h ?? 0}/${pair.txnsSell24h ?? 0}', 
                    theme,
                    icon: Icons.balance,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Additional Token Information
            _buildInfoSection(context, 'Token Information', [
              _buildInfoRow(context, 'Chain', pair.chainId.toUpperCase()),
              _buildInfoRow(context, 'Pair Address', pair.pairId, copyable: true),
              _buildInfoRow(context, 'Base Token', pair.baseAddress, copyable: true),
              _buildInfoRow(context, 'Quote Token', '${pair.quoteSymbol} (${pair.quoteAddress})', copyable: true),
              if (pair.pairCreatedAt != null)
                _buildInfoRow(context, 'Created', _formatDate(pair.pairCreatedAt!)),
            ]),
            
            const SizedBox(height: 16),
            
            // Price Information
            _buildInfoSection(context, 'Price Details', [
              _buildInfoRow(context, 'Current Price', Formatters.fiat(pair.priceUsd)),
              if (pair.change5m != null)
                _buildInfoRow(context, '5m Change', '${Formatters.pct(pair.change5m)} (${_getChangeDirection(pair.change5m!)})', 
                  color: _getChangeColor(pair.change5m!)),
              if (pair.change1h != null)
                _buildInfoRow(context, '1h Change', '${Formatters.pct(pair.change1h)} (${_getChangeDirection(pair.change1h!)})', 
                  color: _getChangeColor(pair.change1h!)),
              if (pair.change24h != null)
                _buildInfoRow(context, '24h Change', '${Formatters.pct(pair.change24h)} (${_getChangeDirection(pair.change24h!)})', 
                  color: _getChangeColor(pair.change24h!)),
            ]),
            
            const SizedBox(height: 16),
            
            // Price Chart
            _buildPriceChart(context),
            
            const SizedBox(height: 16),
            
            // Trading Links
            _buildTradingLinks(context),
            
            const SizedBox(height: 16),
            
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyAddress(context, pair.baseAddress),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Address'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openDexScreener(pair.baseAddress),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('DexScreener'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon(String symbol) => Center(
        child: Text(
          (symbol.isNotEmpty ? symbol[0] : '?').toUpperCase(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildChangeChip(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    final color = _getChangeColor(value);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label ${Formatters.pct(value)}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLargeMetricCard(String label, String value, ThemeData theme, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricCard(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(double change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  String _getChangeDirection(double change) {
    if (change > 0) return '↗';
    if (change < 0) return '↘';
    return '→';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool copyable = false, Color? color}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: copyable ? () => _copyToClipboard(context, value) : null,
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color ?? theme.colorScheme.onSurface,
                  fontWeight: copyable ? FontWeight.w500 : FontWeight.normal,
                  decoration: copyable ? TextDecoration.underline : null,
                ),
                maxLines: copyable ? 1 : null,
                overflow: copyable ? TextOverflow.ellipsis : null,
              ),
            ),
          ),
          if (copyable)
            Icon(
              Icons.copy,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getAssessmentColor(String label) {
    switch (label.toLowerCase()) {
      case 'bullish':
      case 'strong buy':
        return Colors.green;
      case 'bearish':
      case 'strong sell':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _copyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied to clipboard')),
      );
    }
  }

  Future<void> _openDexScreener(String address) async {
    final uri = Uri.parse('https://dexscreener.com/solana/$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPriceChart(BuildContext context) {
    return PriceChart(
      pairAddress: pair.pairId,
      height: 250,
      showControls: true,
    );
  }

  Widget _buildTradingLinks(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Links',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDexScreener(pair.pairId),
                  icon: const Icon(Icons.analytics),
                  label: const Text('DexScreener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openJupiter(pair.baseAddress),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Jupiter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(context, pair.baseAddress),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Address'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openBirdEye(pair.baseAddress),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Birdeye'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openBirdEye(String address) async {
    final uri = Uri.parse('https://birdeye.so/token/$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openJupiter(String address) async {
    final uri = Uri.parse('https://jup.ag/swap/USDC-$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
