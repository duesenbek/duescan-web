import 'package:flutter/widgets.dart';

class Strings {
  final Locale locale;
  Strings(this.locale);

  static Strings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Strings(locale);
  }

  String get _lang => locale.languageCode;

  String get navPortfolio => switch (_lang) { 'ru' => 'Портфель', 'kk' => 'Портфель', _ => 'Portfolio' };
  String get navTrending  => switch (_lang) { 'ru' => 'Тренды', 'kk' => 'Трендтер', _ => 'Trending' };
  String get navWatchlist => switch (_lang) { 'ru' => 'Избранное', 'kk' => 'Таңдаулы', _ => 'Watchlist' };
  String get navAllTokens => switch (_lang) { 'ru' => 'Все токены', 'kk' => 'Барлық токендер', _ => 'All Tokens' };
  String get navSettings => switch (_lang) { 'ru' => 'Настройки', 'kk' => 'Баптаулар', _ => 'Settings' };

  String get watchlistTitle => switch (_lang) { 'ru' => 'Избранные токены', 'kk' => 'Таңдаулы токендер', _ => 'Watchlist' };

  // Common UI strings
  String get copyAddress => switch (_lang) { 'ru' => 'Скопировать адрес', 'kk' => 'Мекенжайды көшіру', _ => 'Copy address' };
  String get addressCopied => switch (_lang) { 'ru' => 'Адрес скопирован', 'kk' => 'Мекенжай көшірілді', _ => 'Address copied' };
  String get loading => switch (_lang) { 'ru' => 'Загрузка...', 'kk' => 'Жүктелуде...', _ => 'Loading...' };
  String get noData => switch (_lang) { 'ru' => 'Нет данных', 'kk' => 'Деректер жоқ', _ => 'No data' };

  // Metrics labels
  String get m5 => '5m';
  String get h1 => '1h';
  String get h24 => '24h';
  String get d7 => '7d';
  String get vol24h => switch (_lang) { 'ru' => 'Объём 24ч', 'kk' => 'Көлем 24с', _ => 'Vol 24h' };
  String get liquidity => switch (_lang) { 'ru' => 'Ликвидность', 'kk' => 'Өтімділік', _ => 'Liquidity' };
  String get mcap => switch (_lang) { 'ru' => 'Кап.', 'kk' => 'Кап.', _ => 'MCAP' };

  // Actions
  String get openInDexscreener => switch (_lang) { 'ru' => 'Открыть в Dexscreener', 'kk' => 'Dexscreener-де ашу', _ => 'Open in Dexscreener' };
  String get buy => switch (_lang) { 'ru' => 'Купить', 'kk' => 'Сатып алу', _ => 'Buy' };
  String get viewOnDex => switch (_lang) { 'ru' => 'Открыть на DEX', 'kk' => 'DEX-те ашу', _ => 'View on DEX' };

  // Filters (Trending)
  String get filterGainers5m => switch (_lang) { 'ru' => '🔥 Рост 5м', 'kk' => '🔥 Өсу 5м', _ => '🔥 Gainers 5m' };
  String get filterLosers24h => switch (_lang) { 'ru' => '📉 Падение 24ч', 'kk' => '📉 Төмендеу 24с', _ => '📉 Losers 24h' };
  String get filterHighLiquidity => switch (_lang) { 'ru' => '💧 Высокая ликвидность', 'kk' => '💧 Жоғары өтімділік', _ => '💧 High Liquidity' };

  // Settings > Filters thresholds
  String get settingsFilters => switch (_lang) { 'ru' => 'Фильтры', 'kk' => 'Сүзгілер', _ => 'Filters' };
  String get gainers5mThreshold => switch (_lang) { 'ru' => 'Порог роста за 5м', 'kk' => '5м өсу шегі', _ => 'Gainers 5m threshold' };
  String get highLiquidityThreshold => switch (_lang) { 'ru' => 'Порог ликвидности', 'kk' => 'Өтімділік шегі', _ => 'High liquidity threshold' };
}
