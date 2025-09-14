import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class NewSettingsScreen extends ConsumerWidget {
  const NewSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    subtitle: Text(_getThemeLabel(settings.themeMode)),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (selection) {
                        ref.read(settingsProvider.notifier).setThemeMode(selection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Currency section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Display Currency'),
                    subtitle: Text('${settings.currency} (${settings.currencySymbol})'),
                    trailing: DropdownButton<String>(
                      value: settings.currency,
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                        DropdownMenuItem(value: 'KZT', child: Text('KZT (₸)')),
                        DropdownMenuItem(value: 'USDT', child: Text('USDT')),
                      ],
                      onChanged: (currency) {
                        if (currency != null) {
                          ref.read(settingsProvider.notifier).setCurrency(currency);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data & Updates section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data & Updates',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.refresh),
                    title: const Text('Live Updates'),
                    subtitle: const Text('Auto-refresh token data'),
                    value: settings.liveUpdatesEnabled,
                    onChanged: (enabled) {
                      ref.read(settingsProvider.notifier).setLiveUpdates(enabled);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Refresh Interval'),
                    subtitle: Text('${settings.pollingIntervalSeconds} seconds'),
                    trailing: DropdownButton<int>(
                      value: settings.pollingIntervalSeconds,
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30s')),
                        DropdownMenuItem(value: 60, child: Text('1m')),
                        DropdownMenuItem(value: 120, child: Text('2m')),
                        DropdownMenuItem(value: 300, child: Text('5m')),
                      ],
                      onChanged: (seconds) {
                        if (seconds != null) {
                          ref.read(settingsProvider.notifier).setPollingInterval(seconds);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filters section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.water_drop),
                    title: const Text('Min Liquidity'),
                    subtitle: Text('\$${settings.minLiquidityFilter.toStringAsFixed(0)}'),
                    trailing: SizedBox(
                      width: 120,
                      child: Slider(
                        value: settings.minLiquidityFilter,
                        min: 0,
                        max: 100000,
                        divisions: 20,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).setMinLiquidityFilter(value);
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Min 24h Gain'),
                    subtitle: Text('${settings.minGainFilter.toStringAsFixed(1)}%'),
                    trailing: SizedBox(
                      width: 120,
                      child: Slider(
                        value: settings.minGainFilter,
                        min: -50,
                        max: 100,
                        divisions: 30,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).setMinGainFilter(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cache & Storage section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Remove cached token data'),
                    trailing: OutlinedButton(
                      onPressed: () async {
                        await ref.read(settingsProvider.notifier).clearCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cache cleared')),
                          );
                        }
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // About section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('DueScan'),
                    subtitle: Text('Solana token scanner with AI assessment'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.code),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
