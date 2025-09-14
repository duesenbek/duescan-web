import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_info.dart';

/// Utility for caching wallet snapshots and app state
class StorageService {
  static const String _walletKey = 'last_wallet_address';
  static const String _tokensKey = 'last_tokens_snapshot';
  static const String _timestampKey = 'last_update_timestamp';
  static const String _rpcStatusKey = 'rpc_status';

  /// Save wallet snapshot with timestamp
  static Future<void> saveWalletSnapshot({
    required String walletAddress,
    required List<TokenInfo> tokens,
    DateTime? timestamp,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = timestamp ?? DateTime.now();
      
      await prefs.setString(_walletKey, walletAddress);
      await prefs.setString(_tokensKey, jsonEncode(tokens.map((t) => t.toJson()).toList()));
      await prefs.setInt(_timestampKey, now.millisecondsSinceEpoch);
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Load cached wallet snapshot
  static Future<WalletSnapshot?> loadWalletSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final wallet = prefs.getString(_walletKey);
      final tokensJson = prefs.getString(_tokensKey);
      final timestampMs = prefs.getInt(_timestampKey);
      
      if (wallet == null || tokensJson == null || timestampMs == null) {
        return null;
      }

      final tokensList = (jsonDecode(tokensJson) as List<dynamic>)
          .map((json) => TokenInfo.fromJson(json as Map<String, dynamic>))
          .toList();

      return WalletSnapshot(
        walletAddress: wallet,
        tokens: tokensList,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_walletKey);
      await prefs.remove(_tokensKey);
      await prefs.remove(_timestampKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Save RPC status for error recovery
  static Future<void> saveRpcStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_rpcStatusKey, status);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get last RPC status
  static Future<String?> getRpcStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_rpcStatusKey);
    } catch (e) {
      return null;
    }
  }

  /// Format timestamp for display
  static String formatLastUpdate(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'только что';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ч назад';
    } else {
      return '${timestamp.day}.${timestamp.month.toString().padLeft(2, '0')} в ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class WalletSnapshot {
  final String walletAddress;
  final List<TokenInfo> tokens;
  final DateTime timestamp;

  WalletSnapshot({
    required this.walletAddress,
    required this.tokens,
    required this.timestamp,
  });

  bool get isStale {
    final now = DateTime.now();
    return now.difference(timestamp).inMinutes > 5;
  }
}
