# NYX App

NYX is a Flutter mobile application focused on sports and active lifestyle services. It combines e-commerce, booking workflows, tournament information, training enrollment, and account management into a single app experience.

## Product Overview

The app is designed as a digital marketplace and service platform for sports-related needs. Users can:

- Browse a dashboard with banners, categories, and featured products
- Explore a shop with product listings and category-based filtering
- Add items to a shopping cart and manage checkout flows
- Book sports facilities, rental courts, and walk-in slots
- Enroll in classes and training sessions
- View tournament schedules, banners, and registration-related screens
- Manage login, sessions, and account information

## Application Scope

This is not a simple demo app; it is structured like a small mobile commerce and booking platform with multiple service modules. Each feature is organized around its own domain/data/presentation pattern, which keeps UI, API logic, and business rules separated by module.

## Features

- Home dashboard with banner carousel and category navigation
- Product catalog with category and tag views
- Cart management with persistent runtime state
- Rental and walk-in booking system for courts and venues
- Training/class enrollment and booking history
- Tournament information screens and banners
- Account management and user session handling
- Support for media, sharing, permissions, and external links

## Architecture

The project follows a feature-first layered architecture, with a partial clean-architecture style across major modules.

### 1. App bootstrap

The application starts in `lib/main.dart` where the root app wires together global services:

- `SessionService` initializes and provides session state
- `CartService` manages cart state across the app
- `TournamentBannerController` is registered through `Provider`
- `MaterialApp` sets the light theme and launches `SplashScreen`

This creates a central app-level dependency graph before the user enters the main dashboard.

### 2. Core shared layer

The `lib/core` folder contains reusable infrastructure and cross-cutting concerns:

- `core/network/` — API client and response handling
- `core/error/` — centralized app error messaging and exceptions
- `core/utils/` — app constants and theme definitions
- `core/presentation/widgets/` — reusable UI widgets such as error views

This layer avoids repeating networking and UI error-handling logic across modules.

### 3. Feature modules

Each feature folder roughly follows this pattern:

```text
lib/features/<feature>/
├── data/
│   ├── datasources/
│   ├── repositories/
│   └── models/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── bloc/ or controllers/
└── ...
```

Examples in this project include:

- `dashboard/` — home dashboard, service widgets, banners, categories, products
- `shop/` — products, listing pages, tags, categories, details, and purchase flow
- `cart/` — cart logic, item management, and cart UI
- `rental/` — venue and court booking with walk-in and reservation flows
- `training/` — training classes, payment flow, and enrollment screens
- `tournament/` — banners, rankings, schedules, and registration-related UI
- `orders/` — order history and payment interactions
- `user/` — login, signup, account pages, session persistence, and user data access

### 4. Presentation layer

The presentation layer contains the user-facing screens and widgets. In the app shell, `MainDashboard` acts as the main navigation container with a bottom navigation bar for:

- Home
- Shop
- Services
- Walk-In
- Account

Each screen uses standard Flutter widgets, custom cards, and page-based navigation patterns.

### 5. State management pattern

The app primarily uses `Provider` for app-wide state, including:

- `SessionService` for user login/session status
- `CartService` for item count and cart data
- `TournamentBannerController` to load and manage tournament banner data

This is a lightweight state management pattern appropriate for a medium-sized Flutter app without deep dependency injection infrastructure.

### 6. Data flow

A typical request follows this path:

1. User interacts with a screen in `presentation/pages`
2. A controller, provider, or widget triggers a feature action
3. A repository/service is called
4. The repository delegates to a data source
5. API client makes HTTP requests
6. Results are parsed into domain entities
7. UI rebuilds with the loaded data

For example, `TournamentBannerController` obtains banners via a repository implementation whose data source fetches remote banner data.

### 7. Bookings and business flows

The app includes multiple service flows that map closely to real sports-center use cases:

- Rental booking of courts and venues
- Walk-in booking by slot or court
- Order/payment pages for products and services
- Training sign-up and event registration
- Account session persistence across the app lifecycle

These flows are implemented as feature pages with a combination of local state and API-based data retrieval.

## Project Structure

```text
lib/
├── core/
│   ├── error/
│   ├── network/
│   ├── presentation/
│   └── utils/
├── features/
│   ├── cart/
│   ├── dashboard/
│   ├── orders/
│   ├── rental/
│   ├── shop/
│   ├── tournament/
│   ├── training/
│   └── user/
├── main.dart
├── ...
└── assets/
    ├── appIcon/
    ├── classes/
    ├── fonts/
    └── images/
```

## Key Technical Components

- `Provider` for app-level service sharing
- `SharedPreferences` and local storage for user/session persistence
- `sqflite` for local data storage and structured persistence
- `http` for remote API calls
- `image_picker` for media capture or media selection
- `share_plus`, `screenshot`, `url_launcher`, and permissions handlers for full app interaction support
- `flutter_launcher_icons` for icon generation and branding

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed and compatible with the version in `pubspec.yaml`
- Android Studio / VS Code with Flutter tooling
- A running Android or iOS emulator, or a connected physical device

## Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd nyxproject
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

## Common Commands

```bash
# Check Flutter environment
flutter doctor

# Run debug build
flutter run

# Run tests
flutter test

# Build Android APK
flutter build apk

# Build iOS app (macOS only)
flutter build ios
```

## Runtime Flow

A typical user journey is:

1. App starts and initializes session and cart services
2. Splash screen loads configuration and decides the landing state
3. Main dashboard opens with bottom navigation
4. User browses home, shop, booking, or account screens
5. Selected services request data from backend APIs
6. State updates are reflected in the UI through `setState` or `Provider`
7. User actions such as booking, checkout, or login persist data locally or through APIs

## Notes

- This project uses a modular, feature-oriented structure rather than a single monolithic screen set.
- Network logic is separated into data sources and repository layers, making it easier to extend.
- The app depends on backend APIs being available and correctly configured for features such as bookings, categories, products, and banners.
- The project includes app icon generation configuration and a custom font setup.

## License

This project is currently configured as a private application and is not published to pub.dev.
