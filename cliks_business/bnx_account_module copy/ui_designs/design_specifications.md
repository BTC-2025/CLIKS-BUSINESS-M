# BNX Account System — UI/UX Design Specifications

Comprehensive design specification for the BNX Account Generation, Registration, OTP, Authentication, and Onboarding experience across Mobile (iOS/Android) and Desktop/Web.

---

## 1. Visual Design Tokens

### 1.1 Color Palette
| Token Name | Hex Value | Usage |
| :--- | :--- | :--- |
| `--bnx-bg-primary` | `#0F172A` / `#121212` | Main page background (Dark Mode) |
| `--bnx-surface` | `#1E293B` / `#1E1E1E` | Card containers, modal sheets, panels |
| `--bnx-surface-light` | `#334155` / `#2D2D2D` | Input fill, elevated tiles, borders |
| `--bnx-primary` | `#3B82F6` | Primary CTAs, active step highlights |
| `--bnx-primary-hover` | `#2563EB` | Button hover and pressed states |
| `--bnx-accent` | `#6366F1` / `#8B5CF6` | Secondary accents, handles, gradient buttons |
| `--bnx-text-primary` | `#F8FAFC` | Headings, primary input text, button labels |
| `--bnx-text-secondary` | `#94A3B8` | Subtitles, labels, placeholders, timestamps |
| `--bnx-text-muted` | `#64748B` | Helper captions, disabled items |
| `--bnx-success` | `#10B981` | OTP verified badge, strong password state |
| `--bnx-error` | `#EF4444` | Form validation errors, invalid OTP badge |
| `--bnx-warning` | `#F59E0B` | Expiry countdown warnings, weak password |

### 1.2 Typography
- **Heading Font:** Outfit, Inter, or SF Pro Display (San Francisco / Roboto fallback).
- **Scale:**
  - Screen Titles: `24px` / `32px` line-height, Bold (`700`)
  - Section Headers: `18px` / `24px` line-height, Semi-Bold (`600`)
  - Body Text: `14px` / `20px` line-height, Regular (`400`)
  - Input Labels: `13px` / `16px` line-height, Medium (`500`)
  - Handle Badges: `14px` / Monospace (`Roboto Mono` / `Courier`), Semi-Bold (`600`)
  - Micro-copy / Errors: `12px` / `16px` line-height, Regular (`400`)

### 1.3 Radii & Elevation
- Input Fields: `10px` rounded corners
- Action Buttons: `12px` rounded corners
- Cards & Dialogs: `16px` rounded corners
- Elevation / Shadow: `0 8px 30px rgba(0, 0, 0, 0.4)` for floating sheets and dialogs

---

## 2. Screen-by-Screen UI & Interaction Workflow

```
[ START: Account Type Selection ]
         │
         ├───► A. "For Myself" (Personal)
         │       │
         │       ├── 1. Personal Details (Name, DOB, Gender)
         │       ├── 2. Handle Selection (@bnxmail.com, 7 letters + 3 digits)
         │       ├── 3. Mobile Verification (Phone + Country Code)
         │       ├── 4. Mobile OTP Screen (6-digit boxes, 60s timer)
         │       └── 5. Password Creation (Checklist validation)
         │               │
         │               └──► Provision Mailbox & Enter Dashboard
         │
         ├───► B. "For My Child" (Parent Supervised)
         │       │
         │       ├── 1. Child Details (Name, DOB)
         │       ├── 2. Parent Contact (Parent Email / Mobile)
         │       ├── 3. Parent Consent OTP Screen
         │       ├── 4. Child Handle Selection
         │       └── 5. Child Password Creation
         │               │
         │               └──► Mailbox Provisioned with Parent Link
         │
         └───► C. "For My Business" (Enterprise / Org)
                 │
                 ├── 1. Business Category (Sole Proprietorship vs Organization)
                 ├── 2. Compliance IDs (PAN, CIN, GSTIN lookup)
                 ├── 3. Business Handle & Admin Credentials
                 ├── 4. Mobile OTP Verification
                 │       │
                 │       └──► Account Created
                 │               │
                 └── 5. First-Time Business Onboarding (Appears ONCE)
                         ├── Step 1: Legal Name, Industry, Size, Support Contacts
                         └── Step 2: Brand Color, Tagline, Logo Upload
                                 │
                                 └──► Enter Business Workspace
```

---

## 3. Detailed UI Component Behaviors

### 3.1 Account Type Cards
- Radio-style selectable container cards:
  - **Myself:** Icon `person_outline`, "Full access personal communication with secure encryption".
  - **Child:** Icon `family_restroom`, "Parental controls and safe communication for minors under 18".
  - **Business:** Icon `business`, "Professional email domain with GSTIN, branch IDs and workspace".
- Selected state has active primary border (`2px solid #3B82F6`) and glow.

### 3.2 Mobile OTP Screen Specifications
- **Layout:**
  - Subtitle: *"Enter the 6-digit code sent to +91 98765 43210"*
  - 6 individual text boxes (`width: 48px`, `height: 56px`), centered with `8px` gap.
  - Text: `24px` bold, centered.
  - Keyboard: `TextInputType.number`.
- **Keyboard & Input Handling:**
  - Auto-focuses to box 1 on page load.
  - Typing a digit automatically shifts focus to the next box.
  - Backspace shifts focus to the previous box and clears the digit.
  - Pasting a 6-digit number automatically distributes into the 6 boxes.
- **Timer & Resend:**
  - Countdown: 60 seconds (`"Resend code in 0:45"`).
  - When timer reaches 0, the text transforms to a clickable blue link: *"Resend OTP"*.
  - Clicking "Resend OTP" calls the backend API and restarts the 60s countdown.

### 3.3 Handle Selection UX Rules
- Personal handle requirement: Exactly 10 characters (7 letters + 3 numbers).
- Suffix pill permanently visible: `@bnxmail.com`.
- Suggestion chips: 3 pills below input showing available generated handles. Clicking any pill auto-fills the handle.

### 3.4 Password Strength Meter & Checklist
- Real-time live validation showing 5 criteria with checkmarks:
  - [x] At least 8 characters
  - [x] At least one uppercase letter (A-Z)
  - [x] At least one lowercase letter (a-z)
  - [x] At least one number (0-9)
  - [x] At least one special symbol (!@#$%^&*)
- Retype password match status indicator.

### 3.5 Business Onboarding Dialog (First-Time Only)
- Triggered immediately after business account creation or first login.
- Two-step wizard:
  - **Step 1:** Company profile (Legal name, GSTIN, Company size, Support email).
  - **Step 2:** Branding (Brand accent color selector, Company tagline, Logo image upload dropzone).
- Persistent state saved to backend (`/api/business/onboarding`) so it is never displayed twice.

---

## 4. Multi-Account Switcher & Login UI
- Top-right avatar dropdown opens the active account switcher.
- Shows current active account with checkmark.
- Lists secondary / linked accounts (Personal, Business, Child).
- "+ Add another account" button smoothly navigates to the Account Selection Screen.
- "Manage your BNX Account" opens `manage_account_screen.dart`.
