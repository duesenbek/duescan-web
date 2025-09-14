import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final String currency;
  final int pollingIntervalSeconds;
  final bool liveUpdatesEnabled;
  final double minLiquidityFilter;
  final double minGainFilter;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.currency = 'USD',
    this.pollingIntervalSeconds = 60,
    this.liveUpdatesEnabled = true,
    this.minLiquidityFilter = 1000,
    this.minGainFilter = 0,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currency,
    int? pollingIntervalSeconds,
    bool? liveUpdatesEnabled,
    double? minLiquidityFilter,
    double? minGainFilter,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      pollingIntervalSeconds: pollingIntervalSeconds ?? this.pollingIntervalSeconds,
      liveUpdatesEnabled: liveUpdatesEnabled ?? this.liveUpdatesEnabled,
      minLiquidityFilter: minLiquidityFilter ?? this.minLiquidityFilter,
      minGainFilter: minGainFilter ?? this.minGainFilter,
    );
  }

  String get currencySymbol {
    switch (currency) {
      case 'EUR': return '€';
      case 'KZT': return '₸';
      case 'USDT': return 'USDT';
      default: return '\$';
    }
  }

  double convertFromUsd(double usdValue) {
    // Simple conversion rates - in production, fetch from API
    switch (currency) {
      case 'EUR': return usdValue * 0.85;
      case 'KZT': return usdValue * 450;
      case 'USDT': return usdValue;
      default: return usdValue;
    }
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 2; // Default to dark theme
    final currency = prefs.getString('currency') ?? 'USD';
    final polling = prefs.getInt('polling_interval') ?? 60;
    final liveUpdates = prefs.getBool('live_updates') ?? true;
    final minLiq = prefs.getDouble('min_liquidity') ?? 1000;
    final minGain = prefs.getDouble('min_gain') ?? 0;

    state = AppSettings(
      themeMode: ThemeMode.values[themeIndex],
      currency: currency,
      pollingIntervalSeconds: polling,
      liveUpdatesEnabled: liveUpdates,
      minLiquidityFilter: minLiq,
      minGainFilter: minGain,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  Future<void> setPollingInterval(int seconds) async {
    state = state.copyWith(pollingIntervalSeconds: seconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('polling_interval', seconds);
  }

  Future<void> setLiveUpdates(bool enabled) async {
    state = state.copyWith(liveUpdatesEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('live_updates', enabled);
  }

  Future<void> setMinLiquidityFilter(double value) async {
    state = state.copyWith(minLiquidityFilter: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('min_liquidity', value);
  }

  Future<void> setMinGainFilter(double value) async {
    state = state.copyWith(minGainFilter: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('min_gain', value);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
