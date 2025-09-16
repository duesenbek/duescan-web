<img width="413" height="422" alt="image" src="https://github.com/user-attachments/assets/facf7751-2af4-443c-b87d-a792a6f7abb1" /># **DueScan**

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
🌐 **Telegram Mini-App**:[https://t.me/DueScanBot]
)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/duesenbek/duescan-web
cd duescan-web

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome  # For web

```

## Tech Stack

- **Flutter 3.22+** with Dart 3.3+
- **Material 3** design system
- **DexScreener API** for token data
- **Trust Wallet assets** for token icons
- **Sf-Pro,Inter** fonts
  ## other dependencies
- **flutter_riverpod: ^2.5.1** for state management
- **dio: ^5.5.0+1** for working with http 
- **Iconly: ^1.0.1** for system icons
- **Cached Network Image** for token icons
- 
## Architecture

```
lib/
├── models/           # Data models (Pair, Token)
├── providers/        # Riverpod state management
├── screens/          # UI screens (Home, My Space, Settings)
├── widgets/          # Reusable components
└── utils/           # Formatters and utilities
```


