import 'dart:async';
import 'package:app_links/app_links.dart';
import '../utils/logger.dart';

class DeepLinkService {
  static const String _tag = 'DeepLinkService';
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Callback when a payment success link is received
  Function(String reference)? onPaymentSuccess;

  void init() {
    AppLogger.logInfo(_tag, 'Initializing DeepLinkService');
    
    // Check initial link if app was closed
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    }, onError: (err) {
      AppLogger.logError(_tag, 'Deep link error', err);
    });
  }

  void _handleUri(Uri uri) {
    AppLogger.logInfo(_tag, 'Received deep link: $uri');
    
    // Check if it's our payment success path
    if (uri.path.contains('payment-success') || uri.host == 'payment-success') {
      final reference = uri.queryParameters['reference'];
      if (reference != null && reference.isNotEmpty) {
        AppLogger.logInfo(_tag, 'Payment success for reference: $reference');
        onPaymentSuccess?.call(reference);
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
