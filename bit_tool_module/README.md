# Bit Tool Standalone Module (`bit_tool_module`)

A completely self-contained, modular Flutter package providing the **Bit Tool Right Utility Rail**, full slide-out panels, and all 8 backend API modules.

This module is packaged as an independent folder at `/Users/btrldev004/Desktop/CLIKS-BUSINESS-M/bit_tool_module` without disturbing the main `cliks_business` host project.

---

## 🚀 Key Features

1. **Self-Contained Right Utility Rail**:
   - Modern vertical floating rail on the right side of the screen.
   - 6 Core Bit Tool utilities: **Beta Apps**, **Calculator**, **Calendar**, **Notes**, **Contacts**, **Weather**, plus quick actions & keyboard shortcuts.
   - Smooth slide-out drawer matching the design specifications.

2. **Clean Modals (Zero cramped mini tabs)**:
   - "New Contact" and "New Note" / "Edit Note" use clean, centered modal dialogs (`showDialog`).
   - The old cramped in-panel overlays have been completely removed.

3. **Complete End-to-End API Integration (8 Modules)**:
   - **Contacts API**: Multi-account contacts list, search, pagination, creation, updating, and deletion.
   - **Calculator API**: Full tape calculator, formula execution, tape archiving, and session persistence to backend.
   - **Calendar API**: Monthly event synchronization, day view, agenda, and reminder completion toggling.
   - **Notes API**: CRUD operations, color tagging, pinned notes, and full markdown-compatible content.
   - **Weather API**: Open-Meteo multi-city weather forecasts with fallback mechanisms.
   - **Notifications API**: Central notification polling and unread counter badges.
   - **Currency API**: Exchange rates conversion.
   - **User Profile API**: Account metadata retrieval.

---

## 📁 Directory Structure

```
bit_tool_module/
├── lib/
│   ├── bit_tool_module.dart              # Main library export barrel
│   └── src/
│       ├── api/                          # Standalone API Client & Modules
│       │   ├── client/                   # Http client with bearer token injection
│       │   ├── config/                   # API base URLs and endpoint descriptors
│       │   ├── facade/                   # Central BitToolApiModule unified facade
│       │   └── modules/                  # 8 modular service implementations
│       │       ├── calculator/
│       │       ├── calendar/
│       │       ├── contacts/
│       │       ├── currency/
│       │       ├── notes/
│       │       ├── notifications/
│       │       ├── user_profile/
│       │       └── weather/
│       ├── providers/                    # Riverpod state notifiers & providers
│       │   └── bit_tool_providers.dart   # Central reactive state management
│       └── ui/                           # Flutter UI Components
│           ├── bit_tool_right_utility_rail.dart # The right utility bar & drawer
│           └── calculator/
│               └── bit_tool_calculator.dart     # Standalone Beta Calculator
├── assets/
│   └── images/beta_logo.png
├── pubspec.yaml
└── README.md
```

---

## 💻 Integration Guide

### 1. Add as a Path Dependency
In your host project's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  lucide_icons_flutter: ^3.1.14+2
  bit_tool_module:
    path: ../bit_tool_module
```

### 2. Provide Auth Token & Active Account
The Bit Tool module is completely decoupled from any single host auth system. Simply inject your host application's active session token and active account into the providers:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bit_tool_module/bit_tool_module.dart';

// In your app initialization or root provider setup:
void setupBitToolAuth(WidgetRef ref) {
  // 1. Supply the token retrieval callback
  ref.read(bitToolTokenProvider.notifier).state = () async {
    return await myAuthService.getAccessToken();
  };

  // 2. Keep the active account in sync
  ref.read(bitToolActiveAccountProvider.notifier).state = BitToolHostAccount(
    id: currentAccount.id,
    email: currentAccount.email,
    name: currentAccount.displayName,
  );
}
```

### 3. Mount the Utility Rail in your Layout
Place `BitToolRightUtilityRail` inside a `Stack` at the top right of your app's main scaffolding:

```dart
import 'package:bit_tool_module/bit_tool_module.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main workspace / Dashboard content
          MainDashboardContent(),

          // Bit Tool right utility rail
          const Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: BitToolRightUtilityRail(),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Verification & Static Analysis

To run static analysis on the module:
```bash
cd bit_tool_module
flutter analyze
```
Result: **`No issues found!`**
