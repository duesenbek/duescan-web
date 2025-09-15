import 'package:flutter_riverpod/flutter_riverpod.dart';

const Object _undefined = Object();

enum TimeInterval { min5, hour1, hour6, hour24 }

enum FilterType { trending, new_, top, sort, search }

enum SortOption { 
  rankPairs, 
  mostVolume, 
  mostTxns, 
  mostLiquidity, 
  pairAgeNewest, 
  pairAgeOldest, 
  marketCapHighest, 
  trending,
  priceChangeUp,
  priceChangeDown
}

class TrendingFiltersState {
  final FilterType? activeFilter;
  final TimeInterval? timeInterval;
  final SortOption? sortOption;
  final TimeInterval? sortTimeInterval; // For sort options that need time
  final String searchQuery;
  final bool isSearchActive;

  const TrendingFiltersState({
    this.activeFilter,
    this.timeInterval,
    this.sortOption,
    this.sortTimeInterval,
    this.searchQuery = '',
    this.isSearchActive = false,
  });

  TrendingFiltersState copyWith({
    Object? activeFilter = _undefined,
    Object? timeInterval = _undefined,
    Object? sortOption = _undefined,
    Object? sortTimeInterval = _undefined,
    String? searchQuery,
    bool? isSearchActive,
  }) {
    return TrendingFiltersState(
      activeFilter: activeFilter == _undefined ? this.activeFilter : activeFilter as FilterType?,
      timeInterval: timeInterval == _undefined ? this.timeInterval : timeInterval as TimeInterval?,
      sortOption: sortOption == _undefined ? this.sortOption : sortOption as SortOption?,
      sortTimeInterval: sortTimeInterval == _undefined ? this.sortTimeInterval : sortTimeInterval as TimeInterval?,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }
}

class TrendingFiltersNotifier extends Notifier<TrendingFiltersState> {
  @override
  TrendingFiltersState build() {
    return const TrendingFiltersState(
      activeFilter: FilterType.trending,
      timeInterval: TimeInterval.hour24,
    );
  }

  void setActiveFilter(FilterType? filter) {
    state = state.copyWith(
      activeFilter: filter,
      isSearchActive: filter == FilterType.search,
    );
  }

  void setTimeInterval(TimeInterval? interval) {
    state = state.copyWith(timeInterval: interval);
  }

  void setSortOption(SortOption? option, {TimeInterval? timeInterval}) {
    state = state.copyWith(
      sortOption: option,
      sortTimeInterval: timeInterval,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleSearch() {
    state = state.copyWith(
      isSearchActive: !state.isSearchActive,
      activeFilter: state.isSearchActive ? null : FilterType.search,
      searchQuery: state.isSearchActive ? '' : state.searchQuery,
    );
  }

  void clearFilters() {
    state = const TrendingFiltersState();
  }
}

final trendingFiltersProvider = NotifierProvider<TrendingFiltersNotifier, TrendingFiltersState>(() {
  return TrendingFiltersNotifier();
});
