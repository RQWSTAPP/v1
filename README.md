# Rqwst Flutter

Flutter port of the Rqwst v19 PWA. Targets Android, iOS, and Web from a single codebase.

## Setup

### 1. Set your server URL

Open `lib/services/api.dart` and change:

```dart
static const _baseUrl = 'https://your-domain.com/server.php';
```

The backend is your existing `server.php` — no changes needed there.

### 2. Install Flutter

https://docs.flutter.dev/get-started/install

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run

```bash
# Android
flutter run

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

### 5. Push notifications (optional)

Add Firebase to the project:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then replace `firebase_messaging` stub with real init in `main()`.

---

## Project structure

```
lib/
  main.dart                  # App entry, shell, bottom nav, toast
  utils/
    theme.dart               # Light/dark themes, brand colors
    i18n.dart                # Full Arabic/English strings (port of L object)
  services/
    api.dart                 # HTTP layer (port of api() function)
    app_state.dart           # All app state + data fetching (port of reactive S)
  widgets/
    common.dart              # BrandButton, StatusPill, RqwstCard, ShimmerBox, EmptyState
  screens/
    home_screen.dart         # Home tab: billboard, CTA, how-it-works
    tasks_screen.dart        # Tasks tab: requester list + provider feed
    chat_screen.dart         # Chat list + chat detail
    wallet_screen.dart       # Wallet balance
    profile_screen.dart      # Profile, stats, provider toggle, vehicle, settings
    auth_sheet.dart          # Login / Register bottom sheet
    new_request_sheet.dart   # 3-step new request bottom sheet
```

## What's included

- ✅ Full RTL Arabic / LTR English (auto-switches, persisted)
- ✅ Dark / light theme (persisted)
- ✅ Auth: login, register, logout, session persistence
- ✅ Home: animated billboard, CTA button, how-it-works cards
- ✅ Tasks: requester view (my requests) + provider view (feed + accept/offer)
- ✅ Provider mode toggle + availability toggle
- ✅ Chat list with thread tiles + full chat detail with polling
- ✅ Wallet screen with balance/earned display
- ✅ Profile: avatar, stats grid, provider toggle, identity verification UI, vehicle form, settings
- ✅ New request: 3-step form (description → type+area → price)
- ✅ Toast notifications
- ✅ Shimmer loading placeholders

## What to add next

- Push notifications via `firebase_messaging`
- Voice notes via `record` + `audioplayers` packages
- WebRTC calls via `flutter_webrtc`
- Google Maps via `google_maps_flutter`
- Geolocation via `geolocator`
- Image picker (avatar, vehicle photos) via `image_picker`
- File picker (ID documents) via `file_picker`
