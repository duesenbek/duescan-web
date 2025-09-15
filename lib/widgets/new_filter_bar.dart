import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import '../providers/trending_filters_provider.dart';

class NewFilterBar extends ConsumerWidget {
  const NewFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(trendingFiltersProvider);

    if (filters.isSearchActive) {
      return _buildSearchBar(context, ref, theme);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(
                    context: context,
                    ref: ref,
                    icon: IconlyLight.arrow_up,
                    label: 'Trending',
                    filterType: FilterType.trending,
                    isActive: filters.activeFilter == FilterType.trending,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    context: context,
                    ref: ref,
                    icon: IconlyLight.star,
                    label: 'New',
                    filterType: FilterType.new_,
                    isActive: filters.activeFilter == FilterType.new_,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    context: context,
                    ref: ref,
                    icon: IconlyLight.chart,
                    label: 'Top',
                    filterType: FilterType.top,
                    isActive: filters.activeFilter == FilterType.top,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    context: context,
                    ref: ref,
                    icon: IconlyLight.swap,
                    label: 'Sort',
                    filterType: FilterType.sort,
                    isActive: filters.activeFilter == FilterType.sort,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ref.read(trendingFiltersProvider.notifier).toggleSearch();
            },
            icon: const Icon(IconlyLight.search),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tokens...',
                prefixIcon: const Icon(IconlyLight.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ref.read(trendingFiltersProvider.notifier).setSearchQuery(value);
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ref.read(trendingFiltersProvider.notifier).toggleSearch();
            },
            icon: const Icon(IconlyLight.delete),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required FilterType filterType,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _handleFilterTap(context, ref, filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isActive 
              ? Border.all(color: theme.colorScheme.primary, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive 
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFilterTap(BuildContext context, WidgetRef ref, FilterType filterType) {
    final currentFilter = ref.read(trendingFiltersProvider).activeFilter;
    
    if (currentFilter == filterType) {
      // Deactivate if same filter is tapped
      ref.read(trendingFiltersProvider.notifier).setActiveFilter(null);
      return;
    }

    ref.read(trendingFiltersProvider.notifier).setActiveFilter(filterType);

    switch (filterType) {
      case FilterType.trending:
      case FilterType.new_:
      case FilterType.top:
        _showTimeIntervalBottomSheet(context, ref, filterType);
        break;
      case FilterType.sort:
        _showSortBottomSheet(context, ref);
        break;
      case FilterType.search:
        ref.read(trendingFiltersProvider.notifier).toggleSearch();
        break;
    }
  }

  void _showTimeIntervalBottomSheet(BuildContext context, WidgetRef ref, FilterType filterType) {
    String title = '';
    switch (filterType) {
      case FilterType.trending:
        title = 'Trending Time';
        break;
      case FilterType.new_:
        title = 'New Tokens Time';
        break;
      case FilterType.top:
        title = 'Top Tokens Time';
        break;
      default:
        title = 'Select Time';
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeIntervalOption(context, ref, TimeInterval.min5, '5 minutes'),
            _buildTimeIntervalOption(context, ref, TimeInterval.hour1, '1 hour'),
            _buildTimeIntervalOption(context, ref, TimeInterval.hour6, '6 hours'),
            _buildTimeIntervalOption(context, ref, TimeInterval.hour24, '24 hours'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeIntervalOption(BuildContext context, WidgetRef ref, TimeInterval interval, String label) {
    final theme = Theme.of(context);
    final currentInterval = ref.watch(trendingFiltersProvider).timeInterval;
    final isSelected = currentInterval == interval;

    return ListTile(
      title: Text(label),
      trailing: isSelected ? Icon(IconlyBold.tick_square, color: theme.colorScheme.primary) : null,
      tileColor: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      onTap: () {
        ref.read(trendingFiltersProvider.notifier).setTimeInterval(interval);
        Navigator.pop(context);
      },
    );
  }

  void _showSortBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSortSection(context, ref, 'Basic Sorting', [
                      (SortOption.rankPairs, 'Rank Pairs'),
                      (SortOption.mostVolume, 'Most Volume'),
                      (SortOption.mostTxns, 'Most Txns'),
                      (SortOption.mostLiquidity, 'Most Liquidity'),
                      (SortOption.pairAgeNewest, 'Pair Age – Newest'),
                      (SortOption.pairAgeOldest, 'Pair Age – Oldest'),
                      (SortOption.marketCapHighest, 'Market Cap – Highest'),
                    ]),
                    const SizedBox(height: 16),
                    _buildSortSection(context, ref, 'Trending', [
                      (SortOption.trending, 'Trending'),
                    ], hasTimeOptions: true),
                    const SizedBox(height: 16),
                    _buildSortSection(context, ref, 'Price Change – Up', [
                      (SortOption.priceChangeUp, 'Price Change – Up'),
                    ], hasTimeOptions: true),
                    const SizedBox(height: 16),
                    _buildSortSection(context, ref, 'Price Change – Down', [
                      (SortOption.priceChangeDown, 'Price Change – Down'),
                    ], hasTimeOptions: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortSection(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    List<(SortOption, String)> options,
    {bool hasTimeOptions = false}
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) => _buildSortOption(
          context, 
          ref, 
          option.$1, 
          option.$2, 
          hasTimeOptions: hasTimeOptions
        )),
      ],
    );
  }

  Widget _buildSortOption(
    BuildContext context, 
    WidgetRef ref, 
    SortOption option, 
    String label,
    {bool hasTimeOptions = false}
  ) {
    final theme = Theme.of(context);
    final currentSort = ref.watch(trendingFiltersProvider).sortOption;
    final isSelected = currentSort == option;

    return Column(
      children: [
        ListTile(
          title: Text(label),
          trailing: isSelected ? Icon(IconlyBold.tick_square, color: theme.colorScheme.primary) : null,
          tileColor: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
          onTap: () {
            ref.read(trendingFiltersProvider.notifier).setSortOption(option);
            if (!hasTimeOptions) {
              Navigator.pop(context);
            }
          },
        ),
        if (hasTimeOptions && isSelected) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 16),
            child: Row(
              children: [
                _buildTimeChip(context, ref, TimeInterval.hour24, '24 Hours'),
                const SizedBox(width: 8),
                _buildTimeChip(context, ref, TimeInterval.hour6, '6 Hours'),
                const SizedBox(width: 8),
                _buildTimeChip(context, ref, TimeInterval.hour1, '1 Hour'),
                const SizedBox(width: 8),
                _buildTimeChip(context, ref, TimeInterval.min5, '5 Minutes'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildTimeChip(BuildContext context, WidgetRef ref, TimeInterval interval, String label) {
    final theme = Theme.of(context);
    final currentInterval = ref.watch(trendingFiltersProvider).sortTimeInterval;
    final isSelected = currentInterval == interval;

    return GestureDetector(
      onTap: () {
        ref.read(trendingFiltersProvider.notifier).setSortOption(
          ref.read(trendingFiltersProvider).sortOption,
          timeInterval: interval,
        );
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
