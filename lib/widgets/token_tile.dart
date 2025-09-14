import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TokenTile extends StatelessWidget {
  const TokenTile({
    super.key,
    required this.mint,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.sentiment,
    this.logoUrl,
    this.price,
    this.onTap,
    this.dense = false,
  });

  final String mint;
  final String symbol;
  final String name;
  final double amount;
  final String sentiment; // positive | neutral | negative
  final String? logoUrl;
  final double? price;
  final VoidCallback? onTap;
  final bool dense;

  Color _sentimentColor(BuildContext context) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _sentimentIcon() {
    switch (sentiment) {
      case 'positive':
        return Icons.thumb_up_alt_outlined;
      case 'negative':
        return Icons.thumb_down_alt_outlined;
      default:
        return Icons.thumbs_up_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _sentimentColor(context);
    final avatarSize = dense ? 32.0 : 40.0;
    return InkWell(
      onTap: onTap,
      onLongPress: () async {
        final messenger = ScaffoldMessenger.of(context);
        await Clipboard.setData(ClipboardData(text: mint));
        messenger.showSnackBar(
          const SnackBar(content: Text('Mint address copied')),
        );
      },
      child: ListTile(
        dense: dense,
        leading: CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ClipOval(
            child: logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: logoUrl!,
                    width: avatarSize,
                    height: avatarSize,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Text(symbol.isNotEmpty ? symbol[0].toUpperCase() : '?'),
                    placeholder: (_, __) => Text(symbol.isNotEmpty ? symbol[0].toUpperCase() : '?'),
                  )
                : Text(symbol.isNotEmpty ? symbol[0].toUpperCase() : '?'),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '$symbol · ${amount.toStringAsFixed(6)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (price != null)
              Text(
                'USD ${price!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        subtitle: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_sentimentIcon(), color: sColor, size: dense ? 16 : null),
            if (!dense) const SizedBox(width: 6),
            if (!dense)
              Text(
                sentiment,
                style: TextStyle(color: sColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
