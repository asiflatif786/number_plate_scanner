import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/session_provider.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _tag = 'SplashScreen';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _animationController.forward();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final sessionProvider = context.read<SessionProvider>();
    await sessionProvider.initialize();

    if (!mounted) return;

    final sessionService = await SessionService.getInstance();

    final isFirstLaunch = await sessionService.isFirstLaunch();

    if (!mounted) return;

    if (isFirstLaunch || !sessionProvider.hasValidSession) {
      AppLogger.info(_tag, 'No valid session — routing to onboarding');
      Navigator.pushReplacementNamed(context, '/company-registration');
    } else {
      AppLogger.info(_tag, 'Valid session found — routing to vehicle search');
      Navigator.pushReplacementNamed(context, '/vehicle-search');
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.logScreenInfo(context);
    final iconSize = ResponsiveHelper.iconSize(context, 100);
    final shieldSize = ResponsiveHelper.iconSize(context, 56);
    final appNameSize = ResponsiveHelper.fontSize(context, 28);
    final taglineSize = ResponsiveHelper.fontSize(context, 14);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0288D1)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.defaultRadius),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: shieldSize,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacingBetweenSections(context)),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: appNameSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction Management System',
                    style: TextStyle(
                      fontSize: taglineSize,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacingBetweenSections(context) * 2),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
