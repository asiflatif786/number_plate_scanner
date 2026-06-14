# Cyber1 TMS Flutter App — Complete Architecture & Flow Reference

## 1. Philosophy: Flutter → Laravel → CyberTMS

The Flutter app **NEVER calls CyberTMS directly**. Every API call goes to the **Laravel backend** at:

```
ApiConstants.laravelBaseUrl = 'https://tms-local-api.justerrand.ie/api/v1'
```

The Laravel server acts as a **proxy/middleware**. It:
1. Receives the Flutter request
2. Adds `channel_number`, `service_number`, and other server-side metadata
3. Forwards to CyberTMS
4. Returns the TMS response back to Flutter

**There is no direct TMS endpoint call in the Flutter code.**

---

## 2. Architecture Pattern

**Pattern:** MVVM (Model-View-ViewModel) with Provider + ChangeNotifier
**Navigation:** `Navigator.pushNamed` with centralized `AppRoutes` constants
**State:** 9 global ViewModels provided via `MultiProvider` in `main.dart`, rest are per-screen via `ChangeNotifierProvider`
**API:** Singleton `ApiClient` instance with `get()`, `post()`, `put()` methods
**Session:** Singleton `SessionManager` backed by `SharedPreferences`

### Data Flow

```
User → Screen → ViewModel (ChangeNotifier) → Repository → ApiClient (Singleton)
  → HTTP GET/POST/PUT → Laravel (https://tms-local-api.justerrand.ie/api/v1)
  → CyberTMS (backend proxy)
  → Response → ApiResponse<Model> → ViewModel updates state → UI rebuilds
```

### Key File Locations

| Layer | Path | Pattern |
|-------|------|---------|
| **Entry** | `lib/main.dart` | Firebase init → Session init → MultiProvider → MaterialApp |
| **Routes** | `lib/app/routes.dart` | 20 route constants + route table |
| **API Client** | `lib/core/network/api_client.dart` | Singleton, GET/POST/PUT, `api-key` header, dual response format |
| **Session** | `lib/core/session/session_manager.dart` | Singleton, SharedPreferences-backed |
| **API Constants** | `lib/core/constants/api_constants.dart` | All endpoint paths + keys |
| **App Constants** | `lib/core/constants/app_constants.dart` | Fee %, vehicle types, UI defaults, storage keys |
| **Active Repos** | `lib/data/repositories/` | REST-based repositories (single source of truth) |
| **Auth Repo** | `lib/features/repositories/auth_repository.dart` | Login API calls |
| **Onboarding Repo** | `lib/features/repositories/onboarding_repository.dart` | Corporate/Agent/Terminal creation |
| **Widgets** | `lib/core/widgets/` | 12 reusable widgets |
| **Models** | `lib/data/models/` | 11 data models |

---

## 3. Tech Stack

| Technology | Package | Purpose |
|-----------|---------|---------|
| **Flutter** | SDK >=3.0.0 <4.0.0 | Cross-platform UI |
| **State Management** | provider ^6.1.2 | ChangeNotifier + Provider |
| **HTTP** | http ^1.2.0 | REST client |
| **Local Storage** | shared_preferences ^2.3.5 | Session + local transaction log |
| **Camera** | camera ^0.11.0+2 | Camera access for scanner |
| **ML Kit OCR** | google_mlkit_text_recognition ^0.11.0 | Text recognition for plate scanning |
| **Permissions** | permission_handler ^11.3.0 | Camera permissions |
| **Image Picker** | image_picker ^1.1.2 | Document upload (onboarding) |
| **Firebase** | firebase_core ^2.25.4, firebase_auth ^4.17.4 | Firebase init (auth not actively used) |
| **Google Sign In** | google_sign_in ^6.2.1 | Available, NOT actively used |
| **Share** | share_plus ^10.0.0 | Share receipt |
| **Formatting** | intl ^0.19.0 | Currency/date formatting |
| **UI** | flutter_svg, lottie, shimmer | Animations & placeholders |
| **Connectivity** | connectivity_plus | Internet check before requests |
| **Toast** | fluttertoast | Login success toast |

---

## 4. Complete API Reference (Flutter → Laravel)

### 4.1 Authentication

#### POST /auth/login
**Called when:** Login button pressed on `LoginScreen`
**URL:** `https://tms-local-api.justerrand.ie/api/v1/auth/login`

**Request Body:**
```json
{
  "email": "agent@example.com",
  "password": "password123"
}
```

**Success Response (old format):**
```json
{
  "status": true,
  "data": {
    "id": 1,
    "email": "agent@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "Agent",
    "agent_number": "AGT-001",
    "company_number": "CMP-001",
    "token": "eyJ..."
  },
  "message": "Login successful"
}
```

**On success:**
- Session saves: role, email, firstName, lastName, agentNumber, companyNumber, authToken
- `ApiClient.instance.setApiKey(key)` — key comes from response somewhere (not the token; the api-key header value)
- Navigate based on role: `Admin` → `/admin-dashboard`, else → `/agent-dashboard`

---

### 4.2 Location Data

#### GET /state/get-states
**Called when:** Any state dropdown loads (onboarding screens, transaction creation, vehicle registration)
**URL:** `https://tms-local-api.justerrand.ie/api/v1/state/get-states`

**No query params.**

**Response shape:**
```json
{
  "status": true,
  "data": {
    "data_list": [
      {"state_id": "1", "state_name": "Lagos"},
      {"state_id": "2", "state_name": "Abuja FCT"},
      ...
    ]
  }
}
```

**Caching:** `LocationRepository` caches states in-memory (`_cachedStates`). Subsequent calls return cached data.

#### GET /state/get-lgas
**Called when:** LGA dropdown loads after state selection

**Two different query param styles depending on caller:**
- `LocationRepository.getLgas()` uses `state_id` (transaction screens, vehicle registration)
- `OnboardingRepository.getLgas()` uses `state_name` (onboarding screens — corporate/agent registration)

**URL with state_id:** `https://tms-local-api.justerrand.ie/api/v1/state/get-lgas?state_id=1`
**URL with state_name:** `https://tms-local-api.justerrand.ie/api/v1/state/get-lgas?state_name=Lagos`

**Response shape:**
```json
{
  "status": true,
  "data": {
    "data_list": [
      {"lga_id": "101", "lga_name": "Ikeja", "state_id": "1"},
      {"lga_id": "102", "lga_name": "Eti-Osa", "state_id": "1"},
      ...
    ]
  }
}
```

**Caching:** `LocationRepository` caches LGAs per `stateId` in `_lgaCache` map.

---

### 4.3 Onboarding

#### POST /corporate/create-company
**Called when:** Corporate registration form submitted
**URL:** `https://tms-local-api.justerrand.ie/api/v1/corporate/create-company`

**Request Body:**
```json
{
  "name": "Cyber1 Tech Ltd",
  "rc_number": "RC123456",
  "tin": "TIN987654",
  "email": "info@cyber1.com",
  "phone_number": "08012345678",
  "address": "123 Main Street",
  "contact_address": "456 Branch Road",
  "city": "Ikeja",
  "state": "Lagos",
  "lga": "Ikeja"
}
```

**Success Response:** Returns `company_number` in `response.data!['company_number']`.

**After success:** `SessionManager.setCompanyNumber(companyNumber)` → navigate to `/agent-registration`

---

#### POST /agent/add-agent
**Called when:** Agent registration form submitted
**URL:** `https://tms-local-api.justerrand.ie/api/v1/agent/add-agent`

**Request Body:**
```json
{
  "title": "Mr",
  "first_name": "John",
  "middle_name": "",
  "last_name": "Doe",
  "email": "john.doe@cyber1.com",
  "password": "securePass123",
  "phone_number": "08012345678",
  "date_of_birth": "1990-01-15",
  "gender": "male",
  "marital_status": "single",
  "nationality": "Nigerian",
  "address": "123 Street, Ikeja",
  "city": "Ikeja",
  "state": "Lagos",
  "lga": "Ikeja",
  "state_of_origin": "Lagos",
  "lga_of_origin": "Ikeja",
  "bvn": "12345678901",
  "nin": "12345678901",
  "id_type": "Voters Card",
  "identity_number": "ID123456",
  "tin": "TIN987654",
  "bank_name": "GTBank",
  "account_number": "0123456789",
  "account_name": "John Doe",
  "sort_code": "058",
  "company_number": "CMP-001",
  "utility_bill": "/9j/4AAQ...base64string...",
  "identity_document": "/9j/4AAQ...base64string...",
  "passport_photo": "/9j/4AAQ...base64string..."
}
```

**Document upload:** Images are picked via `ImagePicker`, converted to base64, and sent as strings.

**After success:** `SessionManager.setAgentNumber(agentNumber)` → navigate to `/terminal-profiling`

---

#### POST /terminal/create-terminal
**Called when:** Terminal profiling form submitted
**URL:** `https://tms-local-api.justerrand.ie/api/v1/terminal/create-terminal`

**Request Body:**
```json
{
  "serial_number": "SN-123456",
  "terminal_id": "T-789012",
  "agent_number": "AGT-001"
}
```

**After success:** `SessionManager.saveOnboardingComplete(...)` — saves all data + sets `is_onboarded = true` → navigate to `/onboarding-complete`

**OnboardingComplete Screen:** Shows credentials summary (agent number, company number, terminal ID, email). User copies and proceeds to dashboard.

---

### 4.4 Vehicle Operations

#### GET /validation/validate-customer
**Called when:** Search button pressed on `VehicleSearchScreen`
**URL:** `https://tms-local-api.justerrand.ie/api/v1/validation/validate-customer`

**Query Params:**
```
vehicle_license=BAL31XA
transaction_type=single|complete
channel_number=CH-001
service_number=SV-001
```

**channel_number** and **service_number** are read from `SessionManager` at request time.

**Success Response:**
```json
{
  "status": true,
  "data": {
    "customer_name": "John Doe",
    "vehicle_license": "BAL31XA",
    "vehicle_type": "Saloon Car",
    "vehicle_color": "Blue",
    "vehicle_make": "Toyota",
    "vehicle_model": "Camry",
    "state_of_origin": "Lagos",
    "enumerating_state": "Lagos",
    "enumerating_lga": "Ikeja",
    "issuing_state": "Lagos",
    "phone_number": "08012345678",
    "transaction_type": "single",
    "price": {
      "amount": 1000.0,
      "service_fee": 0.0,
      "currency": "NGN",
      "name": "Saloon Car",
      "type": "single"
    }
  }
}
```

**On success (status true or status_code "00"):** Navigate to `/vehicle-found` passing `VehicleModel`
**On status_code "04" (Not Found):** Navigate to `/vehicle-not-found` passing plate string
**Other failures:** Show error message on search screen

---

#### POST /vehicle/register
**Called when:** Vehicle registration form submitted (after vehicle not found)
**URL:** `https://tms-local-api.justerrand.ie/api/v1/vehicle/register`

**Request Body (from VehicleRegistrationModel.toJson()):**
```json
{
  "license_plate": "BAL31XA",
  "vehicle_type": "Saloon Car",
  "chassis_number": "CH123456",
  "engine_number": "EN789012",
  "year_of_manufacture": "2020",
  "owner_name": "John Doe",
  "owner_phone": "08012345678",
  "owner_address": "123 Street, Ikeja",
  "owner_state": "Lagos",
  "owner_lga": "Ikeja",
  "issuing_state": "Lagos",
  "issuing_lga": "Ikeja",
  "enumerating_state": "Lagos",
  "enumerating_lga": "Ikeja"
}
```

**On success:** Show success dialog → pop back to vehicle search

---

### 4.5 Transactions

#### POST /transaction/create
**Called when:** Transaction creation form submitted (after filling payer details, origin/destination, payment method)
**URL:** `https://tms-local-api.justerrand.ie/api/v1/transaction/create`

**Request Body:**
```json
{
  "transaction_reference": "TXN-1712345678000",
  "payer_name": "John Doe",
  "payer_phone": "08012345678",
  "payer_email": "john@example.com",
  "amount": "1000.00",
  "fee": "145.00",
  "payment_method": "card",
  "terminal_id": "T-789012",
  "vehicle_license": "BAL31XA",
  "vehicle_type": "Saloon Car",
  "transaction_type": "single",
  "origin_state": "Lagos",
  "origin_lga": "Ikeja",
  "destination_state": null,
  "destination_lga": null,
  "transaction_date": "2024-04-05 14:30:00"
}
```

**Notes:**
- `transaction_reference` generated client-side: `TXN-${DateTime.now().millisecondsSinceEpoch}`
- `amount` and `fee` are formatted as strings with 2 decimal places
- `destination_state`/`destination_lga` are `null` for single trips, populated for complete trips
- `terminal_id` read from session at request time
- `payment_method` is one of: `card`, `wallet`, `transfer`

**After success:** Navigate to `/payment-processing`

---

#### Transaction Flow (after creation)

**Payment Processing Screen** (auto-starts on init):
1. Simulates payment with 2-second `Future.delayed` (TODO: real payment SDK)
2. On simulated success:
   - `PUT /transaction/approve` `{transaction_reference, channel_number}`
3. On simulated failure:
   - `PUT /transaction/decline` `{transaction_reference, channel_number}`
4. Saves to local `TransactionLogStore`
5. On success → navigates to `/transaction-success`

---

#### PUT /transaction/approve
**Request Body:** `{transaction_reference, channel_number}`
**Response:** Success/failure boolean

#### PUT /transaction/decline
**Request Body:** `{transaction_reference, channel_number}`
**Response:** Success/failure boolean

#### PUT /transaction/abandon
**Request Body:** `{transaction_reference, channel_number}`
**Response:** Success/failure boolean

#### PUT /transaction/invalidate
**Request Body:** `{transaction_reference, channel_number}`
**Response:** Success/failure boolean

---

### 4.6 Transaction Query

#### GET /transaction/verify
**URL:** `https://tms-local-api.justerrand.ie/api/v1/transaction/verify`
**Query Params:** `transaction_reference=TXN-xxx`, `channel_number=CH-001`

**Response:** Returns `TransactionModel` with current status

#### GET /transaction/list
**URL:** `https://tms-local-api.justerrand.ie/api/v1/transaction/list`
**Query Params:** `channel_number=CH-001`, `page=1`, `status?=approved`

**Response shape:**
```json
{
  "status": true,
  "data": {
    "data_list": [...],
    "total_pages": 5,
    "total": 47
  }
}
```

**Pagination:** Infinite scroll — each page load increments `_currentPage`. `totalPages` stored in `TransactionRepository.totalPages`.

---

### 4.7 Agent Management (Admin)

#### GET /agent/list-agents
**Query Params:** `channel_number=CH-001`, `page=1`
**Response:** Paginated list with `data_list`, `total_pages`, `total`

#### GET /agent/get-agent
**Query Params:** `agent_number=AGT-001`

#### GET /agent/get-agent-status
**Query Params:** `agent_number=AGT-001`
**Response:** `{status: "active"|"inactive"|...}`

#### GET /agent/get-kyc-status
**Query Params:** `agent_number=AGT-001`
**Response:** `{kyc_complete: true|false}`

#### PUT /agent/assign-agent-to-company
**Body:** `{agent_number, company_number}`

---

### 4.8 Corporate Management (Admin)

#### GET /corporate/get-company-kyc-status
**Query Params:** `company_number=CMP-001`
**Response:** `{kyc_complete: true|false}`

#### GET /corporate/get-company-status
**Query Params:** `company_number=CMP-001`
**Response:** `{status: "active"|"inactive"|...}`

---

## 5. Session Management

Backed by `SharedPreferences` via `SessionManager` singleton.

### Session Keys Stored

| Key | Storage Constant | Source | Used In |
|-----|-----------------|--------|---------|
| `is_onboarded` | `AppConstants.isOnboardedKey` | Set after onboarding complete | Session validity check |
| `company_number` | `AppConstants.companyNumberKey` | Corporate registration response | Admin dashboard, agent ops |
| `agent_number` | `AppConstants.agentNumberKey` | Agent registration response | Receipt display |
| `terminal_id` | `AppConstants.terminalIdKey` | Terminal profiling response | Create-transaction payload |
| `serial_number` | `AppConstants.serialNumberKey` | Terminal profiling response | (stored, not actively used) |
| `user_role` | `AppConstants.userRoleKey` | Login response `role` field | Dashboard routing |
| `user_email` | `AppConstants.userEmailKey` | Login response | Credential summary |
| `user_first_name` | `AppConstants.userFirstNameKey` | Login response | Dashboard greeting |
| `user_last_name` | `AppConstants.userLastNameKey` | Login response | Dashboard greeting |
| `auth_token` | `AppConstants.authTokenKey` | Login response `token` | (saved, not actively used) |
| `channel_number` | `ApiConstants.channelNumberKey` | Set by admin setup | Added to validate, approve, decline, list, verify, abandon, invalidate |
| `service_number_validation` | `ApiConstants.serviceNumberValidationKey` | Set by admin setup | Added to validate-vehicle GET |
| `service_number_transaction` | `ApiConstants.serviceNumberTransactionKey` | Set by admin setup | (future use) |

### api-key Header

The `api-key` is set **in-memory** (not persisted) via `ApiClient.instance.setApiKey(key)` after login. It's sent on every request as an HTTP header. It is **never logged** in plain text.

### Session Validity

```dart
bool hasValidSession() {
  return isOnboarded && agentNumber != null && terminalId != null;
}
```

### Clear Session (Logout)
All 13 keys are removed from SharedPreferences. Navigates to `/login`.

---

## 6. Dual Response Format

`ApiClient._handleResponse()` supports both formats transparently:

**Old Format:**
```json
{"status": true, "data": {...}, "message": "Success"}
```

**New Format:**
```json
{"status_code": "00", "data": {...}, "message": "Success"}
```

### Status Code Mapping

| Code | Meaning | Failure Type | Action |
|------|---------|-------------|--------|
| `"00"` | Success | — | Process data normally |
| `"01"` | Unknown failure | `UnknownFailure` | Show error message |
| `"02"` | Auth error | `AuthFailure` | Show "re-login" message |
| `"03"` | Auth error | `AuthFailure` | Show "re-login" message |
| `"04"` | Not found | `NotFoundFailure` | **Triggers vehicle registration flow** |
| `"05"` | Duplicate | `DuplicateFailure` | Show "already exists" message |

---

## 7. Complete Screen Flow & API Call Chain

### 7.1 App Startup

```
main.dart
  ├─ Firebase.initializeApp()
  ├─ SessionManager.instance.init()
  └─ runApp(Cyber1TMSApp)
       └─ MultiProvider (9 global ViewModels)
            └─ MaterialApp (initialRoute: /splash)

SplashScreen (/splash)
  └─ SplashViewModel.checkSession()
       ├─ SessionManager.instance.hasValidSession() == true
       │    ├─ role == 'Admin' → /admin-dashboard
       │    └─ role != 'Admin' → /agent-dashboard
       └─ hasValidSession() == false → /login
```

### 7.2 Login

```
LoginScreen (/login)
  ├─ User enters email + password
  └─ LoginViewModel.login()
       └─ AuthRepository.login(email, password)
            └─ POST /auth/login {email, password}
                 ├─ On Success:
                 │    → UserModel.fromJson(response.data)
                 │    → SessionManager.saveOnboardingComplete(role, email, firstName, lastName, agentNumber, companyNumber)
                 │    → session.setAuthToken(user.authToken!)
                 │    → ApiClient.instance.setApiKey(key)
                 │    → Fluttertoast.showToast("Welcome, {firstName}!")
                 │    → Admin? /admin-dashboard : /agent-dashboard
                 └─ On Failure:
                      → Show error message on screen
```

### 7.3 Onboarding Flow (First-time Agent Setup)

This is a 4-step sequential registration process for new agents:

```
LoginScreen → "Register Here" link → /corporate-registration

┌─────────────────────────────────────────────────────────────┐
│ STEP 1: CorporateRegistrationScreen (/corporate-registration)│
├─────────────────────────────────────────────────────────────┤
│  init: loadStates() → GET /state/get-states                 │
│  onStateChanged: GET /state/get-lgas?state_name=Lagos       │
│  submit: POST /corporate/create-company {name, rc_number,   │
│          tin, email, phone, address, city, state, lga}       │
│  Success → session.setCompanyNumber(companyNumber)           │
│         → Navigator.pushReplacementNamed(/agent-registration)│
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: AgentRegistrationScreen (/agent-registration)        │
├─────────────────────────────────────────────────────────────┤
│  init: loadStates() → GET /state/get-states                 │
│  onResidentialStateChanged: GET /state/get-lgas?state_name=  │
│  onOriginStateChanged: GET /state/get-lgas?state_name=       │
│  pickDocument(): ImagePicker → crop → base64 encode          │
│  submit: POST /agent/add-agent {title, first_name, ...,     │
│          utility_bill(base64), identity_document(base64),    │
│          passport_photo(base64)}                             │
│  Success → session.setAgentNumber(agentNumber)               │
│         → Navigator.pushReplacementNamed(/terminal-profiling)│
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: TerminalProfilingScreen (/terminal-profiling)        │
├─────────────────────────────────────────────────────────────┤
│  submit: POST /terminal/create-terminal {serial_number,     │
│          terminal_id, agent_number}                          │
│  Success → session.saveOnboardingComplete(agentNumber,       │
│            companyNumber, terminalId, serialNumber, email,   │
│            firstName, lastName, role)                        │
│         → Navigator.pushReplacementNamed(/onboarding-complete)│
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: OnboardingCompleteScreen (/onboarding-complete)      │
├─────────────────────────────────────────────────────────────┤
│  Shows: Company No., Agent No., Terminal ID, Email           │
│  User can copy credentials to clipboard                      │
│  "Proceed to Dashboard" → /agent-dashboard                  │
└─────────────────────────────────────────────────────────────┘
```

### 7.4 Transaction Flow (Agent)

```
┌─────────────────────────────────────────────────────────────┐
│ AgentDashboardScreen (/agent-dashboard)                     │
│  Menu items:                                                 │
│  ├─ "Create Transaction" → /vehicle-search                   │
│  ├─ "Transaction History" → /transaction-history            │
│  └─ "Scan Plate" → /scanner (direct scan from dashboard)    │
└─────────────────────────────────────────────────────────────┘
                              ↓ (Create Transaction)
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: VehicleSearchScreen (/vehicle-search)                │
├─────────────────────────────────────────────────────────────┤
│  ├─ Select trip type: Single / Complete                     │
│  ├─ Enter license plate manually OR tap "Scan Plate"        │
│  │    → /scanner (Google ML Kit OCR)                        │
│  │    → Navigator.pop(context, extractedPlate)               │
│  │    → fills licensePlateController.text                   │
│  └─ "Search" button → VehicleSearchViewModel.search()       │
│       → GET /validation/validate-customer                   │
│         ?vehicle_license=BAL31XA                             │
│         &transaction_type=single                             │
│         &channel_number=...                                  │
│         &service_number=...                                  │
│         ├─ Success (status true or "00")                     │
│         │    → /vehicle-found (passing VehicleModel)        │
│         └─ NotFound (status_code "04")                      │
│              → /vehicle-not-found (passing plate string)    │
└─────────────────────────────────────────────────────────────┘
                    ↓ Found                  ↓ Not Found
               ┌──────────┐          ┌──────────────────┐
               │ STEP 2   │          │ STEP 2 ALT       │
               │ Vehicle  │          │ Vehicle Not Found │
               │ Found    │          │ Screen            │
               └────┬─────┘          └────────┬─────────┘
                    ↓                         ↓
┌──────────────────────────────┐  ┌──────────────────────────────┐
│ VehicleFoundScreen           │  │ VehicleNotFoundScreen        │
│ (/vehicle-found)             │  │ (/vehicle-not-found)         │
├──────────────────────────────┤  ├──────────────────────────────┤
│ Shows vehicle details:       │  │ "Register Vehicle" button    │
│  - Customer Name             │  │  → /vehicle-registration     │
│  - License Plate             │  │    (passing plate string)    │
│  - Vehicle Make/Model/Color  │  │                              │
│  - Vehicle Type              │  │ VehicleRegistrationScreen    │
│  - State of Origin           │  │ (/vehicle-registration)      │
│                              │  ├──────────────────────────────┤
│ Shows fee breakdown:         │  │ Form fields:                 │
│  - Base Amount: ₦1,000.00   │  │  - License Plate (prefilled) │
│  - Admin Fee (2%): ₦20.00   │  │  - Vehicle Type (dropdown,   │
│  - Processing Fee: ₦100.00  │  │    12 types from AppConstants)│
│  - VAT (7.5%): ₦1.50        │  │  - Chassis Number            │
│  - Total Payable: ₦1,121.50 │  │  - Engine Number             │
│                              │  │  - Year of Manufacture       │
│ "Proceed to Payment" button  │  │  - Owner Name, Phone, Address│
│  → /transaction-creation    │  │  - Owner State/LGA           │
│    (passing VehicleModel)    │  │  - Issuing State/LGA         │
└──────────────────────────────┘  │  - Enumerating State/LGA    │
                    ↓             │                              │
┌──────────────────────────────┐  │ loadStates() → GET /state/   │
│ STEP 3: TransactionCreation  │  │   get-states                 │
│ (/transaction-creation)      │  │ onStateChanged → GET /state/ │
├──────────────────────────────┤  │   get-lgas?state_id=...      │
│ init: loadStates() → GET /   │  │ submit: POST /vehicle/       │
│   state/get-states           │  │   register {license_plate,   │
│ onOriginStateChanged: GET /  │  │   vehicle_type, ...}         │
│   state/get-lgas?state_id=   │  │ Success → pop back to search │
│ onDestStateChanged: GET /    │  └──────────────────────────────┘
│   state/get-lgas?state_id=   │
│                              │
│ Form fields:                 │
│  - Payer Name (prefilled     │
│    from vehicle data)        │
│  - Payer Phone               │
│  - Payer Email               │
│  - Origin State/LGA (drop)   │
│  - Destination State/LGA     │
│    (only for Complete Trip)  │
│  - Payment Method: Card/     │
│    Wallet/Transfer           │
│                              │
│ submit: POST /transaction/   │
│   create {...}               │
│  → /payment-processing       │
└──────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: PaymentProcessingScreen (/payment-processing)       │
├─────────────────────────────────────────────────────────────┤
│  Auto-starts on init():                                     │
│  ├─ Simulates payment (2-second Future.delayed)             │
│  ├─ Success → PUT /transaction/approve {ref, channel}       │
│  │         → status = 'approved'                             │
│  │         → "View Receipt" → /transaction-success          │
│  └─ Failure → PUT /transaction/decline {ref, channel}       │
│            → status = 'declined'                             │
│            → Show failure UI (retry / cancel)               │
│  Saves to local TransactionLogStore                          │
└─────────────────────────────────────────────────────────────┘
              ↓ (on success)
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: TransactionSuccessScreen (/transaction-success)     │
├─────────────────────────────────────────────────────────────┤
│  Animated receipt screen with:                               │
│  - Transaction reference, status chip, route, breakdown     │
│  - Animated checkmark + card slide-in                       │
│  Actions:                                                    │
│  ├─ Copy Receipt to clipboard                                │
│  ├─ Share Receipt (system share sheet)                      │
│  ├─ Approve → PUT /transaction/approve {ref, channel}       │
│  ├─ Decline → PUT /transaction/decline {ref, channel}       │
│  ├─ Abandon → PUT /transaction/abandon {ref, channel}       │
│  ├─ Invalidate → PUT /transaction/invalidate {ref, channel} │
│  └─ "New Transaction" → /vehicle-search                    │
│  └─ "Back to Dashboard" → /agent-dashboard                 │
└─────────────────────────────────────────────────────────────┘
```

### 7.5 Transaction History

```
TransactionHistoryScreen (/transaction-history)
  ├─ On init: GET /transaction/list?channel_number=X&page=1
  ├─ Infinite scroll: GET /transaction/list?channel_number=X&page=N
  │   (triggered when scrolling near bottom)
  ├─ Pull-to-refresh: refresh=true → page=1
  ├─ Status filter dropdown (All/Approved/Pending/Declined):
  │   → onStatusFilterChanged → loadTransactions(refresh:true)
  │   → GET /transaction/list?channel_number=X&page=1&status=approved
  ├─ Local search (client-side):
  │   → Filters by transactionReference, customerName, vehicleLicense
  ├─ Row action "Verify":
  │   → GET /transaction/verify?transaction_reference=X&channel_number=X
  │   → Updates local status via copyWith
  └─ Row action "Abandon":
       → ConfirmationDialog → PUT /transaction/abandon {ref, channel}
       → Removes from local list
```

### 7.6 Transaction Detail

```
TransactionDetailScreen (/transaction-detail)
  ├─ Arguments: TransactionModel
  ├─ Shows full transaction info
  └─ "Verify Status" → GET /transaction/verify?ref=X&channel=X
```

### 7.7 Admin Dashboard

```
AdminDashboardScreen (/admin-dashboard)
  ├─ On init: loadSession() + checkCompanyHealth()
  │   ├─ GET /corporate/get-company-status?company_number=X
  │   └─ GET /corporate/get-company-kyc-status?company_number=X
  ├─ Shows: Admin name, company number, current date
  ├─ Warning banner if KYC incomplete or company inactive
  └─ Menu grid:
       ├─ "View Agents" → /view-agents
       ├─ "Transaction History" → /transaction-history
       └─ "Search Vehicle" → /vehicle-search
```

### 7.8 View Agents (Admin)

```
ViewAgentsScreen (/view-agents)
  ├─ On init: GET /agent/list-agents?channel_number=X&page=1
  ├─ Infinite scroll: GET /agent/list-agents?channel_number=X&page=N
  ├─ Local search by name/agent number
  └─ Tap agent → /agent-detail (agent_number as argument)

AgentDetailScreen (/agent-detail)
  ├─ On init: loadAgentHealth()
  │   ├─ GET /agent/get-agent?agent_number=X
  │   ├─ GET /agent/get-agent-status?agent_number=X
  │   └─ GET /agent/get-kyc-status?agent_number=X
  ├─ Shows: Personal info, address, identity (masked BVN/NIN), banking
  ├─ Status badge + KYC badge
  └─ Masked sensitive fields with reveal toggle
```

---

## 8. Fee Calculation (All Client-Side)

Fee calculation is done **entirely client-side** in `VehicleFoundViewModel` and `TransactionCreationViewModel` using constants from `AppConstants`:

```dart
static const double adminFeePercent = 0.02;       // 2%
static const double flatTransactionFee = 100.0;    // ₦100 fixed processing fee
static const double vatPercent = 0.075;            // 7.5% VAT
```

### Formula

```
baseAmount = vehicle.price.amount          (from validate-vehicle response)
adminFee   = baseAmount × 0.02
vat        = (adminFee + flatFee) × 0.075
totalFee   = adminFee + flatFee + vat
totalPayable = baseAmount + totalFee
```

### Example (₦1,000 base)

| Item | Amount |
|------|--------|
| Base Amount | ₦1,000.00 |
| Admin Fee (2%) | ₦20.00 |
| Processing Fee | ₦100.00 |
| VAT (7.5% of ₦120) | ₦9.00 |
| **Total Payable** | **₦1,129.00** |

---

## 9. All Data Models (11 Models)

### UserModel
```dart
id, email, firstName, lastName, role (Admin|Agent),
agentNumber?, companyNumber?, authToken?
```
- `fromJson`: maps `token` → `authToken`
- `isAdmin`: `role == 'Admin'`

### VehicleModel
```dart
customerName, vehicleLicense, vehicleType, vehicleColor,
vehicleMake, vehicleModel, stateOfOrigin,
enumeratingState?, enumeratingLga?, issuingState?,
phoneNumber?, transactionType (single|complete), price (PriceModel)
```

### PriceModel
```dart
amount, serviceFee, currency (NGN)
```
- Parses both `price` and `amount` keys

### TransactionModel
```dart
transactionReference, transactionId?, customerName,
vehicleLicense, amount, serviceFee, totalAmount,
paymentMethod (card|wallet|transfer),
transactionType (single|complete),
status (pending|approved|declined|abandoned|invalidated),
originState, originLga, destinationState, destinationLga,
agentNumber, terminalId, createdAt
```
- `fromJson` looks at both top-level keys and nested `transaction_details`
- `copyWith` allows status updates only

### TransactionDraftModel
```dart
vehicle (VehicleModel), originState, originStateId, originLga, originLgaId,
destinationState, destinationStateId, destinationLga, destinationLgaId, payerEmail
```
- Used for in-progress transactions (not actively used in current flow)

### AgentModel
```dart
id?, agentNumber, title, firstName, lastName, email,
phoneNumber, companyNumber, gender, maritalStatus, dateOfBirth,
address, city, state, lga, stateOfOrigin, lgaOfOrigin, nationality,
bvn, nin, bankName, accountNumber, accountName, sortCode?,
idType, identityNumber, tin?
```

### CompanyModel
```dart
companyNumber, name, rcNumber, email, phoneNumber,
address, contactAddress, tin, city, state, lga
```

### TerminalModel
```dart
serialNumber, terminalId, agentNumber
```

### StateModel
```dart
stateId, stateName
```

### LgaModel
```dart
lgaId, lgaName, stateId
```

### VehicleRegistrationModel
```dart
licensePlate, vehicleType, chassisNumber, engineNumber, yearOfManufacture,
ownerName, ownerPhone, ownerAddress, ownerState, ownerLga,
issuingState, issuingLga, enumeratingState, enumeratingLga
```
- Has `toJson()` only (no `fromJson` — write-only model)

### VerifyResultModel
```dart
transactionReference, status, amount, fee
```

---

## 10. Reusable Widgets (12 Active Widgets)

All in `lib/core/widgets/`. Every screen uses these exclusively — no inline `Card`, `ElevatedButton`, `OutlinedButton`, `TextField`, or `TextFormField`.

| Widget | File | Purpose | Key Props |
|--------|------|---------|-----------|
| **AppButton** | `app_button.dart` | All buttons (filled, outlined, text, loading) | `label`, `onPressed`, `isLoading`, `isOutlined`, `icon`, `color`, `textColor`, `height`, `fontSize` |
| **AppTextField** | `app_text_field.dart` | All text fields | `label`, `hint`, `controller`, `keyboardType`, `obscureText`, `readOnly`, `maxLines`, `validator`, `textCapitalization`, `maxLength`, `prefixIcon`, `suffixIcon`, `textInputAction`, `initialValue`, `enabled`, `fillColor`, `customPadding` |
| **AppCard** | `app_card.dart` | Cards with consistent elevation/padding/radius | `child`, `padding`, `margin`, `borderColor`, `onTap` |
| **DetailRow** | `detail_row.dart` | Label + value rows (info display, fee breakdowns) | `label`, `value`, `isMonospace`, `isSelectable` |
| **SectionHeader** | `section_header.dart` | Section titles with optional subtitle | `title`, `subtitle`, `actionLabel`, `onAction` |
| **StatusChip** | `status_chip.dart` | Status badges (approved/green, pending/amber, declined/red) | `status`, `size` |
| **ShimmerLoader** | `shimmer_loader.dart` | Loading placeholder animations | `width`, `height`, `borderRadius` |
| **ErrorStateWidget** | `state_widgets.dart` | Full-page error with retry button | `message`, `onRetry` |
| **EmptyStateWidget** | `state_widgets.dart` | Empty list state with action | `message`, `icon`, `actionLabel`, `onAction` |
| **ConfirmationDialog** | `confirmation_dialog.dart` | Confirm/cancel dialogs | `title`, `message`, `confirmLabel`, `onConfirm`, `isDestructive` |
| **MaskedField** | `masked_field.dart` | Input masking (phone, BVN, NIN) | `controller`, `mask`, `keyboardType` |
| **LoadingOverlay** | `loading_overlay.dart` | Full-screen loading overlay | `message` |
| **SectionCard** | `section_card.dart` | Grouped card with header | `title`, `children` |
| **ResponsiveLayout** | `responsive_layout.dart` | Adaptive mobile/tablet layout | `mobile`, `tablet` |
| **ResponsiveText** | `responsive_text.dart` | Font scaling | `text`, `style` |

---

## 11. Scanner Implementation (Google ML Kit)

**File:** `lib/features/vehicle/scanner_view.dart` (393 lines)
**ViewModel:** `lib/features/vehicle/scanner_viewmodel.dart`

### How it works:
1. Requests camera permission via `permission_handler`
2. Initializes camera controller with resolution preset
3. Starts a periodic timer (every 500ms) that captures camera images
4. Passes images to `google_mlkit_text_recognition` `TextRecognizer`
5. Extracted text is passed through `PlateExtractor` (custom regex for Nigerian plates)
6. Auto-stops scanning when a valid plate is detected
7. Shows confirmation panel with detected plate
8. User confirms → `Navigator.pop(context, plate)`

### Nigerian Plate Regex Patterns (in `PlateExtractor`):
- Standard format: e.g., `BAL31XA`, `LAG123ABC`
- 3 letters + 2-4 digits + 2 letters (or variations)

### Visual Features:
- Animated scan line overlay
- Torch toggle button
- Corner detection frame
- Auto-zoom indicator

---

## 12. Local Transaction Log (Offline Reference)

**File:** `lib/data/local/transaction_log_store.dart`

- Stores completed transactions locally in `SharedPreferences` as JSON
- Key: `'transaction_log'`
- Max entries: 200 (oldest are trimmed)
- Methods: `saveTransaction()`, `getAll()`, `updateStatus()`, `clear()`
- Used for offline reference only (not as primary data source)

---

## 13. State Management Details

### Global ViewModels (registered in `main.dart` MultiProvider):
1. `SplashViewModel` — Session check on startup
2. `LoginViewModel` — Login form logic
3. `CorporateRegistrationViewModel` — Step 1 onboarding
4. `AgentRegistrationViewModel` — Step 2 onboarding
5. `TerminalProfilingViewModel` — Step 3 onboarding
6. `OnboardingCompleteViewModel` — Step 4 success
7. `AdminDashboardViewModel` — Admin home + company health
8. `ViewAgentsViewModel` — Agent list with pagination
9. `AgentDashboardViewModel` — Agent home

### Per-Screen ViewModels (created on-demand via `ChangeNotifierProvider`):
1. `VehicleSearchViewModel` — Search/scan plate
2. `VehicleFoundViewModel` — Vehicle details + fee calc
3. `VehicleNotFoundViewModel` — Registration redirect
4. `VehicleRegistrationViewModel` — Register new vehicle
5. `ScannerViewModel` — Camera/OCR
6. `TransactionCreationViewModel` — Payer details + submit
7. `PaymentProcessingViewModel` — Payment simulation
8. `TransactionSuccessViewModel` — Receipt + status actions
9. `TransactionHistoryViewModel` — Paginated history
10. `TransactionDetailViewModel` — Single detail + verify
11. `AgentDetailViewModel` — Agent profile + status/KYC

---

## 14. Active vs Dead Code

### Active Code — DO USE
| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry |
| `lib/app/routes.dart` | Route definitions |
| `lib/core/` (all files) | Constants, network, session, widgets, utils, errors |
| `lib/data/models/` | All 11 models |
| `lib/data/repositories/` | 4 REST repositories (vehicle, transaction, agent, location) |
| `lib/data/local/` | TransactionLogStore |
| `lib/features/auth/` | Login screen + viewmodel |
| `lib/features/splash/` | Splash screen + viewmodel |
| `lib/features/onboarding/` | 4 onboarding screens + viewmodels |
| `lib/features/agent/` | Agent dashboard + viewmodel |
| `lib/features/admin/` | Admin dashboard, view agents, agent detail |
| `lib/features/vehicle/` | Scanner, search, found, not found, registration |
| `lib/features/transaction/` | Creation, payment, success, history, detail |
| `lib/features/repositories/auth_repository.dart` | Login API |
| `lib/features/repositories/onboarding_repository.dart` | Onboarding API |

### Dead Code — DO NOT MODIFY / DELETE
| Path | Error Count |
|------|-------------|
| `lib/features/*/data/repositories/*_impl.dart` | 8 errors |
| `lib/features/*/presentation/` | 3 errors |
| `lib/features/repositories/vehicle_repository.dart` | 2 errors |
| `lib/core/network/network_client.dart` | 3 errors |
| `lib/core/router/` | References to non-existent files |
| Root-level `lib/*.dart` duplicates | 0 errors but unused |

These files are never imported by any active code. They are compile-time dead.

---

## 15. flutter analyze Status

**0 errors in active code.** 18 remaining errors are all in dead-code files. The project builds and runs clean.

---

## 16. Key Implementation Notes

1. **`api-key` header**: Set once after login via `ApiClient.instance.setApiKey(key)`. Sent on every request. Never logged in plain text.

2. **`channelNumber` / `serviceNumber`**: Read from `SessionManager` at request time inside each repository method. Not stored in API constants.

3. **`terminalId`**: Read from session in `TransactionCreationViewModel.submit()`, included in create-transaction payload.

4. **Scanner**: Uses Google ML Kit `TextRecognizer` + custom `PlateExtractor` (regex-based for Nigerian plates). Returns scanned plate via `Navigator.pop(context, plate)`.

5. **Transaction References**: Generated client-side as `TXN-{millisecondsSinceEpoch}`.

6. **Payment**: Currently **simulated** with a 2-second delay. TODOs exist for real SDK integration.

7. **Local Transaction Log**: `TransactionLogStore` saves completed transactions locally (for offline reference). Max 200 entries.

8. **Vehicle Types**: 12 types hardcoded in `AppConstants.vehicleTypes`:
   - Saloon Car, SUV/Jeep (4 Tyres), Pick Up Vans (4 Tyres), Pick Up Heavy Duty (6/8 Tyres), Buses (18+ seater), Mini Bus (14-17 seater), Motorcycles, Tricycles (Keke), Trucks (6 Tyres), Trucks (10+ Tyres), Trailers, Tankers

9. **Fee constants**: Edit `AppConstants.adminFeePercent` (0.02), `flatTransactionFee` (100.0), `vatPercent` (0.075) to change pricing.

10. **Onboarding state**: Checked via `SessionManager.hasValidSession()` which verifies `isOnboarded && agentNumber != null && terminalId != null`.

11. **Connectivity**: Every API call checks internet connectivity first via `connectivity_plus`. Returns `NetworkFailure` if offline.

12. **Timeout**: All API calls have a 30-second timeout (`ApiConstants.timeout`).

13. **Firebase**: Initialized in `main.dart`. `firebase_auth` and `google_sign_in` are available as dependencies but **not actively used** for authentication.

14. **No .env files**: Configuration is done via hardcoded constants in `api_constants.dart` + runtime session values.

---

## 17. Route Map (20 Routes)

| Route Constant | Route Path | Screen | Arguments |
|---------------|-----------|--------|-----------|
| `splash` | `/splash` | SplashScreen | none |
| `login` | `/login` | LoginScreen | none |
| `corporateRegistration` | `/corporate-registration` | CorporateRegistrationScreen | none |
| `agentRegistration` | `/agent-registration` | AgentRegistrationScreen | none |
| `terminalProfiling` | `/terminal-profiling` | TerminalProfilingScreen | none |
| `onboardingComplete` | `/onboarding-complete` | OnboardingCompleteScreen | none |
| `adminDashboard` | `/admin-dashboard` | AdminDashboardScreen | none |
| `agentDashboard` | `/agent-dashboard` | AgentDashboardScreen | none |
| `vehicleSearch` | `/vehicle-search` | VehicleSearchScreen | none |
| `vehicleFound` | `/vehicle-found` | VehicleFoundScreen | `VehicleModel` |
| `vehicleNotFound` | `/vehicle-not-found` | VehicleNotFoundScreen | `String` (plate) |
| `vehicleRegistration` | `/vehicle-registration` | VehicleRegistrationScreen | `String` (plate) |
| `scanner` | `/scanner` | ScannerView | none (returns `String` via pop) |
| `transactionCreation` | `/transaction-creation` | TransactionCreationScreen | `VehicleModel` |
| `paymentProcessing` | `/payment-processing` | PaymentProcessingScreen | `TransactionModel` |
| `transactionSuccess` | `/transaction-success` | TransactionSuccessScreen | `TransactionModel` |
| `transactionHistory` | `/transaction-history` | TransactionHistoryScreen | none |
| `transactionDetail` | `/transaction-detail` | TransactionDetailScreen | `TransactionModel` |
| `viewAgents` | `/view-agents` | ViewAgentsScreen | none |
| `agentDetail` | `/agent-detail` | AgentDetailScreen | `String` (agent number) |

---

## 18. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  http: ^1.2.0
  shared_preferences: ^2.3.5
  camera: ^0.11.0+2
  google_mlkit_text_recognition: ^0.11.0
  permission_handler: ^11.3.0
  image_picker: ^1.1.2
  firebase_core: ^2.25.4
  firebase_auth: ^4.17.4
  google_sign_in: ^6.2.1
  flutter_svg: ^2.0.17
  lottie: ^3.3.1
  shimmer: ^3.0.0
  intl: ^0.19.0
  share_plus: ^10.0.0
  connectivity_plus: ^6.1.3
  fluttertoast: ^8.2.2
```

---

## 19. Quick Summary for New Developers

- **This is a vehicle/traffic ticket management system** for Nigerian roads
- **Agents** scan license plates, look up vehicles in the TMS, and process payments
- **Admins** manage agents, view transactions, and check company health
- **All data flows:** Flutter → Laravel Proxy → CyberTMS backend
- **Auth:** Custom email/password login via Laravel (not Firebase Auth)
- **Payment:** Simulated (2s delay) — no real payment SDK integrated
- **Offline:** Minimal — only local transaction log for reference
- **State:** Provider/ChangeNotifier (no BLoC, no Riverpod)
- **20 API endpoints** across auth, states, onboarding, vehicles, transactions, agents
- **11 data models** with JSON serialization
- **12 reusable widgets** for consistent UI
- **18 compile errors** exist but are all in dead code — active code has 0 errors
