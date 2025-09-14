import 'package:equatable/equatable.dart';

class Token {
  final String address;
  final String symbol;
  final String name;
  final String? imageUrl;

  const Token({
    required this.address,
    required this.symbol,
    required this.name,
    this.imageUrl,
  });
}

class Pair extends Equatable {
  final String chainId;
  final String pairId;
  final String baseAddress;
  final Token baseToken;
  final Token quoteToken;
  final String? baseImageUrl;
  final String quoteAddress;
  final String quoteSymbol;
  final String quoteName;
  final double? priceUsd;
  final double? change5m;
  final double? change1h;
  final double? change24h;
  final double? volume24h;
  final double? liquidityUsd;
  final double? marketCapUsd;
  final double? marketCap;
  final double? fdv;
  final int? txns24h;
  final int? txnsBuy24h;
  final int? txnsSell24h;
  final DateTime? pairCreatedAt;

  const Pair({
    required this.chainId,
    required this.pairId,
    required this.baseAddress,
    required this.baseToken,
    required this.quoteToken,
    this.baseImageUrl,
    required this.quoteAddress,
    required this.quoteSymbol,
    required this.quoteName,
    this.priceUsd,
    this.change5m,
    this.change1h,
    this.change24h,
    this.volume24h,
    this.liquidityUsd,
    this.marketCapUsd,
    this.marketCap,
    this.fdv,
    this.txns24h,
    this.txnsBuy24h,
    this.txnsSell24h,
    this.pairCreatedAt,
  });

  // Backward compatibility getters
  Token get token => baseToken;
  String get baseSymbol => baseToken.symbol;
  String get baseName => baseToken.name;

  @override
  List<Object?> get props => [
        chainId,
        pairId,
        baseAddress,
        baseToken,
        quoteToken,
        baseImageUrl,
        quoteAddress,
        quoteSymbol,
        quoteName,
        priceUsd,
        change5m,
        change1h,
        change24h,
        volume24h,
        liquidityUsd,
        marketCapUsd,
        marketCap,
        fdv,
        txns24h,
        txnsBuy24h,
        txnsSell24h,
        pairCreatedAt,
      ];

  factory Pair.fromDex(Map<String, dynamic> j, {required String chainId}) {
    try {
      final baseToken = j['baseToken'] as Map<String, dynamic>?;
      final quoteToken = j['quoteToken'] as Map<String, dynamic>?;
      final priceChange = j['priceChange'] as Map<String, dynamic>?;
      final txns = j['txns'] as Map<String, dynamic>?;
      final volume = j['volume'] as Map<String, dynamic>?;
      final liquidity = j['liquidity'] as Map<String, dynamic>?;
      
      // Handle different txns formats
      final t24 = txns?['h24'] as Map<String, dynamic>? ?? 
                  txns?['24h'] as Map<String, dynamic>? ?? 
                  const <String, dynamic>{};

      return Pair(
        chainId: j['chainId'] as String? ?? chainId,
        pairId: j['pairAddress'] as String? ?? j['pairId'] as String? ?? '',
        baseAddress: baseToken?['address'] as String? ?? '',
        baseToken: Token(
          address: baseToken?['address'] as String? ?? '',
          symbol: baseToken?['symbol'] as String? ?? '',
          name: baseToken?['name'] as String? ?? '',
          imageUrl: j['info']?['imageUrl'] as String? ?? baseToken?['imageUrl'] as String?,
        ),
        quoteToken: Token(
          address: quoteToken?['address'] as String? ?? '',
          symbol: quoteToken?['symbol'] as String? ?? '',
          name: quoteToken?['name'] as String? ?? '',
          imageUrl: quoteToken?['imageUrl'] as String?,
        ),
        baseImageUrl: baseToken?['imageUrl'] as String?,
        quoteAddress: quoteToken?['address'] as String? ?? '',
        quoteSymbol: quoteToken?['symbol'] as String? ?? '',
        quoteName: quoteToken?['name'] as String? ?? '',
        priceUsd: _parseDouble(j['priceUsd']),
        change5m: _parseDouble(priceChange?['m5']) ?? _parseDouble(priceChange?['5m']),
        change1h: _parseDouble(priceChange?['h1']) ?? _parseDouble(priceChange?['1h']),
        change24h: _parseDouble(priceChange?['h24']) ?? _parseDouble(priceChange?['24h']),
        volume24h: _parseDouble(volume?['h24']) ?? _parseDouble(volume?['24h']) ?? _parseDouble(j['volume24h']),
        liquidityUsd: _parseDouble(liquidity?['usd']) ?? _parseDouble(j['liquidityUsd']),
        marketCapUsd: _parseDouble(j['marketCap']),
        marketCap: _parseDouble(j['marketCap']),
        fdv: _parseDouble(j['fdv']),
        pairCreatedAt: j['pairCreatedAt'] != null ? 
            DateTime.fromMillisecondsSinceEpoch(
              (j['pairCreatedAt'] is int) 
                ? j['pairCreatedAt'] as int
                : ((j['pairCreatedAt'] as num?)?.toInt() ?? 0) * 1000
            ) : null,
        txns24h: (_parseInt(t24['buys']) ?? 0) + (_parseInt(t24['sells']) ?? 0),
        txnsBuy24h: _parseInt(t24['buys']),
        txnsSell24h: _parseInt(t24['sells']),
      );
    } catch (e) {
      print('Error in Pair.fromDex: $e');
      print('Data: ${j.toString()}');
      rethrow;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
