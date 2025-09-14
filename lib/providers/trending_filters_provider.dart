import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeFilter { min5, hour1, hour6, hour24 }
enum CategoryFilter { trending, newest, topVolume, topLiquidity }
enum SortFilter { volume, liquidity, marketCap, priceChange, pairAge }

class TrendingFiltersState {
  final TimeFilter? timeFilter;
  final CategoryFilter? categoryFilter;
  final SortFilter? sortFilter;
  final String searchQuery;

  const TrendingFiltersState({
    this.timeFilter,
    this.categoryFilter,
    this.sortFilter,
    this.searchQuery = '',
  });

  TrendingFiltersState copyWith({
    TimeFilter? timeFilter,
    CategoryFilter? categoryFilter,
    SortFilter? sortFilter,
    String? searchQuery,
  }) {
    return TrendingFiltersState(
      timeFilter: timeFilter,
      categoryFilter: categoryFilter,
      sortFilter: sortFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TrendingFiltersNotifier extends Notifier<TrendingFiltersState> {
  @override
  TrendingFiltersState build() {
    return const TrendingFiltersState();
  }

  void setTimeFilter(TimeFilter? filter) {
    state = state.copyWith(timeFilter: filter);
  }

  void setCategoryFilter(CategoryFilter? filter) {
    state = state.copyWith(categoryFilter: filter);
  }

  void setSortFilter(SortFilter filter) {
    state = state.copyWith(sortFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final trendingFiltersProvider = NotifierProvider<TrendingFiltersNotifier, TrendingFiltersState>(() {
  return TrendingFiltersNotifier();
});
