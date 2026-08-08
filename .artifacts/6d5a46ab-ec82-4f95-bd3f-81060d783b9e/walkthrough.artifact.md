# Walkthrough - SSL Certificate Bypass

I have implemented a workaround for the `HandshakeException` caused by the expired SSL certificate on the server.

## Changes Made

### [Core]
#### [MODIFY] [main.dart](file:///C:/xampp/htdocs/number_plate_scanner/lib/main.dart)
- Added `DevHttpOverrides` class to ignore certificate verification errors.
- Configured `HttpOverrides.global` to use this class on app startup.

```dart
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = DevHttpOverrides();
  // ...
}
```

> [!WARNING]
> This is a **development-only** fix. Before deploying to production, ensure the server has a valid SSL certificate and remove this override to maintain app security.

## Verification Results

### Manual Verification
- You can now restart the app and attempt the login. The `CERTIFICATE_VERIFY_FAILED` error should no longer appear, and the request should reach the server successfully.
