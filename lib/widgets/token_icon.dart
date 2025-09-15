import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/token_profile_service.dart';

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

    try {
      final iconUrl = await TokenProfileService.instance.getTokenIcon(
        widget.tokenAddress,
        chainId: widget.chainId,
      );
      
      print('Token icon loaded for ${widget.symbol}: $iconUrl'); // Debug
      
      if (mounted && iconUrl != null && iconUrl.isNotEmpty) {
        setState(() {
          _profileImageUrl = iconUrl;
        });
      }
    } catch (e) {
      print('Error loading token icon for ${widget.symbol}: $e'); // Debug
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) _profileImageUrl!,
      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) widget.imageUrl!,
    ];

    if (imageSources.isNotEmpty) {
      return _buildImageWithFallback(imageSources, 0, theme);
    }

    return _buildFallbackIcon(theme);
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
    final symbol = widget.symbol.toUpperCase();
    final firstLetter = symbol.isNotEmpty ? symbol[0] : '?';
    
    // Generate a color based on the symbol
    final colorIndex = symbol.hashCode % _fallbackColors.length;
    final backgroundColor = _fallbackColors[colorIndex.abs()];
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static const List<Color> _fallbackColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFF84CC16), // Lime
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
    Color(0xFF8B5A2B), // Brown
    Color(0xFF6B7280), // Gray
  ];
}
