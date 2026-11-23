# MediMatch Rwanda

A Flutter mobile app that helps people in Rwanda find verified pharmacies,
clinics and hospitals that accept their health insurance — with distance,
opening hours, stock information and an emergency SOS directory built in.

The project code lives in `pharma_finder`; the product name is **MediMatch**.

## Features

- **Onboarding & authentication** — email/password, phone OTP and Google
  sign-in via Firebase Auth, plus a guest browsing path.
- **Insurance selection** — choose from Rwandan schemes (RSSB/RAMA, Mutuelle
  de Santé/CBHI, MMI, Britam, Sanlam, Radiant, international, cash) during
  onboarding.
- **Facility discovery** — home feed of nearby providers and a search
  directory with cubit-driven filters: facility type, insurance accepted,
  open-now / 24-hour, distance radius and specific needs (prescription
  refill, over-the-counter, maternal care, emergency triage).
- **Live location** — permission flow, GPS position streaming and reverse
  geocoding; the last known position is cached locally and synced to
  `users/{uid}.location` so the UI renders instantly on the next launch.
- **Emergency SOS** — one-tap calling for national emergency numbers
  (police 112, fire 111, Isange GBV hotline 3512).
- **Profile & health passport** — account details, blood type, allergies and
  next of kin for first responders, stored per user in Firestore.
- **About screen** — content (version, tagline, support contacts, body copy)
  is read from the `app_config/about` Firestore document, so it can be updated
  without shipping a new build.

## Tech stack

| Area | Choice |
| --- | --- |
| Framework | Flutter 3.44+ / Dart 3.12+ (Material 3) |
| State management | `flutter_bloc` (Cubits) + `equatable` |
| Backend | Firebase Core, Firebase Auth, Cloud Firestore |
| Auth providers | Email/password, phone OTP, Google Sign-In |
| Location | `geolocator`, `geocoding` |
| Config | `flutter_dotenv` |
| Platform actions | `url_launcher` (`tel:`, `mailto:`, web links) |
| Linting | `flutter_lints` |

## Architecture

The app follows a feature-first layout with a light Clean Architecture split:

```
lib/
├── main.dart                     # Firebase bootstrap, session restore, app entry
├── core/
│   ├── firestore/                # FirestorePaths + UserRepository (typed reads/writes)
│   ├── location/                 # LocationStore (in-memory cache in front of Firestore)
│   ├── router/app_shell.dart     # Bottom-navigation shell
│   └── theme/                    # Colors and ThemeData
├── features/
│   ├── about/                    # Firestore-backed About page
│   ├── emergency/                # SOS directory
│   ├── facilities/               # entity → cubit → state → screens/widgets
│   ├── insurance/                # plan entity, cubit and onboarding screen
│   ├── location/                 # Live location screen
│   └── profile/                  # Profile, edit profile
├── screen/                       # Onboarding, login, signup
├── services/                     # Auth helpers (phone formatting, error copy), UserProfile
└── shell/main_shell.dart         # Alternate tab shell used by tests
```

Each feature follows the same pattern: **screen → Cubit → state → widgets**.
Screens render all three branches (loading, empty/error, loaded) and never use
`setState` for app state. Data access goes through `UserRepository` and
`FirestorePaths` so collection names live in one place.

> **Note:** facilities and insurance plans currently use sample data inside the
> cubits. The facilities Cubit is structured to be swapped for a Firestore
> repository in `features/facilities/data/` without touching the UI.

### Data model

The intended Firestore schema is documented in
[doc/pharma_finder.jpg](doc/pharma_finder.jpg) (ER diagram). The collections
in use today are:

- `users/{uid}` — profile, health passport, preferences, saved location.
- `app_config/about` — read-only app/about content.

Security rules ([firestore.rules](firestore.rules)) restrict every user to
their own document; `app_config` is readable by any signed-in user and
writable only by admins (Console/Admin SDK).

## Getting started

### Prerequisites

- Flutter SDK 3.44 or newer (`flutter --version`)
- Android Studio (Android SDK) and/or Xcode for iOS
- A Firebase project with **Authentication** (email, phone, Google) and
  **Cloud Firestore** enabled

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Fill in the Firebase values for each platform in `.env` (they come from the
Firebase console under *Project settings → Your apps*). `GOOGLE_WEB_CLIENT_ID`
is the Web OAuth client ID used as the Google Sign-In server client ID.

### 3. Add Firebase platform config

- Android: `android/app/google-services.json` (generated from your Firebase
  project; `firebase.json` already points at it).
- iOS/macOS/web/Windows: generated per-platform options live in
  [lib/firebase_options.dart](lib/firebase_options.dart); regenerate them with
  the FlutterFire CLI when the Firebase project changes.

Neither `google-services.json` nor `.env` is committed — never commit secrets.

### 4. Seed the About document

Follow [scripts/seed_about.md](scripts/seed_about.md) to create the
`app_config/about` document in the Firebase console.

### 5. Run the app

```bash
flutter run
```

Run on an Android emulator/device or iOS simulator. Do not use
`flutter run -d chrome` — this project targets mobile.

### Firestore rules

Deploy the security rules after changing them:

```bash
firebase deploy --only firestore:rules
```

## Tests and quality checks

```bash
flutter analyze   # must report "No issues found!"
flutter test      # unit + widget tests
dart format .
```

Tests cover auth helpers (phone normalisation/error copy), the facilities and
insurance cubits, location storage, the main shell tabs, the profile screen,
and the insurance screen.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). In short:

- Branch off `dev`; open PRs against `dev` (`feat/<name>/<what>`),
  `main` is protected.
- Use prefixed commit messages, e.g. `feat(auth): add Google sign-in`.
- Run `flutter analyze`, `flutter test` and `dart format .` before every PR.
- Never use `setState()` for state management, and never push directly to
  `main`.

