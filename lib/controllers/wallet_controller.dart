import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/token_info.dart';
// import '../services/ai_sentiment_service.dart';
// import '../services/solana_service.dart';
// import '../services/token_registry_service.dart';
// import '../services/token_price_service.dart';
import '../utils/storage.dart';

class WalletController extends ChangeNotifier {
  WalletController();

  // final SolanaService _solana;
  // final TokenRegistryService _registry;
  // final AiSentimentService _ai;
  // final TokenPriceService _prices;

  String walletAddress = '';
  bool isLoading = false;
  String? errorMessage;
  List<TokenInfo> tokens = [];
  DateTime? lastUpdated; // when tokens/prices last updated

  // UI controls
  String filterText = '';
  SortMode sortMode = SortMode.byBalanceDesc;

  void setFilterText(String value) {
    filterText = value;
    notifyListeners();
  }

  // Public helper to allow UI to populate demo tokens without entering a wallet
  Future<void> loadDemoData() => _loadDemoData();

  void setSortMode(SortMode mode) {
    sortMode = mode;
    notifyListeners();
  }

  // Persistence keys
  static const _prefsRefreshKey = 'price_refresh_seconds';

  // Price auto-refresh
  Timer? _priceTimer;
  int _priceRefreshSeconds = 60; // configurable via startPriceAutoRefresh
  int get priceRefreshSeconds => _priceRefreshSeconds;

  /// Load last wallet and cached token snapshot using StorageService
  Future<void> init() async {
    try {
      final snapshot = await StorageService.loadWalletSnapshot();
      if (snapshot != null) {
        walletAddress = snapshot.walletAddress;
        tokens = snapshot.tokens;
        lastUpdated = snapshot.timestamp;
        if ((tokens.isEmpty) && walletAddress.trim().isEmpty) {
          await _loadDemoData();
        }
      } else {
        // No cached data and no wallet set: show demo tokens so UI isn't empty
        if (walletAddress.trim().isEmpty) {
          await _loadDemoData();
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final refreshSecs = prefs.getInt(_prefsRefreshKey);
      if (refreshSecs != null) {
        _priceRefreshSeconds = refreshSecs;
      }
      
      // Start auto-refresh if we have cached tokens and interval > 0
      if (tokens.isNotEmpty && _priceRefreshSeconds > 0) {
        startPriceAutoRefresh(_priceRefreshSeconds);
      }
      
      notifyListeners();
    } catch (_) {
      // ignore initialization errors
    }
  }

  Future<void> _persistState() async {
    try {
      await StorageService.saveWalletSnapshot(
        walletAddress: walletAddress.trim(),
        tokens: tokens,
        timestamp: lastUpdated,
      );
    } catch (_) {
      // ignore storage errors
    }
  }

  List<TokenInfo> get filteredSortedTokens {
    Iterable<TokenInfo> list = tokens;
    if (filterText.trim().isNotEmpty) {
      final q = filterText.toLowerCase();
      list = list.where((t) => t.symbol.toLowerCase().contains(q) || t.name.toLowerCase().contains(q));
    }
    final l = list.toList();
    switch (sortMode) {
      case SortMode.byBalanceDesc:
        l.sort((a, b) => b.uiAmount.compareTo(a.uiAmount));
        break;
      case SortMode.byBalanceAsc:
        l.sort((a, b) => a.uiAmount.compareTo(b.uiAmount));
        break;
      case SortMode.byAiScoreDesc:
        l.sort((a, b) => (b.aiScore ?? 0).compareTo(a.aiScore ?? 0));
        break;
      case SortMode.byAiScoreAsc:
        l.sort((a, b) => (a.aiScore ?? 0).compareTo(b.aiScore ?? 0));
        break;
    }
    return l;
  }

  Future<void> fetchTokens() async {
    if (walletAddress.trim().isEmpty) {
      errorMessage = 'Please enter a wallet address';
      notifyListeners();
      return;
    }

    // Basic validation for Solana wallet address
    final trimmed = walletAddress.trim();
    if (trimmed.length < 32 || trimmed.length > 44) {
      errorMessage = 'Invalid Solana wallet address format';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    tokens = [];
    notifyListeners();

    // Use demo data if API is unavailable
    try {
      await _fetchTokensFromAPI();
    } catch (e) {
      print('API unavailable, using demo data: $e');
      await _loadDemoData();
    }
  }

  Future<void> _loadDemoData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    
    final demoTokens = [
      TokenInfo(
        mint: 'So11111111111111111111111111111111111111112',
        symbol: 'SOL',
        name: 'Solana',
        decimals: 9,
        uiAmount: 2.5,
        sentiment: 'positive',
        logoUrl: 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
        price: 142.50,
        aiScore: 0.85,
        aiSummary: 'Bullish trend with strong fundamentals',
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
        aiScore: 0.5,
        aiSummary: 'Stable coin with consistent value',
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
        aiScore: 0.78,
        aiSummary: 'Strong DEX aggregator with growing adoption',
      ),
    ];

    tokens = demoTokens;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _fetchTokensFromAPI() async {
    try {
      // TODO: Implement when services are available
      throw Exception('Services not implemented yet');
      
      // final accounts = await _solana.getSplTokenAccountsByOwner(walletAddress.trim());

      // // 1) Build preliminary list quickly (mint/meta/balance only)
      // final prelim = <TokenInfo>[];
      // for (final a in accounts) {
      //   final meta = await _registry.getMeta(a.mint, defaultDecimals: a.decimals);
      //   prelim.add(TokenInfo(
      //     mint: a.mint,
      //     symbol: meta.symbol,
      //     name: meta.name,
      //     decimals: meta.decimals,
      //     uiAmount: a.uiAmount,
      //     sentiment: 'neutral',
      //     logoUrl: meta.logoUrl,
      //     price: 0.0,
      //   ));
      // }

      // // Show tokens immediately
      // tokens = prelim;
      // lastUpdated = DateTime.now();
      // isLoading = false;
      // notifyListeners();
      // await _persistState();

      // // Ensure price auto-refresh is running
      // startPriceAutoRefresh(_priceRefreshSeconds);

      // // 2) Enrich in background with AI + price
      // for (var i = 0; i < tokens.length; i++) {
      //   final t = tokens[i];
      //   try {
      //     final (sentiment, score, summary) = await _ai.analyzeDetailed('${t.symbol} ${t.name}'.trim());
      //     final price = await _prices.getUsdPriceByMint(t.mint);
      //     final updated = t.copyWith(
      //       sentiment: sentiment,
      //       aiScore: score,
      //       aiSummary: summary,
      //       price: price ?? t.price,
      //     );
      //     // Replace at index and notify for partial update
      //     final newList = List<TokenInfo>.from(tokens);
      //     newList[i] = updated;
      //     tokens = newList;
      //     lastUpdated = DateTime.now();
      //     notifyListeners();
      //   } catch (_) {
      //     // ignore individual token errors; continue enriching others
      //   }
      // }
      // // Persist after enrichment pass
      // await _persistState();
    } catch (e) {
      errorMessage = 'Failed to fetch: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Configure and start periodic price refresh. Pass seconds <= 0 to stop.
  void startPriceAutoRefresh(int seconds) {
    _priceRefreshSeconds = seconds;
    _priceTimer?.cancel();
    if (seconds <= 0) return;
    _priceTimer = Timer.periodic(Duration(seconds: seconds), (_) {
      _refreshPricesOnce();
    });
    // persist preference
    _persistRefreshPref();
  }

  void setPriceRefreshSeconds(int seconds) {
    startPriceAutoRefresh(seconds);
    notifyListeners();
  }

  Future<void> _persistRefreshPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsRefreshKey, _priceRefreshSeconds);
    } catch (_) {}
  }

  Future<void> _refreshPricesOnce() async {
    if (tokens.isEmpty) return;
    try {
      final updated = <TokenInfo>[];
      for (final t in tokens) {
        final p = await _prices.getUsdPriceByMint(t.mint);
        updated.add(t.copyWith(price: p ?? t.price));
      }
      tokens = updated;
      lastUpdated = DateTime.now();
      notifyListeners();
      await _persistState();
    } catch (_) {
      // ignore background errors
    }
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }
  // Add missing methods for Riverpod compatibility
  void setWalletAddress(String address) {
    walletAddress = address;
    notifyListeners();
  }
}

enum SortMode { byBalanceDesc, byBalanceAsc, byAiScoreDesc, byAiScoreAsc }
