# BNX Account Flow & Architecture Specification

This document provides complete sequence diagrams, state machines, and lifecycle specifications for all Account operations in the BNX Mail ecosystem.

---

## 1. 2-Step Registration Architecture (Personal / Myself)

```mermaid
sequenceDiagram
    autonumber
    actor User as Mobile App / Frontend
    participant AuthScreen as RegisterAccountTypeScreen
    participant AuthRepo as AuthRepository
    participant Backend as BNX Account Backend
    participant SMS as SMS OTP Gateway

    User->>AuthScreen: Select "For Myself"
    User->>AuthScreen: Enter Name (First/Last), DOB, Gender
    User->>AuthScreen: Choose Handle (e.g., sivakum123)
    User->>AuthScreen: Enter Mobile Number (+91 9876543210)
    
    AuthScreen->>AuthRepo: sendMobileOtp(phoneNumber, '+91')
    AuthRepo->>Backend: POST /api/auth/send-mobile-otp
    Backend->>SMS: Dispatch 6-digit OTP
    Backend-->>AuthRepo: { success: true, cooldown: 60s }
    AuthRepo-->>AuthScreen: Start 60s countdown timer

    User->>AuthScreen: Enters 6-digit OTP (e.g., 123456)
    AuthScreen->>AuthRepo: verifyMobileOtp(phoneNumber, '+91', '123456')
    AuthRepo->>Backend: POST /api/auth/verify-mobile-otp
    Backend-->>AuthRepo: { verified: true, verificationToken: '...' }
    AuthRepo-->>AuthScreen: Phone Verified Checked ✓

    User->>AuthScreen: Enter & Confirm Password
    User->>AuthScreen: Tap "Create Account"

    Note over AuthScreen,Backend: STEP 1: Register User Credentials
    AuthScreen->>AuthRepo: register(username, password, mode='PERSONAL', ...)
    AuthRepo->>Backend: POST /api/auth/register
    Backend-->>AuthRepo: { success: true, data: { userId, username, tempToken } }
    
    Note over AuthScreen,Backend: STEP 2: Provision Mailbox with tempToken
    AuthScreen->>AuthRepo: createMailbox(emailName, password, tempToken)
    AuthRepo->>Backend: POST /api/emails/create (Authorization: Bearer <tempToken>)
    Backend-->>AuthRepo: { success: true, data: { accessToken, refreshToken, user } }

    AuthRepo-->>AuthScreen: Save tokens to secure storage & enter Dashboard
```

---

## 2. Child Account Parent Consent OTP Flow

```mermaid
sequenceDiagram
    autonumber
    actor ChildUser as Minor User / Parent
    participant Screen as RegisterAccountTypeScreen (Child)
    participant Backend as BNX Account Backend

    ChildUser->>Screen: Enter Child Name & DOB (< 18 yrs)
    ChildUser->>Screen: Enter Parent Mobile Number or Email
    Screen->>Backend: POST /api/auth/child/send-parent-otp
    Backend-->>Screen: { success: true, message: "Consent OTP sent to parent" }

    ChildUser->>Screen: Enters 6-digit Parent OTP
    Screen->>Backend: POST /api/auth/child/verify-parent-otp
    alt Valid OTP
        Backend-->>Screen: { verified: true, parentConsentToken: "..." }
        Screen->>Screen: Enable Handle & Password creation
    else Invalid OTP
        Backend-->>Screen: { success: false, message: "Invalid code" }
        Screen->>ChildUser: Display error message
    end
```

---

## 3. Business Account & First-Time Onboarding Gatekeeper

```mermaid
sequenceDiagram
    autonumber
    actor BizUser as Business Admin
    participant Screen as Business Flow & Dashboard
    participant Backend as BNX Account Backend

    BizUser->>Screen: Register Business Account (Sole Proprietorship or Organization)
    Screen->>Backend: POST /api/auth/register & POST /api/emails/create
    Backend-->>Screen: Business Account Created (tokens issued)

    Note over Screen,Backend: Onboarding Gatekeeper Check
    Screen->>Backend: GET /api/business/status?username=biz_user
    Backend-->>Screen: { isCompleted: false, shouldShowOnboarding: true }

    Screen->>BizUser: Present Business Onboarding Modal (Step 1 & 2)
    BizUser->>Screen: Fill Org Info, Support Email, Brand Color, Logo
    BizUser->>Screen: Tap "Submit Business Profile"
    Screen->>Backend: POST /api/business/onboarding
    Backend-->>Screen: { success: true, status: "COMPLETED" }

    Note over Screen,Backend: Subsequent Logins / Visits
    Screen->>Backend: GET /api/business/status?username=biz_user
    Backend-->>Screen: { isCompleted: true, shouldShowOnboarding: false }
    Screen->>BizUser: Direct Access to Business Dashboard (Modal NEVER shown again)
```

---

## 4. Multi-Step Registration Wizard State Machine

```mermaid
stateDiagram-v2
    [*] --> AccountTypeSelection: User opens registration
    
    AccountTypeSelection --> Myself_Details: Selected "Myself"
    AccountTypeSelection --> Child_Details: Selected "Child"
    AccountTypeSelection --> Business_Details: Selected "Business"

    state "Myself Flow" as MyselfFlow {
        Myself_Details --> Myself_Handle: Name & DOB valid
        Myself_Handle --> Myself_Mobile: 10-char handle chosen
        Myself_Mobile --> Myself_OTP: Mobile entered & OTP sent
        Myself_OTP --> Myself_Password: OTP verified (6 digits)
        Myself_Password --> Myself_Registering: Password validated
        Myself_Registering --> Provision_Mailbox: Step 1 success (tempToken)
        Provision_Mailbox --> Registered_Done: Step 2 success (accessToken)
    }

    state "Child Flow" as ChildFlow {
        Child_Details --> Child_ParentContact: Child DOB < 18
        Child_ParentContact --> Child_ParentOTP: Parent mobile/email provided
        Child_ParentOTP --> Child_Handle: Consent verified
        Child_Handle --> Child_Password: Child handle selected
        Child_Password --> Child_Done: Parent linked account created
    }

    state "Business Flow" as BizFlow {
        Business_Details --> Business_Compliance: Choose Sole or Org
        Business_Compliance --> Business_AdminHandle: CIN/PAN/GSTIN provided
        Business_AdminHandle --> Business_Password: Admin credentials set
        Business_Password --> Business_AccountCreated: Account created
        Business_AccountCreated --> Business_Onboarding_Step1: Check status -> Uncompleted
        Business_Onboarding_Step1 --> Business_Onboarding_Step2: Org info saved
        Business_Onboarding_Step2 --> Business_Done: Branding saved & marked complete
    }

    Registered_Done --> [*]
    Child_Done --> [*]
    Business_Done --> [*]
```
