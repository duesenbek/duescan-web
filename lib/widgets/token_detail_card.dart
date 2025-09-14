import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pair.dart';
import '../services/ai_service.dart';
import '../utils/formatters.dart';

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
    final aiService = const AiService();
    final assessment = aiService.assessPair(pair);

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
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: ClipOval(
                      child: (pair.baseImageUrl != null && pair.baseImageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: pair.baseImageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _fallbackIcon(pair.baseSymbol),
                              placeholder: (_, __) => _fallbackIcon(pair.baseSymbol),
                            )
                          : _fallbackIcon(pair.baseSymbol),
                    ),
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
            
            const SizedBox(height: 16),
            
            // Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Volume 24h',
                    Formatters.fiat(pair.volume24h),
                    Icons.bar_chart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Liquidity',
                    Formatters.fiat(pair.liquidityUsd),
                    Icons.water_drop,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Market Cap',
                    Formatters.fiat(pair.marketCap),
                    Icons.account_balance,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // AI Assessment
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Assessment',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getAssessmentColor(assessment.label).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${assessment.score}/100 ${assessment.label}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getAssessmentColor(assessment.label),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: assessment.score / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(_getAssessmentColor(assessment.label)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assessment.explanation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
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

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getChangeColor(double value) {
    return value >= 0 ? Colors.green : Colors.red;
  }

  Color _getAssessmentColor(String label) {
    switch (label.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
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

  Future<void> _openJupiter(String address) async {
    final uri = Uri.parse('https://jup.ag/swap/USDC-$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
