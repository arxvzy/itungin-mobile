
## Project Overview

Build a Flutter mobile application for **Itungin**, a personal finance management app.

The app connects to a Laravel 12 RESTful API using Laravel Sanctum Bearer Token authentication.

The mobile app must allow users to:

1. Register and login
2. View dashboard summary
3. Manage income and expense transactions
4. Manage saving targets
5. Add funds to saving targets
6. Chat with an AI financial assistant
7. Persist login session securely
8. Handle API validation, authentication, and server errors gracefully

---

## Backend API Information

### Base URL

For local development:

```txt
http://localhost:8000/api
````

For Android emulator, use:

```txt
http://10.0.2.2:8000/api
```

For physical Android device, use the computer LAN IP address:

```txt
http://192.168.x.x:8000/api
```

Example:

```txt
http://192.168.1.10:8000/api
```

### Content Type

All requests and responses use:

```txt
Content-Type: application/json
Accept: application/json
```

### Authentication

Protected endpoints require:

```txt
Authorization: Bearer <token>
```

The token is obtained from login or register response.

Store the token securely using `flutter_secure_storage`.

---

## Recommended Flutter Stack

Use the following packages:

```yaml
dependencies:
  flutter:
    sdk: flutter

  dio: ^5.0.0
  flutter_secure_storage: ^9.0.0
  provider: ^6.0.0
  intl: ^0.19.0
  fl_chart: ^0.68.0
```

Recommended architecture:

```txt
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── api_exception.dart
│   ├── storage/
│   │   └── secure_storage_service.dart
│   └── utils/
│       ├── currency_formatter.dart
│       └── date_formatter.dart
├── models/
│   ├── user_model.dart
│   ├── transaction_model.dart
│   ├── target_model.dart
│   ├── dashboard_model.dart
│   └── chat_model.dart
├── services/
│   ├── auth_service.dart
│   ├── dashboard_service.dart
│   ├── transaction_service.dart
│   ├── target_service.dart
│   └── chat_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── dashboard_provider.dart
│   ├── transaction_provider.dart
│   ├── target_provider.dart
│   └── chat_provider.dart
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── transactions/
    │   ├── transaction_list_screen.dart
    │   ├── transaction_form_screen.dart
    │   └── transaction_detail_screen.dart
    ├── targets/
    │   ├── target_list_screen.dart
    │   ├── target_form_screen.dart
    │   └── add_fund_screen.dart
    ├── chat/
    │   └── chat_screen.dart
    └── profile/
        └── profile_screen.dart
```

---

## App Features

## 1. Authentication

### Login Screen

Create a login screen with:

* Username input
* Password input
* Login button
* Link to register screen
* Loading state
* Error message display

Endpoint:

```txt
POST /login
```

Request body:

```json
{
  "username": "budi",
  "password": "password"
}
```

Successful response contains:

```json
{
  "status": "success",
  "message": "Login successful",
  "user": {},
  "token": "TOKEN_HERE"
}
```

After successful login:

1. Save token securely
2. Save user data locally if needed
3. Redirect to dashboard screen

### Register Screen

Create a register screen with:

* Name input
* Username input
* Email input
* Password input
* Password confirmation input
* Register button
* Link back to login screen

Endpoint:

```txt
POST /register
```

Request body:

```json
{
  "name": "John Doe",
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

After successful register:

1. Save token securely
2. Save user data locally if needed
3. Redirect to dashboard screen

### Logout

Endpoint:

```txt
POST /logout
```

After successful logout:

1. Delete token from secure storage
2. Clear provider state
3. Redirect to login screen

### Current User

Endpoint:

```txt
GET /user
```

Use this endpoint to check whether the stored token is still valid when the app starts.

---

## 2. Dashboard

Create a dashboard screen that shows:

* Total wealth or current balance
* Monthly income
* Monthly expense
* Recent transactions
* Monthly balance chart

Endpoint:

```txt
GET /dashboard
```

Expected response structure:

```json
{
  "status": "success",
  "data": {
    "total_wealth": 28450000,
    "monthly_income": 12500000,
    "monthly_expense": 8500000,
    "recent_transactions": [],
    "chart": {
      "labels": [1, 2, 3],
      "actual": [5.5, 5.8, 6.2],
      "target": [8.0, 8.0, 8.0]
    }
  }
}
```

UI requirements:

* Format all currency values as Indonesian Rupiah
* Use `intl` package for currency formatting
* Show loading indicator while fetching
* Show empty state when there is no transaction data
* Use `fl_chart` to display actual balance and target line

Currency format example:

```txt
Rp28.450.000
```

---

## 3. Transactions

The app must support CRUD for transactions.

### Transaction List

Endpoint:

```txt
GET /transactions
```

Optional filter:

```txt
GET /transactions?filter=semua
GET /transactions?filter=pemasukan
GET /transactions?filter=pengeluaran
```

Screen requirements:

* Show current balance
* Show total income
* Show total expense
* Show transaction list
* Add filter tabs:

  * Semua
  * Pemasukan
  * Pengeluaran
* Add floating action button to create transaction
* Allow edit and delete transaction

Transaction fields:

```json
{
  "id": 135,
  "user_id": 1,
  "tipe_transaksi": "pengeluaran",
  "jumlah": 250000,
  "kategori": "Belanja",
  "deskripsi": "Beli grocery di supermarket",
  "tanggal": "2026-05-10",
  "created_at": "2026-05-10T10:30:00.000000Z",
  "updated_at": "2026-05-10T10:30:00.000000Z"
}
```

### Create Transaction

Endpoint:

```txt
POST /transactions
```

Request body:

```json
{
  "tipe_transaksi": "pengeluaran",
  "jumlah": 150000,
  "kategori": "Makanan",
  "deskripsi": "Makan di restoran",
  "tanggal": "2026-05-10"
}
```

Validation rules:

* `tipe_transaksi` must be `pemasukan` or `pengeluaran`
* `jumlah` must be numeric and minimum 1
* `kategori` is required
* `deskripsi` is required
* `tanggal` must use `YYYY-MM-DD`

### Update Transaction

Endpoint:

```txt
PUT /transactions/{id}
PATCH /transactions/{id}
```

Use the same request body as create transaction.

### Delete Transaction

Endpoint:

```txt
DELETE /transactions/{id}
```

Before deleting, show confirmation dialog.

### Transaction Form UI

Fields:

* Transaction type dropdown:

  * Pemasukan
  * Pengeluaran
* Amount input
* Category input
* Description input
* Date picker
* Submit button

Important:

* Send `pemasukan` or `pengeluaran` as API value
* Date must be formatted as `YYYY-MM-DD`
* Amount must be sent as integer, not formatted string

---

## 4. Saving Targets

The app must support CRUD for saving targets.

### Target List

Endpoint:

```txt
GET /targets
```

Screen requirements:

* Show user balance
* Show list of saving targets
* Show target progress percentage
* Show target deadline
* Show status badge:

  * Aktif
  * Tercapai
* Add button to create target
* Add button to add funds to target
* Allow edit and delete target

Target fields:

```json
{
  "id": 1,
  "user_id": 1,
  "nama_target": "Tabungan Liburan ke Bali",
  "target_jumlah": 10000000,
  "jumlah_terkumpul": 7500000,
  "tanggal_target": "2026-12-15",
  "status": "aktif",
  "kategori": "Tabungan",
  "created_at": "2026-05-10T13:20:22.000000Z",
  "updated_at": "2026-05-10T13:20:22.000000Z"
}
```

Progress formula:

```dart
final progress = jumlahTerkumpul / targetJumlah;
```

Clamp progress between 0 and 1.

### Create Target

Endpoint:

```txt
POST /targets
```

Request body:

```json
{
  "nama_target": "Tabungan Pendidikan",
  "target_jumlah": 50000000,
  "tanggal_target": "2027-06-01",
  "kategori": "Tabungan"
}
```

### Update Target

Endpoint:

```txt
PUT /targets/{id}
PATCH /targets/{id}
```

Use the same request body as create target.

### Delete Target

Endpoint:

```txt
DELETE /targets/{id}
```

Before deleting, show confirmation dialog.

### Add Funds to Target

Endpoint:

```txt
POST /targets/{id}/add-fund
```

Request body:

```json
{
  "jumlah_fund": 1000000
}
```

Important behavior:

* This transfers funds from user balance to the saving target
* Backend automatically creates an expense transaction
* Backend may return insufficient balance error
* Refresh target list and dashboard after success

---

## 5. Chatbot

Create a chat screen for AI financial assistant.

Endpoint:

```txt
POST /chat
```

Request body:

```json
{
  "message": "Saya ingin beli laptop seharga 8 juta. Boleh tidak dengan saldo saya saat ini?"
}
```

Response:

```json
{
  "status": "success",
  "reply": "Dengan saldo Anda saat ini sebesar Rp28.450.000..."
}
```

Screen requirements:

* Chat message list
* User message bubble
* AI reply bubble
* Text input
* Send button
* Loading indicator while waiting for AI response
* Error message when request fails

Important:

* Chatbot may automatically create transactions
* Chatbot may automatically update saving targets
* After successful chat response, refresh dashboard, transactions, and targets because financial data may have changed

---

## API Error Handling

The app must handle these errors consistently.

### 401 Unauthorized

Possible response:

```json
{
  "status": "error",
  "message": "Unauthenticated."
}
```

or:

```json
{
  "status": "error",
  "message": "Sesi habis, silakan login ulang."
}
```

Required behavior:

1. Delete stored token
2. Clear auth state
3. Redirect to login screen
4. Show message: `Sesi habis, silakan login ulang.`

### 422 Validation Error

Possible response:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "jumlah": ["The jumlah must be at least 1."]
  }
}
```

Required behavior:

* Display validation errors near the related form fields
* If field-specific display is difficult, show the first error in snackbar

### 422 Insufficient Balance

Possible response:

```json
{
  "status": "error",
  "message": "Saldo tidak cukup!"
}
```

or:

```json
{
  "status": "error",
  "message": "Saldo tidak cukup untuk menambahkan dana ke target!"
}
```

Required behavior:

* Show error dialog or snackbar
* Do not close the form automatically

### 404 Not Found

Required behavior:

* Show message from API
* Refresh list because the resource may have been deleted

### 429 API Limit

Possible response:

```json
{
  "status": "error",
  "message": "Semua API Key limit."
}
```

Required behavior:

* Show message to user
* Keep chat input available for retry

### 500 Server Error

Required behavior:

* Show general message:
  `Terjadi kesalahan pada server. Silakan coba lagi.`
* Log detailed error in debug mode only

---

## Data Models

## UserModel

Fields:

```dart
int id;
String name;
String username;
String email;
int saldo;
String? createdAt;
String? updatedAt;
```

## TransactionModel

Fields:

```dart
int id;
int userId;
String tipeTransaksi;
int jumlah;
String kategori;
String deskripsi;
String tanggal;
String? createdAt;
String? updatedAt;
```

## TargetModel

Fields:

```dart
int id;
int userId;
String namaTarget;
int targetJumlah;
int jumlahTerkumpul;
String tanggalTarget;
String status;
String kategori;
String? createdAt;
String? updatedAt;
```

## DashboardModel

Fields:

```dart
int totalWealth;
int monthlyIncome;
int monthlyExpense;
List<TransactionModel> recentTransactions;
DashboardChartModel chart;
```

## DashboardChartModel

Fields:

```dart
List<int> labels;
List<double> actual;
List<double> target;
```

## ChatMessageModel

Fields:

```dart
String message;
bool isUser;
DateTime createdAt;
```

---

## Service Layer Requirements

Each service must only handle API communication.

Required services:

```txt
AuthService
DashboardService
TransactionService
TargetService
ChatService
```

### AuthService

Methods:

```dart
Future<AuthResponse> login(String username, String password);
Future<AuthResponse> register({
  required String name,
  required String username,
  required String email,
  required String password,
  required String passwordConfirmation,
});
Future<UserModel> getCurrentUser();
Future<void> logout();
```

### DashboardService

Methods:

```dart
Future<DashboardModel> getDashboard();
```

### TransactionService

Methods:

```dart
Future<TransactionListResponse> getTransactions({String filter = 'semua'});
Future<TransactionModel> createTransaction(CreateTransactionRequest request);
Future<TransactionModel> updateTransaction(int id, CreateTransactionRequest request);
Future<void> deleteTransaction(int id);
```

### TargetService

Methods:

```dart
Future<TargetListResponse> getTargets();
Future<TargetModel> createTarget(CreateTargetRequest request);
Future<TargetModel> updateTarget(int id, CreateTargetRequest request);
Future<void> deleteTarget(int id);
Future<TargetModel> addFund(int id, int jumlahFund);
```

### ChatService

Methods:

```dart
Future<String> sendMessage(String message);
```

---

## State Management Requirements

Use Provider or ChangeNotifier.

Required providers:

```txt
AuthProvider
DashboardProvider
TransactionProvider
TargetProvider
ChatProvider
```

### AuthProvider

State:

```dart
UserModel? user;
bool isAuthenticated;
bool isLoading;
String? errorMessage;
```

Responsibilities:

* Login
* Register
* Logout
* Check existing session on app start
* Store and delete token

### DashboardProvider

State:

```dart
DashboardModel? dashboard;
bool isLoading;
String? errorMessage;
```

Responsibilities:

* Fetch dashboard data
* Refresh dashboard after transaction or target changes

### TransactionProvider

State:

```dart
List<TransactionModel> transactions;
int saldo;
int totalPemasukan;
int totalPengeluaran;
String currentFilter;
bool isLoading;
String? errorMessage;
```

Responsibilities:

* Fetch transactions
* Filter transactions
* Create transaction
* Update transaction
* Delete transaction

### TargetProvider

State:

```dart
List<TargetModel> targets;
UserModel? user;
bool isLoading;
String? errorMessage;
```

Responsibilities:

* Fetch targets
* Create target
* Update target
* Delete target
* Add funds to target

### ChatProvider

State:

```dart
List<ChatMessageModel> messages;
bool isLoading;
String? errorMessage;
```

Responsibilities:

* Send chat message
* Store local conversation history during app session
* Refresh financial data after AI action

---

## Navigation Flow

App startup flow:

```txt
Splash Screen
↓
Check token from secure storage
↓
If token exists, call GET /user
↓
If valid, go to Dashboard
↓
If invalid, go to Login
```

Main navigation after login:

```txt
Bottom Navigation
├── Dashboard
├── Transactions
├── Targets
├── Chat
└── Profile
```

Profile screen:

* Show user name
* Show username
* Show email
* Show balance
* Logout button

---

## UI Guidelines

Use clean and simple personal finance UI.

Recommended visual structure:

* Dashboard cards for balance, income, and expense
* Green indicator for income
* Red indicator for expense
* Blue or primary color for saving targets
* Progress bar for target completion
* Bottom navigation for main modules
* Floating action button for adding transaction or target

Important formatting:

* Currency must be displayed as Indonesian Rupiah
* Date must be displayed in readable Indonesian format
* API date format must remain `YYYY-MM-DD`

Example currency helper:

```dart
String formatRupiah(int value) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  return formatter.format(value);
}
```

Example API date format:

```dart
String formatDateForApi(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
```

---

## Security Requirements

1. Never hardcode real tokens
2. Store token using `flutter_secure_storage`
3. Automatically attach token using Dio interceptor
4. Clear token on logout
5. Clear token when API returns 401
6. Do not print token in production logs
7. Do not store password locally

---

## Dio Client Requirements

Create a centralized Dio client.

It must:

1. Use the base API URL
2. Add `Accept: application/json`
3. Add `Content-Type: application/json`
4. Attach Bearer token automatically if available
5. Handle 401 globally
6. Parse error message from API response

Example behavior:

```txt
Before request:
- Read token from secure storage
- If token exists, add Authorization header

After error:
- If status code is 401, clear token and redirect to login
```

---

## Refresh Rules

After creating, updating, or deleting a transaction:

* Refresh transactions
* Refresh dashboard
* Refresh current user if needed

After creating, updating, deleting, or funding a target:

* Refresh targets
* Refresh dashboard
* Refresh transactions if add-fund was used

After chatbot response:

* Refresh dashboard
* Refresh transactions
* Refresh targets

---

## Form Validation

Validate input before sending API request.

### Transaction Form

Rules:

* Transaction type is required
* Amount is required
* Amount must be greater than 0
* Category is required
* Description is required
* Date is required

### Target Form

Rules:

* Target name is required
* Target amount is required
* Target amount must be greater than 0
* Target date is required
* Category is required

### Add Fund Form

Rules:

* Fund amount is required
* Fund amount must be greater than 0

### Login Form

Rules:

* Username is required
* Password is required

### Register Form

Rules:

* Name is required
* Username is required
* Email is required
* Email must be valid
* Password is required
* Password minimum length is 8
* Password confirmation must match password

---

## Important API Field Mapping

Use exact API field names when sending JSON.

### Transaction

Flutter property:

```dart
tipeTransaksi
```

API field:

```json
"tipe_transaksi"
```

Flutter property:

```dart
jumlah
```

API field:

```json
"jumlah"
```

Flutter property:

```dart
kategori
```

API field:

```json
"kategori"
```

Flutter property:

```dart
deskripsi
```

API field:

```json
"deskripsi"
```

Flutter property:

```dart
tanggal
```

API field:

```json
"tanggal"
```

### Target

Flutter property:

```dart
namaTarget
```

API field:

```json
"nama_target"
```

Flutter property:

```dart
targetJumlah
```

API field:

```json
"target_jumlah"
```

Flutter property:

```dart
jumlahTerkumpul
```

API field:

```json
"jumlah_terkumpul"
```

Flutter property:

```dart
tanggalTarget
```

API field:

```json
"tanggal_target"
```

Flutter property:

```dart
kategori
```

API field:

```json
"kategori"
```

### Add Fund

Flutter property:

```dart
jumlahFund
```

API field:

```json
"jumlah_fund"
```

---

## Minimum Screens To Implement

The mobile app is considered complete when these screens exist:

1. Splash screen
2. Login screen
3. Register screen
4. Dashboard screen
5. Transaction list screen
6. Create transaction screen
7. Edit transaction screen
8. Target list screen
9. Create target screen
10. Edit target screen
11. Add fund screen
12. Chat screen
13. Profile screen

---

## Acceptance Criteria

The Flutter app is complete when:

* User can register
* User can login
* Token is stored securely
* User stays logged in after reopening the app
* User can logout
* Dashboard data loads correctly
* Dashboard chart is displayed
* User can view transactions
* User can filter transactions
* User can create transaction
* User can edit transaction
* User can delete transaction
* User can view saving targets
* User can create saving target
* User can edit saving target
* User can delete saving target
* User can add funds to saving target
* User can chat with AI assistant
* App handles 401, 422, 404, 429, and 500 errors
* Currency is displayed in Rupiah format
* Dates sent to API use `YYYY-MM-DD`
* UI refreshes after data-changing actions
* App works on Android physical device using LAN backend URL

---

## Development Notes

When running Laravel backend locally and testing on a physical Android phone:

1. Make sure phone and computer are on the same Wi-Fi network
2. Run Laravel with host binding:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

3. Use computer local IP address in Flutter:

```txt
http://192.168.x.x:8000/api
```

4. If the request fails, check firewall settings

---

## Do Not Do

* Do not hardcode Bearer token
* Do not store password locally
* Do not send formatted Rupiah string to API
* Do not send date in display format to API
* Do not ignore 401 errors
* Do not duplicate API logic inside UI widgets
* Do not mutate provider state directly from screens
* Do not assume chatbot only returns text without side effects

```
```
