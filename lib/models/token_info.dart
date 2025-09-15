import 'package:flutter/foundation.dart';

/// Simple model to hold SPL token information for display
@immutable
class TokenInfo {
  final String mint;
  final String symbol;
  final String name;
  final int decimals;
  final double uiAmount;
  final String sentiment; // positive | neutral | negative
  final String? logoUrl; // token icon url if available
  final String? aiSummary; // longer AI text (trend/risk/desc)
  final double? aiScore; // optional numeric score 0..1
  final double? price; // current price in USD if available

  const TokenInfo({
    required this.mint,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.uiAmount,
    required this.sentiment,
    this.logoUrl,
    this.aiSummary,
    this.aiScore,
    this.price,
  });

  TokenInfo copyWith({
    String? sentiment,
    String? logoUrl,
    String? aiSummary,
    double? aiScore,
    double? price,
  }) => TokenInfo(
        mint: mint,
        symbol: symbol,
        name: name,
        decimals: decimals,
        uiAmount: uiAmount,
        sentiment: sentiment ?? this.sentiment,
        logoUrl: logoUrl ?? this.logoUrl,
        aiSummary: aiSummary ?? this.aiSummary,
        aiScore: aiScore ?? this.aiScore,
        price: price ?? this.price,
      );

  Map<String, dynamic> toJson() => {
        'mint': mint,
        'symbol': symbol,
        'name': name,
        'decimals': decimals,
        'uiAmount': uiAmount,
        'sentiment': sentiment,
        'logoUrl': logoUrl,
        'aiSummary': aiSummary,
        'aiScore': aiScore,
        'price': price,
      };

  factory TokenInfo.fromJson(Map<String, dynamic> json) => TokenInfo(
        mint: json['mint'] as String,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        decimals: (json['decimals'] as num).toInt(),
        uiAmount: (json['uiAmount'] as num).toDouble(),
        sentiment: json['sentiment'] as String? ?? 'neutral',
        logoUrl: json['logoUrl'] as String?,
        aiSummary: json['aiSummary'] as String?,
        aiScore: (json['aiScore'] as num?)?.toDouble(),
        price: (json['price'] as num?)?.toDouble(),
      );
}
