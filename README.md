# DueScan

A minimalistic Flutter app for scanning Solana tokens with AI-powered growth potential assessment. Built with clean architecture, Material 3 design, and production-ready features.

## Features

### Core Functionality
- 🔥 **Trending Tokens**: Real-time trending Solana tokens with volume and price data
- 🔍 **Token Search**: Search by name, symbol, or contract address with pagination
- 📊 **Token Details**: Comprehensive token information with price charts and metrics
- 🤖 **AI Assessment**: Heuristic-based growth potential scoring (High/Medium/Low)
- 💱 **Multi-Currency**: Support for USD, EUR, KZT, and USDT display

### Technical Features
- ⚡ **Caching & Offline**: Smart caching with offline snapshots using SharedPreferences
- 🔄 **Auto-Refresh**: Configurable live updates (30s, 1m, 2m, 5m intervals)
- 🎨 **Material 3**: Modern UI with adaptive theming (Light/Dark/System)
- 📱 **Responsive**: Works on mobile, tablet, and web with adaptive layouts
- 🚀 **Performance**: Rate-limited API calls with exponential backoff and retries
- 🧪 **Tested**: Unit tests for services and widget tests for components

## Architecture

### Clean Architecture with Riverpod
```
lib/
├── models/           # Data models (Pair, TokenProfile, etc.)
├── services/         # Business logic and API clients
│   ├── dexscreener_service.dart  # DexScreener API with caching
│   └── ai_service.dart           # AI assessment heuristics
├── providers/        # Riverpod state management
│   ├── settings_provider.dart    # App settings and preferences
│   ├── tokens_provider.dart      # Trending tokens with auto-refresh
│   └── search_provider.dart      # Search with debouncing
├── screens/          # UI screens
├── widgets/          # Reusable UI components
└── utils/           # Formatters, network utils, rate limiter
```

### Key Services
- **DexscreenerService**: Dio-based HTTP client with rate limiting, caching (60s TTL), and exponential backoff
- **AiService**: Deterministic heuristic combining momentum, volume, and liquidity for growth assessment
- **Providers**: Riverpod-based state management with auto-refresh and offline caching

## Requirements
- Flutter 3.22+ (Dart 3.3+)
- Web, iOS, Android support

## Setup

### 1. Install Flutter
```bash
flutter config --enable-web
```

### 2. Clone and Install Dependencies
```bash
git clone <repository-url>
cd duescan
flutter pub get
```

### 3. Environment Configuration (Optional)
Create `.env` file for custom settings:
```env
# Optional: Custom RPC endpoint for better rate limits
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# Optional: Hugging Face API key for sentiment analysis
HUGGINGFACE_API_KEY=hf_xxx
```

### 4. Run the App
```bash
# Web
flutter run -d chrome

# Mobile (iOS/Android)
flutter run

# Production build
flutter build web --release
flutter build apk --release
flutter build ios --release
```

## Testing

### Run Tests
```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Test Structure
- `test/formatters_test.dart` - Unit tests for utility functions
- `test/widget_test.dart` - Basic widget tests
- Future: Service tests with mocked HTTP clients

## Deployment

### GitHub Pages (Automated)
The repository includes GitHub Actions workflows:

1. **CI Pipeline** (`.github/workflows/ci.yml`):
   - Runs on push/PR to `main`
   - Executes `flutter analyze` and `flutter test`

2. **Web Deployment** (`.github/workflows/deploy.yml`):
   - Triggers on push to `gh-pages-deploy` branch
   - Builds and deploys to GitHub Pages

To deploy:
```bash
git checkout -b gh-pages-deploy
git push origin gh-pages-deploy
```

### Manual Deployment
```bash
# Build for web
flutter build web --release --base-href=/your-repo-name/

# Deploy build/web/ to your hosting provider
```

## Configuration

### App Settings
The app includes comprehensive settings accessible via the Settings screen:

- **Theme**: Light/Dark/System adaptive theming
- **Currency**: USD ($), EUR (€), KZT (₸), USDT display
- **Auto-Refresh**: Configurable intervals (30s-5m) with live updates toggle
- **Filters**: Minimum liquidity and 24h gain filters
- **Cache Management**: Clear cached data option

### Performance Tuning
- **Rate Limiting**: Max 6 concurrent requests, 200ms minimum interval
- **Caching**: 60-second TTL for API responses, offline snapshots for trending tokens
- **Retries**: Exponential backoff on 429/5xx errors (up to 3 attempts)

## API Integration

### DexScreener API
The app integrates with DexScreener's public API:
- Latest token profiles
- Pair search and details
- Token boosts and trending data
- Solana chain focus with multi-chain support

### Rate Limiting & Caching
- Client-side rate limiting prevents API abuse
- Smart caching reduces redundant requests
- Offline-first approach with cached snapshots

## Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and add tests
4. Run tests: `flutter test`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use `flutter analyze` to check code quality
- Add tests for new features
- Update documentation as needed

## Screenshots

*Screenshots will be added here once the UI is finalized*

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- [DexScreener](https://dexscreener.com) for the excellent API
- [Flutter](https://flutter.dev) team for the amazing framework
- [Riverpod](https://riverpod.dev) for state management
- Material 3 design system
