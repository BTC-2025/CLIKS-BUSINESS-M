<!-- markdownlint-disable MD013 -->

# Cliks Mobile App API Documentation: Payments Module

> **Base URL:** `https://<YOUR_API_DOMAIN>/api/v1`  
> **Content-Type:** `application/json`  
> **Authentication:** Bearer JWT in the `Authorization` header for all requests:  
> `Authorization: Bearer <ACCESS_TOKEN>`

---

## Table of Contents

1. [Authentication & Headers](#1-authentication--headers)
2. [Core Business Payments (`/payments`)](#2-core-business-payments-payments)
   - [2.1 Receive Payment (Customer Receipts)](#21-receive-payment-customer-receipts)
   - [2.2 Pay Supplier (Outgoing Payment)](#22-pay-supplier-outgoing-payment)
   - [2.3 Internal Vault / Account Transfer](#23-internal-vault--account-transfer)
   - [2.4 Get Unified Payment Reports & Ledgers](#24-get-unified-payment-reports--ledgers)
   - [2.5 Get Outstanding Aggregated Stats](#25-get-outstanding-aggregated-stats)
   - [2.6 Create Online Payment Gateway Order (Cashfree / UPI)](#26-create-online-payment-gateway-order-cashfree--upi)
3. [Invoice Direct Payments (`/billing`)](#3-invoice-direct-payments-billing)
   - [3.1 Record Payment for Invoice](#31-record-payment-for-invoice)
   - [3.2 Get All Payments for an Invoice](#32-get-all-payments-for-an-invoice)
4. [Supplier Purchase Bill Payments (`/purchases`)](#4-supplier-purchase-bill-payments-purchases)
   - [4.1 Record Payment for Purchase Bill](#41-record-payment-for-purchase-bill)
   - [4.2 Get Payments for Purchase Bill](#42-get-payments-for-purchase-bill)
5. [Planned & Scheduled Payments (`/planned-payments`)](#5-planned--scheduled-payments-planned-payments)
   - [5.1 List Planned Payments](#51-list-planned-payments)
   - [5.2 Create Planned Payment](#52-create-planned-payment)
   - [5.3 Update Planned Payment](#53-update-planned-payment)
   - [5.4 Mark Planned Payment as Paid](#54-mark-planned-payment-as-paid)
   - [5.5 Delete Planned Payment](#55-delete-planned-payment)
6. [Payment Accounts & Bank Wallets (`/bank-accounts`)](#6-payment-accounts--bank-wallets-bank-accounts)
   - [6.1 List Bank Accounts & Balances](#61-list-bank-accounts--balances)
   - [6.2 Add New Bank Account](#62-add-new-bank-account)
7. [Endpoints Quick Reference & Summary](#7-endpoints-quick-reference--summary)
   - [7.1 Complete Endpoints Summary Table](#71-complete-endpoints-summary-table)
   - [7.2 Endpoints Grouped by Feature](#72-endpoints-grouped-by-feature)

---

## 1. Authentication & Headers

Every payment request must include the JWT token received from `/api/v1/auth/login`.

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

Standard API Response Envelope:

```json
{
  "success": true,
  "data": { ... },
  "message": "Status description string"
}
```

Error Response Envelope (HTTP 4xx / 5xx):

```json
{
  "success": false,
  "message": "Specific error message here",
  "error": "BAD_REQUEST | NOT_FOUND | INTERNAL_ERROR"
}
```

---

## 2. Core Business Payments (`/payments`)

### 2.1 Receive Payment (Customer Receipts)

Records an incoming customer payment, reconciles against an invoice (if linked), updates customer outstanding, adds funds to the selected bank/cash account, and logs the income in the accounting ledger.

- **Method:** `POST`
- **Endpoint:** `/api/v1/payments/receive`  
  *(Alternative alias: `/api/v1/payments/customer-receipts`)*

#### 2.1 Request Body

```json
{
  "amount": 5000.00,
  "customer_name": "Ramesh Traders",
  "invoice_id": "INV-2026-0042",
  "payment_mode": "UPI",
  "reference_number": "UPI/9876543210/PAY",
  "account_id": 1,
  "notes": "Payment received via PhonePe QR code",
  "total_original_amount": 5000.00,
  "paid_amount": 5000.00
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `amount` | Number | **Yes** | Paid amount (must be > 0) |
| `customer_name` | String | Optional | Customer / Client name (default: "General Customer") |
| `invoice_id` | String/Number | Optional | Invoice Number (e.g. `INV-001`) or Database ID |
| `payment_mode` | String | Optional | `Cash`, `UPI`, `Bank Transfer`, `Cheque`, `Card` |
| `reference_number` | String | Optional | Transaction ID, Cheque number, UTR |
| `account_id` | Number | Optional | ID of the receiving Bank / Cash Account |
| `notes` | String | Optional | Notes or memo |
| `total_original_amount` | Number | Optional | Original bill total if partial |

#### 2.1 Response (`201 Created`)

```json
{
  "success": true,
  "data": {
    "id": 108,
    "amount": 5000,
    "paidAmount": 5000,
    "paid_amount": 5000,
    "totalOriginalAmount": 5000,
    "total_original": 5000,
    "customerProfile": "Ramesh Traders",
    "customer_name": "Ramesh Traders",
    "invoiceLinkedId": "INV-2026-0042",
    "invoice_id": "INV-2026-0042"
  },
  "message": "Payment received successfully"
}
```

---

### 2.2 Pay Supplier (Outgoing Payment)

Records an outgoing payment to a vendor/supplier, deducts balance from the specified bank/cash account, settles the credit purchase bill, and updates supplier balance.

- **Method:** `POST`
- **Endpoint:** `/api/v1/payments/pay`

#### 2.2 Request Body

```json
{
  "amount": 12500.00,
  "supplier_name": "Metro Steel Supplies",
  "purchase_id": "PUR-2026-015",
  "payment_mode": "Bank Transfer",
  "reference_number": "NEFT-HDFC-991283",
  "account_id": 2,
  "notes": "Advance for raw materials shipment"
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `amount` | Number | **Yes** | Amount to pay (must be > 0) |
| `supplier_name` | String | Optional | Name of the supplier/vendor |
| `purchase_id` | String/Number | Optional | Purchase bill number or purchase ID |
| `payment_mode` | String | Optional | `Bank Transfer`, `Cash`, `Cheque`, `UPI` |
| `reference_number` | String | Optional | UTR / NEFT reference number |
| `account_id` | Number | Optional | ID of the paying Bank / Cash Account |
| `notes` | String | Optional | Remarks / memo |

#### 2.2 Response (`201 Created`)

```json
{
  "success": true,
  "data": {
    "id": 84,
    "amount": 12500
  },
  "message": "Payment to supplier recorded successfully"
}
```

---

### 2.3 Internal Vault / Account Transfer

Transfers money internally between accounts (e.g. Bank to Cash Register, or HDFC to ICICI).

- **Method:** `POST`
- **Endpoint:** `/api/v1/payments/transfer`

#### 2.3 Request Body

```json
{
  "from_acc_id": 1,
  "to_acc_id": 2,
  "amount": 10000.00
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `from_acc_id` | Number/String | **Yes** | Source account ID |
| `to_acc_id` | Number/String | **Yes** | Destination account ID |
| `amount` | Number | **Yes** | Transfer amount (must be > 0 and <= available balance) |

#### 2.3 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "from_account": "HDFC Current Account",
    "to_account": "Cash Register",
    "amount": 10000
  },
  "message": "Internal fund transfer settled successfully"
}
```

---

### 2.4 Get Unified Payment Reports & Ledgers

Returns customer receivables, vendor payables, all connected bank/cash balances, and overdue invoices in a single call.

- **Method:** `GET`
- **Endpoint:** `/api/v1/payments/reports`

#### 2.4 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "receivables": [
      {
        "id": 1,
        "type": "receive",
        "party_name": "Ramesh Traders",
        "amount": 5000,
        "paid_amount": 5000,
        "total_original": 10000,
        "pending_amount": 5000,
        "payment_mode": "UPI",
        "reference_number": "UPI/9876543210/PAY",
        "status": "completed",
        "reconciliation_status": "matched",
        "created_at": "2026-10-27T10:30:00.000Z"
      }
    ],
    "payables": [
      {
        "id": 2,
        "type": "pay",
        "party_name": "Metro Steel Supplies",
        "amount": 12500,
        "paid_amount": 12500,
        "total_original": 12500,
        "pending_amount": 0,
        "payment_mode": "Bank Transfer",
        "reference_number": "NEFT-HDFC-991283",
        "status": "completed",
        "reconciliation_status": "matched",
        "created_at": "2026-10-27T11:15:00.000Z"
      }
    ],
    "accounts": [
      {
        "id": 1,
        "bank_account_id": 1,
        "bank_name": "HDFC Bank",
        "bank_account_name": "HDFC Current Account",
        "account_number": "50200012345678",
        "ifsc_code": "HDFC0001234",
        "branch_name": "Indiranagar",
        "current_balance": 184500.00,
        "type": "bank",
        "status": "Active"
      },
      {
        "id": "cash-register",
        "bank_account_id": "cash-register",
        "bank_name": "Cash Register",
        "bank_account_name": "Cash Register (Cash in Hand)",
        "account_number": "Cash Counter",
        "current_balance": 32000.00,
        "type": "cash",
        "status": "Active"
      }
    ],
    "overdueInvoices": [
      {
        "id": 14,
        "invoice_number": "INV-2026-0014",
        "client_name": "Shree Enterprises",
        "client_email": "shree@example.com",
        "total_amount": 25000,
        "paid_amount": 10000,
        "due_amount": 15000,
        "due_date": "2026-10-20",
        "status": "Partially Paid"
      }
    ]
  },
  "message": "Payment reports fetched successfully"
}
```

---

### 2.5 Get Outstanding Aggregated Stats

Returns high-level totals of processed receivables and payables.

- **Method:** `GET`
- **Endpoint:** `/api/v1/payments/outstanding`

#### 2.5 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "receivables": 0,
    "payables": 0,
    "total_processed": 145000
  },
  "message": "Outstanding aggregated"
}
```

---

### 2.6 Create Online Payment Gateway Order (Cashfree / UPI)

Initiates a secure payment gateway session for mobile SDK checkout (Cashfree UPI / Cards / NetBanking).

- **Method:** `POST` *(or `GET` with query params)*
- **Endpoint:** `/api/v1/payments/create-order`

#### 2.6 Request Body

```json
{
  "amount": 1499.00,
  "orderId": "ORDER_MOBILE_10293",
  "currency": "INR"
}
```

#### 2.6 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "cf_order_id": "1840291",
    "order_id": "ORDER_MOBILE_10293",
    "entity": "order",
    "order_currency": "INR",
    "order_amount": 1499,
    "payment_session_id": "session_6pQW1l089_sample_token...",
    "order_status": "ACTIVE",
    "mode": "production",
    "cf_environment": "production"
  },
  "message": "Payment provider session established securely"
}
```

> **Mobile Developer Note:** Pass the returned `payment_session_id` directly to the Cashfree Android / iOS / React Native SDK to launch the payment screen.

---

## 3. Invoice Direct Payments (`/billing`)

### 3.1 Record Payment for Invoice

Applies a payment directly to a specific customer invoice, updates due balance, and changes invoice status to `Paid` or `Partially Paid`.

- **Method:** `POST`
- **Endpoint:** `/api/v1/billing/:id/payments`  
  *(Alternative alias: `/api/v1/invoices/:id/payments`)*  
  *(Where `:id` can be invoice integer ID or invoice number string)*

#### 3.1 Request Body

```json
{
  "amount": 3500.00,
  "payment_method": "UPI",
  "reference_number": "UPI/39201928374",
  "notes": "Part payment via QR scan"
}
```

#### 3.1 Response (`200 OK`)

```json
{
  "success": true,
  "data": null,
  "message": "Payment captured successfully"
}
```

---

### 3.2 Get All Payments for an Invoice

- **Method:** `GET`
- **Endpoint:** `/api/v1/billing/:id/payments`

#### 3.2 Response (`200 OK`)

```json
{
  "success": true,
  "data": [
    {
      "id": 12,
      "invoice_id": 14,
      "amount": 3500.00,
      "payment_method": "UPI",
      "payment_date": "2026-10-27T11:00:00.000Z",
      "reference_number": "UPI/39201928374",
      "notes": "Part payment via QR scan"
    }
  ],
  "message": "Payments loaded"
}
```

---

## 4. Supplier Purchase Bill Payments (`/purchases`)

### 4.1 Record Payment for Purchase Bill

Applies an outgoing payment directly to a supplier purchase bill.

- **Method:** `POST`
- **Endpoint:** `/api/v1/purchases/:id/payments`

#### 4.1 Request Body

```json
{
  "paid_amount": 8000.00,
  "payment_mode": "Bank Transfer"
}
```

#### 4.1 Response (`200 OK`)

```json
{
  "success": true,
  "data": null,
  "message": "Payment processed successfully"
}
```

---

### 4.2 Get Payments for Purchase Bill

- **Method:** `GET`
- **Endpoint:** `/api/v1/purchases/:id/payments`

#### 4.2 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "paid_amount": 8000.00,
    "payment_mode": "Bank Transfer",
    "payment_status": "partial"
  },
  "message": "Payments loaded successfully"
}
```

---

## 5. Planned & Scheduled Payments (`/planned-payments`)

Used for recurring bills, upcoming commitments, subscriptions, and scheduled loan/vendor installments.

### 5.1 List Planned Payments

- **Method:** `GET`
- **Endpoint:** `/api/v1/planned-payments`
- **Query Parameters:**
  - `status`: `pending` | `paid`
  - `category`: string (e.g. `Utilities`, `Rent`, `Salary`)
  - `search`: search by payment title or contact name
  - `type`: `bill` | `expense` | `loan`
  - `page`: default `1`
  - `limit`: default `20`
  - `sort`: `due_date` | `amount` | `created_at`
  - `order`: `asc` | `desc`

#### 5.1 Response (`200 OK`)

```json
{
  "success": true,
  "data": [
    {
      "id": 18,
      "user_id": 1,
      "account_id": 1,
      "name": "Commercial Office Rent",
      "description": "November rent for 3rd floor office",
      "amount": 45000.00,
      "due_date": "2026-11-01",
      "frequency": "monthly",
      "category": "Rent",
      "status": "pending",
      "type": "bill",
      "person_id": null,
      "person_name": null,
      "created_at": "2026-10-27T09:00:00.000Z",
      "updated_at": "2026-10-27T09:00:00.000Z"
    }
  ],
  "meta": {
    "total": 1,
    "page": 1,
    "limit": 20
  }
}
```

---

### 5.2 Create Planned Payment

- **Method:** `POST`
- **Endpoint:** `/api/v1/planned-payments`

#### 5.2 Request Body

```json
{
  "name": "Internet Leased Line Bill",
  "amount": 4200.00,
  "due_date": "2026-11-10",
  "account_id": 1,
  "frequency": "monthly",
  "category": "Utilities",
  "type": "bill",
  "description": "Airtel fiber static IP line"
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `name` | String | **Yes** | Bill title / commitment name |
| `amount` | Number | **Yes** | Amount to be paid (> 0) |
| `due_date` | String | **Yes** | Due date (`YYYY-MM-DD`) |
| `account_id` | Number | Optional | Default paying account |
| `frequency` | String | Optional | `monthly`, `weekly`, `quarterly`, `yearly`, `one-time` |
| `category` | String | Optional | Category label |
| `type` | String | Optional | `bill`, `expense`, `subscription`, `loan` |
| `description` | String | Optional | Detailed note |

#### 5.2 Response (`201 Created`)

```json
{
  "success": true,
  "data": {
    "id": 19,
    "user_id": 1,
    "account_id": 1,
    "name": "Internet Leased Line Bill",
    "amount": 4200,
    "due_date": "2026-11-10",
    "status": "pending",
    "frequency": "monthly",
    "category": "Utilities",
    "type": "bill",
    "created_at": "2026-10-27T13:45:00.000Z",
    "updated_at": "2026-10-27T13:45:00.000Z"
  },
  "message": "Planned payment created"
}
```

---

### 5.3 Update Planned Payment

- **Method:** `PATCH`
- **Endpoint:** `/api/v1/planned-payments/:id`

#### 5.3 Request Body

```json
{
  "amount": 4500.00,
  "due_date": "2026-11-12"
}
```

#### 5.3 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "id": 19,
    "amount": 4500,
    "due_date": "2026-11-12"
  },
  "message": "Planned payment updated"
}
```

---

### 5.4 Mark Planned Payment as Paid

- **Method:** `PATCH`
- **Endpoint:** `/api/v1/planned-payments/:id/mark-paid`
- **Request Body:** `{}` (empty)

#### 5.4 Response (`200 OK`)

```json
{
  "success": true,
  "data": {
    "id": 19,
    "status": "paid"
  },
  "message": "Planned payment marked as paid"
}
```

---

### 5.5 Delete Planned Payment

- **Method:** `DELETE`
- **Endpoint:** `/api/v1/planned-payments/:id`
- **Response:** `204 No Content`

---

## 6. Payment Accounts & Bank Wallets (`/bank-accounts`)

### 6.1 List Bank Accounts & Balances

Used to populate dropdowns for payment methods / receiving bank accounts.

- **Method:** `GET`
- **Endpoint:** `/api/v1/bank-accounts`

#### 6.1 Response (`200 OK`)

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "bank_name": "HDFC Bank",
      "account_holder": "Cliks Tech",
      "account_number": "50200012345678",
      "ifsc": "HDFC0001234",
      "branch": "Main Branch",
      "current_balance": 184500.00,
      "account_type": "Current",
      "status": "Active"
    }
  ]
}
```

---

### 6.2 Add New Bank Account

- **Method:** `POST`
- **Endpoint:** `/api/v1/bank-accounts`

#### 6.2 Request Body

```json
{
  "bank_name": "State Bank of India",
  "account_holder": "Cliks Business Account",
  "account_number": "30192837465",
  "ifsc": "SBIN0000456",
  "branch": "MG Road Branch",
  "opening_balance": 50000.00,
  "account_type": "Current"
}
```

#### 6.2 Response (`201 Created`)

```json
{
  "success": true,
  "data": {
    "id": 2,
    "bank_name": "State Bank of India",
    "account_number": "30192837465",
    "current_balance": 50000.00
  },
  "message": "Bank account created successfully"
}
```

---

## 7. Endpoints Quick Reference & Summary

### 7.1 Complete Endpoints Summary Table

| # | HTTP Method | Endpoint Path | Module / Section | Description / Purpose |
| --- | --- | --- | --- | --- |
| 1 | `POST` | `/api/v1/payments/receive` *(alias: `/customer-receipts`)* | Core Payments | Record incoming customer payment & reconcile |
| 2 | `POST` | `/api/v1/payments/pay` | Core Payments | Record outgoing payment to vendor/supplier |
| 3 | `POST` | `/api/v1/payments/transfer` | Core Payments | Internal transfer between bank/cash accounts |
| 4 | `GET` | `/api/v1/payments/reports` | Core Payments | Unified receivables, payables, accounts & overdue invoices |
| 5 | `GET` | `/api/v1/payments/outstanding` | Core Payments | High-level aggregated stats of processed payments |
| 6 | `POST` / `GET` | `/api/v1/payments/create-order` | Core Payments | Create Cashfree / UPI payment gateway order session |
| 7 | `POST` | `/api/v1/billing/:id/payments` *(alias: `/api/v1/invoices/:id/payments`)* | Invoices | Record payment directly against a specific invoice |
| 8 | `GET` | `/api/v1/billing/:id/payments` | Invoices | List all payment transactions for an invoice |
| 9 | `POST` | `/api/v1/purchases/:id/payments` | Purchase Bills | Record payment for a supplier purchase bill |
| 10 | `GET` | `/api/v1/purchases/:id/payments` | Purchase Bills | Get payment details for a purchase bill |
| 11 | `GET` | `/api/v1/planned-payments` | Planned Payments | List & filter scheduled/recurring payments |
| 12 | `POST` | `/api/v1/planned-payments` | Planned Payments | Create a new scheduled/recurring payment |
| 13 | `PATCH` | `/api/v1/planned-payments/:id` | Planned Payments | Update a planned payment |
| 14 | `PATCH` | `/api/v1/planned-payments/:id/mark-paid` | Planned Payments | Mark a planned payment as paid |
| 15 | `DELETE` | `/api/v1/planned-payments/:id` | Planned Payments | Delete a planned payment |
| 16 | `GET` | `/api/v1/bank-accounts` | Bank Accounts | List all active bank and cash accounts & balances |
| 17 | `POST` | `/api/v1/bank-accounts` | Bank Accounts | Add a new bank/cash account |

### 7.2 Endpoints Grouped by Feature

#### Core Business Payments Routes (`/api/v1/payments`)

- `POST /api/v1/payments/receive` *(Alternative: `/api/v1/payments/customer-receipts`)*
- `POST /api/v1/payments/pay`
- `POST /api/v1/payments/transfer`
- `GET /api/v1/payments/reports`
- `GET /api/v1/payments/outstanding`
- `POST /api/v1/payments/create-order` *(supports `GET` with query params)*

#### Invoice Direct Payments Routes (`/api/v1/billing` or `/api/v1/invoices`)

- `POST /api/v1/billing/:id/payments` *(Alternative: `/api/v1/invoices/:id/payments`)*
- `GET /api/v1/billing/:id/payments`

#### Supplier Purchase Bill Payments Routes (`/api/v1/purchases`)

- `POST /api/v1/purchases/:id/payments`
- `GET /api/v1/purchases/:id/payments`

#### Planned and Scheduled Payments Routes (`/api/v1/planned-payments`)

- `GET /api/v1/planned-payments` *(Query params: `status`, `category`, `search`, `type`, `page`, `limit`, `sort`, `order`)*
- `POST /api/v1/planned-payments`
- `PATCH /api/v1/planned-payments/:id`
- `PATCH /api/v1/planned-payments/:id/mark-paid`
- `DELETE /api/v1/planned-payments/:id`

#### Payment Accounts and Bank Wallets Routes (`/api/v1/bank-accounts`)

- `GET /api/v1/bank-accounts`
- `POST /api/v1/bank-accounts`
