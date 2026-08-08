# Implementation Plan - Fix HandshakeException (Expired Certificate)

The goal is to resolve the `HandshakeException: CERTIFICATE_VERIFY_FAILED: certificate has expired` error that is currently blocking API requests. This typically happens in development environments when the server's SSL certificate has expired.

## User Review Required

> [!IMPORTANT]
> This fix bypasses SSL certificate verification. While this is acceptable and common for **development and staging environments**, it should **NOT** be used in production apps as it poses a security risk.

## Proposed Changes

### [Core]
#### [MODIFY] [main.dart](file:///C:/xampp/htdocs/number_plate_scanner/lib/main.dart)
- Import `dart:io`.
- Define a `DevHttpOverrides` class that implements `HttpOverrides` and overrides `createHttpClient` to bypass certificate verification.
- Set `HttpOverrides.global = DevHttpOverrides()` in the `main()` function before the app starts.

## Verification Plan

### Automated Tests
- None, as this is a network-level configuration.

### Manual Verification
1. Restart the application.
2. Attempt to log in again.
3. Verify that the `HandshakeException` no longer occurs and the login request proceeds to the server.
