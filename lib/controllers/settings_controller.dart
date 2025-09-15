import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  static const _liveUpdatesKey = 'live_updates_enabled';
  static const _pollIntervalKey = 'poll_interval_seconds';
  static const _localeKey = 'app_locale'; // 'en', 'ru', 'kk'
  static const _currencyKey = 'display_currency'; // 'USD','USDT','EUR','KZT'
  static const _gainers5mKey = 'filter_gainers5m_threshold'; // percent, e.g., 5.0
  static const _highLiqKey = 'filter_high_liquidity_threshold'; // USD, e.g., 500000

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _liveUpdatesEnabled = true;
  bool get liveUpdatesEnabled => _liveUpdatesEnabled;

  int _pollIntervalSeconds = 15;
  int get pollIntervalSeconds => _pollIntervalSeconds;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // Display currency (for formatting and simple conversion from USD)
  String _currency = 'USD';
  String get currency => _currency;

  // Very lightweight FX rates relative to USD; in real app fetch dynamically
  // Kept conservative to avoid surprises; user can still choose USDT which ~USD
  static const Map<String, double> _fx = {
    'USD': 1.0,
    'USDT': 1.0,
    'EUR': 0.92,
    'KZT': 485.0,
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_themeKey);
    switch (val) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    // Live updates enabled
    _liveUpdatesEnabled = prefs.getBool(_liveUpdatesKey) ?? true;
    // Poll interval seconds
    _pollIntervalSeconds = prefs.getInt(_pollIntervalKey) ?? 15;
    // Locale
    final code = prefs.getString(_localeKey);
    if (code == 'ru') {
      _locale = const Locale('ru');
    } else if (code == 'kk') {
      _locale = const Locale('kk');
    } else {
      _locale = const Locale('en');
    }
    // Currency
    _currency = prefs.getString(_currencyKey) ?? 'USD';

    // Filters thresholds (defaults)
    _gainers5mThreshold = (prefs.getDouble(_gainers5mKey)) ?? 5.0;
    _highLiquidityThreshold = (prefs.getDouble(_highLiqKey)) ?? 500000.0;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final val = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_themeKey, val);
  }

  Future<void> setLiveUpdatesEnabled(bool enabled) async {
    _liveUpdatesEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_liveUpdatesKey, enabled);
  }

  Future<void> setPollIntervalSeconds(int seconds) async {
    _pollIntervalSeconds = seconds;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pollIntervalKey, seconds);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final code = locale.languageCode;
    await prefs.setString(_localeKey, code);
  }

  Future<void> setCurrency(String code) async {
    if (!_fx.containsKey(code)) return;
    _currency = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }

  String get currencySymbol {
    switch (_currency) {
      case 'EUR':
        return '€';
      case 'KZT':
        return '₸';
      case 'USDT':
        return '\$';
      case 'USD':
      default:
        return '\$';
    }
  }

  double convertFromUsd(double usd) {
    final rate = _fx[_currency] ?? 1.0;
    return usd * rate;
  }

  // Filters: thresholds
  double _gainers5mThreshold = 5.0;
  double get gainers5mThreshold => _gainers5mThreshold;
  Future<void> setGainers5mThreshold(double v) async {
    _gainers5mThreshold = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_gainers5mKey, v);
  }

  double _highLiquidityThreshold = 500000.0;
  double get highLiquidityThreshold => _highLiquidityThreshold;
  Future<void> setHighLiquidityThreshold(double v) async {
    _highLiquidityThreshold = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_highLiqKey, v);
  }
}
