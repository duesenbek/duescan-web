
import '../models/token_info.dart';
import 'dex_data_service.dart';

/// Demo data service for showcasing DEX screener functionality without API dependencies
class DemoDataService {
  static List<TokenInfo> getDemoTokens() {
    return [
      TokenInfo(
        mint: 'So11111111111111111111111111111111111111112',
        symbol: 'SOL',
        name: 'Solana',
        decimals: 9,
        uiAmount: 2.5,
        sentiment: 'positive',
        logoUrl: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
        price: 142.50,
      ),
      TokenInfo(
        mint: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
        symbol: 'USDC',
        name: 'USD Coin',
        decimals: 6,
        uiAmount: 1000.0,
        sentiment: 'neutral',
        logoUrl: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png',
        price: 1.00,
      ),
      TokenInfo(
        mint: 'mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So',
        symbol: 'mSOL',
        name: 'Marinade staked SOL',
        decimals: 9,
        uiAmount: 5.2,
        sentiment: 'positive',
        logoUrl: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So/logo.svg',
        price: 158.75,
      ),
      TokenInfo(
        mint: 'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
        symbol: 'BONK',
        name: 'Bonk',
        decimals: 5,
        uiAmount: 1000000.0,
        sentiment: 'negative',
        logoUrl: 'https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I',
        price: 0.000025,
      ),
      TokenInfo(
        mint: 'JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN',
        symbol: 'JUP',
        name: 'Jupiter',
        decimals: 6,
        uiAmount: 150.0,
        sentiment: 'positive',
        logoUrl: 'https://static.jup.ag/jup/icon.png',
        price: 0.85,
      ),
    ];
  }

  static List<TrendingToken> getDemoTrendingTokens() {
    return [
      TrendingToken(
        mint: 'JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN',
        symbol: 'JUP',
        name: 'Jupiter',
        logoUri: 'https://static.jup.ag/jup/icon.png',
        price: 0.85,
        priceChange24h: 15.2,
        volume24h: 2500000,
        marketCap: 850000000,
      ),
      TrendingToken(
        mint: 'So11111111111111111111111111111111111111112',
        symbol: 'SOL',
        name: 'Solana',
        logoUri: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
        price: 142.50,
        priceChange24h: 8.7,
        volume24h: 15000000,
        marketCap: 67000000000,
      ),
      TrendingToken(
        mint: 'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
        symbol: 'BONK',
        name: 'Bonk',
        logoUri: 'https://arweave.net/hQiPZOsRZXGXBJd_82PhVdlM_hACsT_q6wqwf5cSY7I',
        price: 0.000025,
        priceChange24h: -12.3,
        volume24h: 800000,
        marketCap: 1500000000,
      ),
      TrendingToken(
        mint: 'mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So',
        symbol: 'mSOL',
        name: 'Marinade staked SOL',
        logoUri: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So/logo.svg',
        price: 158.75,
        priceChange24h: 9.1,
        volume24h: 1200000,
        marketCap: 1200000000,
      ),
      TrendingToken(
        mint: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
        symbol: 'USDC',
        name: 'USD Coin',
        logoUri: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png',
        price: 1.00,
        priceChange24h: 0.1,
        volume24h: 25000000,
        marketCap: 32000000000,
      ),
    ];
  }

  static DexTokenData getDemoTokenData(String mint) {
    final demoData = {
      'So11111111111111111111111111111111111111112': DexTokenData(
        mint: 'So11111111111111111111111111111111111111112',
        price: 142.50,
        priceChange24h: 8.7,
        volume24h: 15000000,
        liquidity: 5000000,
        marketCap: 67000000000,
        holders: 2500000,
        lastUpdated: DateTime.now(),
      ),
      'JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN': DexTokenData(
        mint: 'JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN',
        price: 0.85,
        priceChange24h: 15.2,
        volume24h: 2500000,
        liquidity: 800000,
        marketCap: 850000000,
        holders: 150000,
        lastUpdated: DateTime.now(),
      ),
    };
    
    return demoData[mint] ?? DexTokenData(
      mint: mint,
      price: 1.0,
      priceChange24h: 0.0,
      volume24h: 100000,
      liquidity: 50000,
      marketCap: 1000000,
      holders: 1000,
      lastUpdated: DateTime.now(),
    );
  }
}
