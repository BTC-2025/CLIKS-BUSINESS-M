# BNX Mail — Manage Account Module (Frontend Export)

This folder contains a **standalone copy** of all frontend files needed to run the
Manage Account and Profile screens in another Flutter project.

---

## 📁 Folder Structure

```
manage_account_export/
│
├── screens/                         ← UI Screens
│   ├── manage_account_screen.dart   ← Full Manage Account screen (tabs: Home, Personal Info, Payment, Team, Storage, B2Auth, Connected Accounts)
│   └── profile_screen.dart          ← Profile screen (shown before Manage Account)
│
├── models/                          ← Data models (pure Dart, no API calls)
│   ├── account_model.dart           ← AccountModel with avatarColor, email, name, etc.
│   ├── two_factor_model.dart        ← TwoFactorSetupData (TOTP/QR setup)
│   ├── user_model.dart              ← UserModel (profile info from server)
│   ├── user_settings_model.dart     ← UserSettings (language, spell check, etc.)
│   ├── signature_model.dart         ← SignatureModel (email signature)
│   └── blocked_contact_model.dart   ← BlockedContact (unsubscribe list)
│
├── widgets/
│   └── avatar_widget.dart           ← Reusable avatar (letter avatar + image)
│
├── theme/
│   ├── colors.dart                  ← BNXColors (light/dark palette constants)
│   └── neumorphic.dart              ← NeumorphicDecoration helper
│
├── network/
│   └── api_exception.dart           ← ApiException class (typed HTTP error)
│
├── account_provider.dart            ← Riverpod AccountsNotifier + activeAccountProvider
├── settings_provider.dart           ← Riverpod SettingsNotifier (signatures, 2FA, language)
├── storage_repository.dart          ← StorageQuota model + API calls
├── subscription_repository.dart     ← SubscriptionRepository (blocked contacts)
├── user_repository.dart             ← UserRepository (profile fetch/update)
└── settings_repository.dart         ← SettingsRepository (settings fetch/save/2FA)
```

---

## 📦 Required Flutter Packages

Add these to your target project's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  file_picker: ^8.0.0
  http: ^1.2.0
```

---

## 🔌 Integration Steps

### 1. Copy files into your project

Place the files in your own `lib/` folder following the same structure:

```
lib/
  features/profile/presentation/manage_account_screen.dart
  features/profile/presentation/profile_screen.dart
  core/widgets/avatar_widget.dart
  core/theme/colors.dart
  core/theme/neumorphic.dart
  core/network/api_exception.dart
  models/account_model.dart
  models/two_factor_model.dart
  models/user_model.dart
  models/user_settings_model.dart
  models/signature_model.dart
  models/blocked_contact_model.dart
  data/account_provider.dart
  data/settings_provider.dart
  data/repositories/storage_repository.dart
  data/repositories/subscription_repository.dart
  data/repositories/user_repository.dart
  data/repositories/settings_repository.dart
```

### 2. Update imports

After placing the files, **find-and-replace** the import prefixes to match your
own project's package name. Example:

```
Find:    import '../../../core/widgets/avatar_widget.dart';
Replace: import 'package:YOUR_APP/core/widgets/avatar_widget.dart';
```

Or just keep the relative import style if you mirror the folder structure exactly.

### 3. Connect your API client

`storage_repository.dart`, `user_repository.dart`, and `settings_repository.dart`
all call `ApiClient.get(...)` / `ApiClient.post(...)`. You'll need to provide your
own `ApiClient` implementation or stub it with mock data for the UI to render.

To use **static/mock data only** (pure UI preview), you can stub every API call to
return an empty Map or hardcoded values:

```dart
// Example stub for ApiClient
class ApiClient {
  static Future<dynamic> get(String path, {Map<String, String>? queryParams, String? tempToken}) async => {};
  static Future<dynamic> post(String path, {dynamic body, Map<String, String>? queryParams}) async => {};
  static Future<dynamic> put(String path, {dynamic body}) async => {};
  static Future<dynamic> delete(String path) async => {};
}
```

### 4. Wrap your app in `ProviderScope`

```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 5. Navigate to the screens

```dart
// Profile screen (entry point)
Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));

// Or directly to Manage Account
Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAccountScreen()));

// With initial tab (0=Home, 1=Personal info, 2=Payment, 3=Team, 4=Storage, 5=B2Auth, 6=Connected)
Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAccountScreen(initialTab: 1)));
```

---

## ⚠️ Notes

- **No backend calls are hardcoded** — all API logic is isolated in the repository files.
- The `profile_screen.dart` uses `go_router`'s `context.push('/manage-account')` for navigation. Replace with your router's equivalent.
- `avatar_widget.dart` reads images from base64 data URIs, file paths, and network URLs — it's self-contained.
- Dark mode is controlled by `appUiProvider` (from `app_state_provider.dart` in the source project). You can replace this with your own `isDark` bool.
- This export is **frontend-only** — no WebSocket, no auth tokens, no email sending logic is included.

---

## 🎨 Manage Account Tabs

| Tab | Content |
|-----|---------|
| Home | Overview grid with all account sections |
| Personal info | Name, bio, gender, address, occupation |
| Payment & subscription | Business plan, billing info |
| Team & Sub-IDs | Sub-accounts and team members |
| Account storage | Storage quota bar chart |
| B2Auth | 2FA setup (TOTP / QR code) |
| Connected accounts | Linked email accounts |

