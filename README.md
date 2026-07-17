# 📚 Bookly — Flutter Book Store App

A modern, premium-looking Flutter mobile app for browsing and ordering books, built with **Riverpod**, **Dio**, and **go_router**. Connects to the [Bookly REST API](https://github.com/AbdelrhmanSamy1/bookly-rest).

---

## ✨ Features

| Feature | Description |
|---|---|
| **Authentication** | Register/Login with JWT, auto token refresh, persistent sessions |
| **Book Browsing** | Browse by category, search with filters, paginated results |
| **Book Details** | Hero animations, SliverAppBar, price/stock/year stats |
| **Shopping Cart** | Add/remove items, quantity controls, checkout flow |
| **Order Tracking** | View order history with status badges (Pending → Delivered) |
| **Dark Theme** | Premium dark UI with gradients, glassmorphism, and micro-animations |

## 📱 Screenshots

> Run the app to experience the full UI — deep navy theme with teal accents, gradient book covers, and smooth transitions.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.10+) |
| **State Management** | Riverpod 3 (AsyncNotifier, NotifierProvider) |
| **HTTP Client** | Dio 5 with auth interceptor |
| **Routing** | go_router (ShellRoute + bottom nav) |
| **Typography** | Google Fonts (Inter, Outfit) |
| **Storage** | SharedPreferences (JWT persistence) |

## 📐 Architecture

Clean architecture with feature-first organization:

```
lib/
├── main.dart                              # Entry point (ProviderScope)
├── core/
│   ├── network/
│   │   ├── api_endpoints.dart             # Centralized API paths
│   │   └── dio_client.dart                # Dio instance + JWT interceptor
│   ├── router/
│   │   └── app_router.dart                # GoRouter + bottom navigation shell
│   ├── theme/
│   │   └── app_theme.dart                 # Dark theme, colors, typography
│   └── utils/
│       ├── constants.dart                 # Base URL, keys
│       └── token_storage.dart             # JWT persistence
├── features/
│   ├── auth/
│   │   ├── data/                          # Repository + models
│   │   ├── providers/auth_provider.dart   # AsyncNotifier (login, register, logout)
│   │   └── presentation/screens/          # Login & Register screens
│   ├── books/
│   │   ├── data/                          # Repository + models (Book, Author, Category)
│   │   ├── providers/book_provider.dart   # FutureProviders + search filter
│   │   └── presentation/
│   │       ├── screens/                   # Home, Detail, Search
│   │       └── widgets/                   # BookCard, CategoryChip
│   ├── cart/
│   │   ├── providers/cart_provider.dart   # Local cart state (Notifier)
│   │   └── presentation/                 # Cart screen + item cards
│   └── orders/
│       ├── data/                          # Repository + models
│       ├── providers/order_provider.dart  # FutureProvider.family
│       └── presentation/screens/          # Orders list + detail
```

## 🎨 UI Design

| Aspect | Implementation |
|---|---|
| **Background** | Deep navy `#0A0E21` |
| **Primary Accent** | Teal-to-cyan gradient `#00BFA6 → #00E5FF` |
| **Cards** | Glassmorphic with subtle white borders |
| **Book Covers** | 8 unique gradient palettes based on book ID |
| **Typography** | Inter (body) + Outfit (headings) via Google Fonts |
| **Bottom Nav** | 4 tabs — Home, Search, Cart (with badge), Orders |
| **Animations** | Hero transitions, fade-in auth screens, animated chips |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Dart 3.x

### Run

```bash
# Clone
git clone https://github.com/AbdelrhmanSamy1/bookly-app.git
cd bookly-app

# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### Configuration

The app connects to the live API by default. To point to a local backend, edit [`lib/core/utils/constants.dart`](lib/core/utils/constants.dart):

```dart
const String kBaseUrl = 'http://10.0.2.2:8080/api/v1'; // Android emulator
// const String kBaseUrl = 'http://localhost:8080/api/v1'; // Web/Desktop
```

## 🔗 Backend API

This app is the frontend for the **Bookly REST API**:

| | |
|---|---|
| **Repository** | [`AbdelrhmanSamy1/bookly-rest`](https://github.com/AbdelrhmanSamy1/bookly-rest) |
| **Live API** | [`bookly-rest-production.up.railway.app`](https://bookly-rest-production.up.railway.app) |
| **Swagger Docs** | [`/swagger-ui.html`](https://bookly-rest-production.up.railway.app/swagger-ui.html) |

## 📦 Key Packages

```yaml
dependencies:
  flutter_riverpod: ^3.3.2    # State management
  dio: ^5.10.0                # HTTP client
  go_router: ^17.3.0          # Navigation
  google_fonts: ^8.2.0        # Typography
  shared_preferences: ^2.5.5  # Token storage
```

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
