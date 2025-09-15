import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import '../models/pair.dart';

class TokenIcon extends StatefulWidget {
  final String? imageUrl;
  final String tokenAddress;
  final String symbol;
  final double size;
  final String chainId;

  const TokenIcon({
    super.key,
    this.imageUrl,
    required this.tokenAddress,
    required this.symbol,
    this.size = 40,
    this.chainId = 'solana',
  });

  @override
  State<TokenIcon> createState() => _TokenIconState();
}

// Helper function to get TrustWallet token logo URL
String getTokenLogo(String address, {String blockchain = 'solana'}) {
  return 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/$blockchain/assets/$address/logo.png';
}

class _TokenIconState extends State<TokenIcon> {
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Always try to load token icon, even if imageUrl is provided as fallback
    _loadTokenIcon();
  }

  Future<void> _loadTokenIcon() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // For now, just set loading to false since we're using TrustWallet as primary source
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveImageUrl = widget.imageUrl ?? _profileImageUrl;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: ClipOval(
        child: _buildIconContent(theme, effectiveImageUrl),
      ),
    );
  }

  Widget _buildIconContent(ThemeData theme, String? imageUrl) {
    if (_isLoading) {
      return _buildFallbackIcon(theme); // Show fallback immediately instead of loading spinner
    }

    // Try multiple image sources in priority order
    final imageSources = <String>[
      getTokenLogo(widget.tokenAddress), // TrustWallet first
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) _profileImageUrl!,
      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) widget.imageUrl!,
    ];

    return _buildImageWithFallback(imageSources, 0, theme);
  }

  Widget _buildImageWithFallback(List<String> urls, int index, ThemeData theme) {
    if (index >= urls.length) {
      return _buildFallbackIcon(theme);
    }

    return CachedNetworkImage(
      imageUrl: urls[index],
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      },
      placeholder: (context, url) => _buildFallbackIcon(theme),
      errorWidget: (context, url, error) {
        print('Failed to load image ${urls[index]}: $error');
        // Try next URL if available
        if (index + 1 < urls.length) {
          return _buildImageWithFallback(urls, index + 1, theme);
        }
        return _buildFallbackIcon(theme);
      },
    );
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        IconlyBold.wallet,
        size: widget.size * 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
