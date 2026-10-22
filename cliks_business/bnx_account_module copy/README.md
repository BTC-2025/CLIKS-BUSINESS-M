# 📦 BNX Mail — Complete Standalone Account System Module

A fully self-contained, end-to-end package containing all Frontend UI pages, State Notifiers, Data Models, API Repositories, Backend Server, and UI Design Specifications for the **BNX Account & Authentication Suite**.

This folder is completely decoupled from the main app project. It serves as an isolated reference and reusable module that can be tested, exported, or integrated into any client application without modifying or breaking existing workflows.

---

## 📁 Directory Structure & File Inventory

```
bnx_account_module/
│
├── README.md                                    # This documentation guide
│
├── docs/                                        # Comprehensive API & Architecture Specifications
│   ├── BNX_ACCOUNT_MOBILE_API_REFERENCE.md      # Mobile API guide (endpoints, payloads, responses)
│   ├── bnx_account_ui_api_reference.md          # Account dashboard & profile API reference
│   ├── ACCOUNT_FLOW_ARCHITECTURE.md            # Mermaid sequence diagrams, state machines, and lifecycles
│   └── openapi_account_spec.json               # OpenAPI 3.0 specification for all account endpoints
│
├── frontend/                                    # Flutter UI, Screens, Widgets & State Management
│   ├── pages/
│   │   ├── register_account_type_screen.dart   # Complete Registration Wizard (Myself, Child, Business, OTP, Password)
│   │   ├── login_screen.dart                   # Sign In screen with Multi-Account Switcher
│   │   ├── business_onboarding_screen.dart     # Post-Registration 2-Step Business Profile & Branding (Shown Once)
│   │   └── manage_account_screen.dart          # Account settings, 2FA, session devices & branch Sub-IDs
│   ├── widgets/
│   │   ├── auth_text_field.dart                # Styled text input with validation and clear button
│   │   ├── auth_button.dart                    # Primary action button with loading indicators
│   │   └── account_switcher.dart               # Multi-account picker & switcher sheet
│   ├── notifiers/
│   │   ├── auth_notifier.dart                  # Riverpod authentication state notifier
│   │   └── login_notifier.dart                 # Login credentials and validation state
│   ├── providers/
│   │   └── account_provider.dart               # Account switching, current user profile provider
│   ├── constants/
│   │   ├── auth_constants.dart                 # Validation regex patterns, character limits, copy
│   │   └── colors.dart                         # Brand theme color definitions
│   └── models/
│       ├── user_model.dart                     # User entity model with JSON serialization
│       ├── account_model.dart                  # Multi-account representation model
│       └── user_settings_model.dart            # User preferences and security configuration
│
├── api/                                         # Flutter Networking Layer & Repositories
│   ├── api_client.dart                         # Dio/HTTP client with interceptors & base URLs
│   ├── token_service.dart                      # Secure JWT storage and token refresh handler
│   ├── api_exception.dart                      # Error wrapper and status code parsing
│   ├── auth_repository.dart                    # Registration, OTP send/verify, Login calls
│   └── user_repository.dart                    # Profile, Avatar upload, Sub-IDs, Sessions
│
├── backend/                                     # Complete Standalone Node.js / Express API Server
│   ├── package.json                            # Backend dependencies (Express, CORS, JWT, Multer)
│   ├── server.js                               # Master Express server running on port 8080
│   └── routes/
│       ├── auth_routes.js                      # /auth/register, /auth/send-mobile-otp, /auth/verify-mobile-otp, /auth/login
│       ├── email_routes.js                     # /emails/create (Step 2), /emails/check-handle, /emails/suggestions
│       ├── user_routes.js                      # /api/users/me, /api/users/profile, /api/subid/create, /security/devices
│       └── business_routes.js                  # /business/onboarding, /business/status, /business/gstin-lookup
│
└── ui_designs/                                  # Visual Design System & Interactive Wireframes
    ├── interactive_preview.html                # Standalone interactive browser preview of all screens & OTP flows
    ├── design_specifications.md                # Typography, color tokens, OTP input UX rules & checklist
    └── assets/                                 # Brand assets (bnx_mail_logo.png, cliks_business_img.png, etc.)
```

---

## 🚀 How to Run the Backend Server

The included backend in `backend/` is a complete, working Express.js service that simulates the real BNX API.

### 1. Install Dependencies
```bash
cd bnx_account_module/backend
npm install
```

### 2. Start the Server
```bash
npm start
```

### 3. Server Details
- **Port:** `http://localhost:8080`
- **Base API:** `http://localhost:8080/api`
- **Health Check:** `http://localhost:8080/health`
- **Master Dev OTP:** `123456` (accepts `123456` for any phone number during testing)

---

## 🎨 Interactive UI Preview

You can preview and interact with all screens and OTP flows without running Flutter!
Simply open the interactive HTML preview in any modern browser:

```bash
open bnx_account_module/ui_designs/interactive_preview.html
```

Features in the interactive preview:
1. **Account Type Selection:** Select between Myself, Child, and Business.
2. **Myself Flow:** Personal details $\rightarrow$ Handle selection $\rightarrow$ Mobile OTP verification (with 60s live countdown & resend link) $\rightarrow$ Password checklist.
3. **Child Flow:** Child details $\rightarrow$ Parent email/phone $\rightarrow$ Parent consent OTP.
4. **Business Flow:** Sole proprietorship vs Organization, PAN, CIN, GSTIN.
5. **Business Onboarding Wizard:** First-time onboarding step 1 (profile) & step 2 (branding).
6. **Authentication & Multi-Account Switcher:** Login and profile switching.

---

## 🔑 Key Features Implemented

### 1. 2-Step Registration Flow
- **Step 1:** Call `/api/auth/register` $\rightarrow$ Validates username, password, and personal info $\rightarrow$ Returns `tempToken`.
- **Step 2:** Call `/api/emails/create` with `Authorization: Bearer <tempToken>` $\rightarrow$ Allocates mailbox and returns permanent access tokens.

### 2. Mobile OTP Verification
- Custom 6-digit numeric input with auto-advance and backspace handling.
- Integrated 60-second cooldown timer before the "Resend OTP" link becomes active.
- Master development test code: `123456`.

### 3. Personal Handle Rules
- Personal account handles strictly enforce the 10-character rule (7 letters + 3 digits, e.g. `sivakum123@bnxmail.com`).
- Real-time suggestions based on user first and last name.

### 4. Child Supervised Account
- For users under 18 years of age.
- Requests parent email or phone number.
- Dispatches a parent consent OTP (`/api/auth/child/send-parent-otp`) and validates consent (`/api/auth/child/verify-parent-otp`).

### 5. Business Account & First-Time Onboarding Gatekeeper
- Supports Sole Proprietorship and Organization registrations with GSTIN, CIN, and PAN validation.
- First-time login gatekeeper checks `/api/business/status`. If uncompleted, displays `BusinessOnboardingScreen` (Step 1 Company Details, Step 2 Branding/Logo). Once completed, it is marked complete and never shown again.

---

## 🛡️ Project Isolation Guarantee
All files in `bnx_account_module/` are standalone duplicates and isolated modules. The main application in `lib/` is completely unaffected and continues to run cleanly.
