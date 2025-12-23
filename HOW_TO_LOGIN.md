# Lighten Up - How to Login

## Current Backend Setup

The app is currently using a **Mock API** for development. This means:
- ✅ No real backend required
- ✅ Login works with ANY email/password
- ✅ All authentication flows work (login, logout, token refresh)

## How to Login (Mock Mode)

1. **Run the app:**
   ```bash
   cd lighten_up
   
   # For web (Chrome)
   flutter run -d chrome
   
   # For macOS
   flutter run -d macos
   ```

2. **Login credentials:**
   - **Email**: ANY email (e.g., `test@example.com`, `doctor@hospital.com`)
   - **Password**: ANY password (e.g., `password123`, `test`)
   
   The mock interceptor accepts any credentials and returns a successful login!

3. **What you'll see:**
   - Login screen with dark theme
   - After login → Dashboard with user info
   - User will be "Dr. John Doe" (mock data)
   - Quick action cards for Messages, Alerts, Patients, Staff
   - Logout button returns to login screen

## Mock API Details

The mock interceptor simulates these endpoints:

- **POST /api/v1/auth/login**: Returns mock access token + user data
- **GET /api/v1/users/me**: Returns mock user profile
- **POST /api/v1/auth/logout**: Returns success

**Mock User Profile:**
```json
{
  "id": "user_123",
  "email": "john.doe@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "doctor",
  "department": "Cardiology",
  "title": "Senior Physician"
}
```

## Switching to a Real Backend

When you're ready to connect to a real backend:

### Step 1: Update API Base URL

Edit `lib/core/network/api_endpoints.dart`:

```dart
static const String baseUrl = 'https://your-api.com';
```

### Step 2: Remove Mock Interceptor

Edit `lib/presentation/providers/core_providers.dart`:

```dart
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(
    // Remove this line:
    // additionalInterceptors: [MockApiInterceptor()],
  );
}
```

Or just change to:

```dart
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(); // No mock interceptor
}
```

### Step 3: Backend Requirements

Your backend needs these endpoints:

**1. Login**
```
POST /api/v1/auth/login
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "expires_in": 3600,
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "doctor",
    "status": "online",
    "department": "Cardiology",
    "title": "Senior Physician",
    "is_active": true,
    "is_verified": true
  }
}
```

**2. Get Current User**
```
GET /api/v1/users/me
Authorization: Bearer {access_token}

Response (200):
{
  "id": "user_123",
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "doctor",
  ...
}
```

**3. Logout**
```
POST /api/v1/auth/logout
Authorization: Bearer {access_token}

Response (200):
{
  "message": "Logged out successfully"
}
```

## Project Structure

```
lib/
├── core/
│   └── network/
│       ├── api_client.dart          # HTTP client
│       ├── api_endpoints.dart        # API URLs (UPDATE THIS)
│       └── mock_api_interceptor.dart # Mock backend (REMOVE FOR PROD)
├── data/
│   └── repositories/
│       └── auth_repository_impl.dart # Auth logic
└── presentation/
    ├── providers/
    │   └── core_providers.dart       # DI setup (REMOVE MOCK HERE)
    └── screens/
        ├── auth/login_screen.dart    # Login UI
        └── dashboard/dashboard_screen.dart  # Dashboard UI
```

## Testing Tips

### Test Login Flow
1. Enter any email/password
2. Click "Sign In"
3. Should navigate to dashboard
4. Should see "Welcome back, John Doe"

### Test Logout Flow
1. Click "Logout" button on dashboard
2. Should return to login screen
3. Auth state should be cleared

### Check Browser Console
- Open DevTools (F12)
- Console tab shows:
  - `🔶 Mock API Request: POST /api/v1/auth/login`
  - `✅ Returning mock response`

## Common Issues

### "No ProviderScope found"
- Make sure `main.dart` has `ProviderScope`:
  ```dart
  runApp(const ProviderScope(child: MyApp()));
  ```

### Login button does nothing
- Check browser console for errors
- Verify email/password fields are filled

### Stays on login screen after clicking Sign In
- Check if `go_router` is configured correctly
- Verify auth state is updating (use Flutter DevTools)

## Next Steps

1. ✅ Login with mock API (works now!)
2. 🔲 Build/connect real backend
3. 🔲 Implement other features (Messages, Alerts, etc.)
4. 🔲 Add proper error handling for network failures
5. 🔲 Add loading states and better UX

---

**Current Status**: Mock API mode - Login works with ANY credentials!
