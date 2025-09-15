class TrendingToken {
  final String mint;
  final String symbol;
  final String name;
  final String logoUri;
  final double price;
  final double priceChange24h;
  final double volume24h;
  final double marketCap;

  TrendingToken({
    required this.mint,
    required this.symbol,
    required this.name,
    required this.logoUri,
    required this.price,
    required this.priceChange24h,
    required this.volume24h,
    required this.marketCap,
  });
}

class DexTokenData {
  final String mint;
  final double price;
  final double priceChange24h;
  final double volume24h;
  final double liquidity;
  final double marketCap;
  final int holders;
  final DateTime lastUpdated;

  DexTokenData({
    required this.mint,
    required this.price,
    required this.priceChange24h,
    required this.volume24h,
    required this.liquidity,
    required this.marketCap,
    required this.holders,
    required this.lastUpdated,
  });
}
