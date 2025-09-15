# DueScan

A Flutter app for tracking trending Solana tokens with real-time data from DexScreener API.

## Features

- 🔥 **Trending Tokens**: Live trending Solana tokens with auto-refresh
- 🔍 **Smart Filters**: Filter by time periods (5min, 1h, 6h, 24h) and categories
- ⭐ **Favorites**: Save and track your favorite tokens
- 🌙 **Dark Theme**: Material 3 design with dark theme by default
- 📱 **Pull to Refresh**: Swipe down to update token data
- 💰 **Real-time Data**: Price, volume, liquidity, and market cap information

## Live Demo

🌐 **Web App**: [https://duesenbek.github.io/duescan-web/](https://duesenbek.github.io/duescan-web/)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/duesenbek/duescan-web
cd duescan-web

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome  # For web
flutter run             # For mobile
```

## Tech Stack

- **Flutter 3.22+** with Dart 3.3+
- **Riverpod** for state management
- **Material 3** design system
- **DexScreener API** for token data
- **Cached Network Image** for token icons

## Architecture

```
lib/
├── models/           # Data models (Pair, Token)
├── providers/        # Riverpod state management
├── screens/          # UI screens (Home, My Space, Settings)
├── widgets/          # Reusable components
└── utils/           # Formatters and utilities
```


