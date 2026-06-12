import 'package:flutter/material.dart';
import 'logger.dart';

class ResponsiveHelper {
  static const double mobileSmall = 320;
  static const double mobile = 375;
  static const double mobileLarge = 414;
  static const double tablet = 768;
  static const double tabletLarge = 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < tablet;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= tablet;

  static bool isSmallPhone(BuildContext context) =>
      screenWidth(context) <= mobileSmall;

  static double horizontalPadding(BuildContext context) {
    if (isTablet(context)) return screenWidth(context) * 0.08;
    if (screenWidth(context) >= mobileLarge) return 20.0;
    return 16.0;
  }

  static double cardPadding(BuildContext context) {
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  static double fontSize(BuildContext context, double base) {
    if (isSmallPhone(context)) return base * 0.9;
    if (isTablet(context)) return base * 1.1;
    return base;
  }

  static double buttonHeight(BuildContext context) {
    if (isTablet(context)) return 56.0;
    if (isSmallPhone(context)) return 48.0;
    return 52.0;
  }

  static double iconSize(BuildContext context, double base) {
    if (isTablet(context)) return base * 1.2;
    return base;
  }

  static int gridCrossAxisCount(BuildContext context) {
    if (isTablet(context)) return 3;
    if (screenWidth(context) >= mobileLarge) return 2;
    return 2;
  }

  static double maxContentWidth(BuildContext context) {
    if (isTablet(context)) return 680.0;
    return double.infinity;
  }

  static double spacingBetweenSections(BuildContext context) =>
      isTablet(context) ? 24.0 : 16.0;

  static double spacingBetweenFields(BuildContext context) =>
      isTablet(context) ? 16.0 : 12.0;

  static bool isLandscape(BuildContext context) =>
      screenWidth(context) > screenHeight(context);

  static void logScreenInfo(BuildContext context) {
    AppLogger.debug('ResponsiveHelper',
        'Screen: ${screenWidth(context)}x${screenHeight(context)} '
        'Type: ${isTablet(context) ? 'Tablet' : 'Mobile'}');
  }
}
