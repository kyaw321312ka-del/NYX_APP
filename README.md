# NYX App

NYX is a Flutter mobile application focused on sports and active lifestyle services. It combines e-commerce, booking workflows, tournament information, training enrollment, and account management into a single app experience.

## Product Overview

NYX brings sports-center services together in one mobile app. The dashboard surfaces banners, categories, products, and service sections. Users can browse the catalog, manage a cart, submit orders, book facilities and walk-in courts, enroll in training, view tournament information, and manage their account.

## Application Scope

The app is organized as a set of feature modules. Some modules use domain entities, repository interfaces/implementations, and use cases; other screens call data sources or the shared API client more directly. The architecture is therefore feature-first with Clean Architecture patterns applied selectively, rather than a uniform Clean Architecture implementation.

## Features

- **Dashboard:** home banners, categories, featured products, and service entry points
- **Shop and cart:** product/category/tag browsing, product details, cart editing, checkout, and order history
- **Facility rentals:** venue and court discovery, availability/slot selection, booking, payment, and booking history
- **Walk-in:** court discovery and walk-in booking/payment flows
- **Training:** class discovery, enrollment, payment, and class lists
- **Tournaments:** tournament banners, details, schedules, rankings, and enrollment screens
- **User and account:** sign-in, sign-up, OTP and password flows, profile/settings, and support pages
- **Device integration:** image selection, screenshots, sharing, permissions, and external links

## Architecture

The project follows a feature-first layered architecture, with a partial clean-architecture style across major modules.

### 1. App bootstrap

The entry point is `lib/main.dart`. It initializes `SessionService`, creates the app-level `CartService`, and wires these plus feature dependencies into `MultiProvider`. The root `MaterialApp` applies `AppTheme.light` and opens `SplashScreen`. The splash screen displays for two seconds and then navigates to `MainDashboard`; it does not itself make an authentication-based routing decision. The sign-in state is used by account and protected actions elsewhere in the app.

### 2. Core shared layer

The `lib/core` folder contains reusable infrastructure and cross-cutting concerns:

- `core/network/` — shared API client and response representation
- `core/error/` — API exception type and user-facing error-message mapping
- `core/utils/` — API base URL configuration, request headers, and app theme
- `core/presentation/widgets/` — reusable shared UI such as retryable error views

The shared API client handles common account, profile, home, category, and tag requests. Several feature-specific data sources also make HTTP requests directly, so networking is not yet fully centralized.

### 3. Feature modules

Feature directories group code by responsibility. Where a feature uses the layered pattern, its structure resembles:

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

The principal modules are:

| Module | Responsibilities |
| --- | --- |
| `dashboard` | Home dashboard, service aggregation, banner/category widgets, and app shell |
| `shop` | Product catalog, category/tag views, product details, checkout, and tax |
| `cart` | Cart items, quantity/stock rules, totals, and cart screen |
| `orders` | Payment methods, order submission, and order history |
| `rental` | Venues, courts, availability, reservation and walk-in flows |
| `training` | Training data, class enrollment, payment, and class screens |
| `tournament` | Tournament banners and tournament information screens |
| `user` | Authentication, profile/account UI, and local session storage |

The feature tree is a convention, not a strict rule: some presentation pages contain local API/state logic, while selected flows use separate use cases and repositories.

The Shop catalog and checkout flows use the layered pattern:

```text
presentation page -> Cubit -> use case -> ShopRepository
                                      -> ShopRepositoryImpl
                                      -> ShopRemoteDataSource
                                      -> existing API/data-source clients
```

`ShopCatalogCubit` owns product/category loading, search, brand/category/tag
filters, sorting, and catalog errors. Product details use
`ShopRelatedProductsCubit` for recommendations. `ShopCheckoutCubit` loads
payment methods and tax and submits typed `ShopOrderRequest` values. The
repository boundary keeps these screens from calling catalog, tax, payment,
or order APIs directly. The checkout contact-info screen also validates the
server session through `ShopSessionCubit`. Cart contents and form controls
remain app/UI state.

### 4. Presentation layer

The presentation layer contains user-facing pages and widgets. `MainDashboard` in `lib/features/dashboard/presentation/pages/layout.dart` is the app shell. Its bottom navigation contains:

- Home
- Shop
- Services
- Walk-In
- Account

The shell keeps these five pages in an `IndexedStack`, preserving their widget state while switching tabs. Feature details and multi-step flows also use page-based navigation.

### 5. State management pattern

`Provider` exposes app services and selected feature controllers:

- `SessionService` stores and reads the user's login flag, token, token expiry, and serialized profile through `SharedPreferences`.
- `CartService` manages cart contents, quantities, stock limits, and totals in memory for the current app process; it does not persist cart data between launches.
- `ServicesController` tracks loading, data, and errors independently for training, venues, and canteen sections.
- `TournamentBannerController` loads tournament banner data and exposes loading/error state.

Many individual pages use Flutter `StatefulWidget`/`setState` for local form, selection, and loading state. This is a mixed state-management approach.

Shop catalog, product recommendations, and checkout use `flutter_bloc` Cubits
with immutable states for asynchronous data and errors. `Provider` remains in
use for app-wide services such as the session and cart, while other features
continue to use their existing `ChangeNotifier`, controller, or local widget
state patterns.

### 6. Data flow

A request in a repository-backed feature typically follows this path:

1. User interacts with a screen in `presentation/pages`
2. A controller or use case invokes a repository contract
3. The repository implementation calls a feature data source
4. The data source performs the HTTP request and parses the response into domain entities
5. The controller/Cubit publishes data or a mapped user-facing error
6. Provider notifies listeners, or a Bloc/Cubit builder rebuilds the UI

The Services tab is one example: `ServicesController` calls `GetServicesData`, which calls `ServicesRepository`; `ServicesRepositoryImpl` uses the training, venue, and canteen APIs. The tournament banner flow similarly separates its controller, use case, repository, and remote data source. Other screens may call a data source or `Api` directly, as the project is not uniformly layered.

### 7. Bookings and business flows

Booking and checkout pages coordinate user input, availability, payment method selection, optional payment-image upload, and submission to backend endpoints. Session tokens are obtained from `SessionService` for authenticated requests. Exact steps and available payment options depend on the backend response.

## Project Structure

```text
lib/
├── core/
│   ├── error/
│   ├── network/
│   ├── presentation/
│   └── utils/
├── features/
│   ├── cart/          # cart service and cart UI
│   ├── dashboard/     # app shell, home, services, banners
│   ├── orders/        # payment methods and order history
│   ├── rental/        # venue/court booking and walk-in flows
│   ├── shop/          # catalog, product details, checkout
│   ├── tournament/    # tournament screens and banners
│   ├── training/      # classes, enrollment, and payment
│   └── user/          # auth, profile, account, session
├── main.dart
└── ...
assets/
├── appIcon/           # launcher icon source images
├── classes/           # class artwork
├── fonts/             # Belanosima regular and bold
└── images/            # app imagery and branding
test/
├── features/
│   └── shop/presentation/bloc/
│       └── shop_bloc_test.dart  # catalog and checkout Cubit tests
└── widget_test.dart             # startup splash-screen smoke test
```

## Key Technical Components

- **Provider** and `ChangeNotifier` for shared services and feature controllers
- **SharedPreferences** for login/session values; cart state is in-memory
- **http** for backend requests
- **image_picker** for payment/profile image selection
- **share_plus**, **screenshot**, **url_launcher**, and **permission_handler** for device features
- **flutter_launcher_icons** for generating launcher icons from `assets/appIcon/nyx3.png`
- **Flutter Material** widgets, Material icons, Font Awesome icons, and the bundled Belanosima font

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK **3.41.6** (the version used by CI; `pubspec.yaml` requires Dart `^3.11.1`)
- JDK **17** for Android/Gradle builds
- Android SDK and an Android emulator or connected device for Android development
- Xcode on macOS for iOS builds
- Android Studio or VS Code with Flutter/Dart tooling
- A running Android or iOS emulator, or a connected physical device

## Backend configuration

The application reads the API origin from the `API_BASE_URL` Dart compile-time define. It defaults to the development URL configured in `lib/core/utils/app_constants.dart`; the app appends `/api` for most API routes. Set the origin (without a trailing `/api`) when running or building against a different backend:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

Use your environment's actual backend URL in place of the example. Ensure the device/emulator can reach it. Do not put credentials or private keys in Dart defines or commit them to the repository.

## Installation

1. Clone the repository and enter the project directory:
   ```bash
   git clone <repository-url>
   cd nyxproject
   ```

2. Check the local Flutter/Android toolchain:
   ```bash
   flutter doctor
   java -version
   ```
   Use JDK 17 for Android builds. CI configures Flutter to use the JDK 17 installed by GitHub Actions; no machine-specific `org.gradle.java.home` setting is required in `android/gradle.properties`.

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

   To use a non-default backend, pass `--dart-define=API_BASE_URL=...` as described above.

## Common Commands

```bash
# Check Flutter environment
flutter doctor

# Run debug build
flutter run

# Run tests
flutter test

# Build a release Android APK (JDK 17)
flutter build apk --release

# Build iOS app (macOS only)
flutter build ios --release

# Check Dart formatting and static analysis
dart format --output=none --set-exit-if-changed lib test
flutter analyze
```

## Continuous integration

`.github/workflows/flutter-ci.yml` runs on pushes and pull requests targeting `main`. The Android CI job:

1. Installs Temurin JDK 17 and Flutter 3.41.6
2. Fetches Dart/Flutter dependencies
3. Checks formatting, runs `flutter analyze`, and executes `flutter test`
4. Builds a release APK and uploads it as the `nyx-android-apk` artifact (7-day retention)

The workflow uses Flutter's configured JDK rather than a developer-specific Java installation path.

## Runtime Flow

A typical user journey is:

1. Flutter initializes, then `main()` initializes `SessionService` and creates `CartService`.
2. `MyApp` registers app dependencies with Provider and displays the splash screen.
3. After its two-second display, the splash screen opens `MainDashboard`.
4. The dashboard shell provides Home, Shop, Services, Walk-In, and Account tabs.
5. Screens request backend data through a controller/repository flow or a data source/API client, depending on the feature.
6. UI state is refreshed through Provider/`ChangeNotifier` or page-local `setState`.
7. Session data is stored in `SharedPreferences`; cart contents are held in memory; bookings, orders, and profile changes are submitted to backend APIs.

## Notes

- This project uses a modular, feature-oriented structure rather than a single monolithic screen set.
- Network logic is separated into data sources and repository layers, making it easier to extend.
- The app depends on backend APIs being available and correctly configured for features such as bookings, categories, products, and banners.
- The app requires a reachable backend for live catalog, account, booking, payment-method, training, and tournament data.
- In Android development, Gradle should use JDK 17. Avoid committing a local absolute Java path in `android/gradle.properties`.
- The current automated widget test verifies that the splash screen renders at startup; it is not an end-to-end test of backend flows.
- Launcher icon configuration and the custom font are declared in `pubspec.yaml`.

## License

This project is currently configured as a private application and is not published to pub.dev.
