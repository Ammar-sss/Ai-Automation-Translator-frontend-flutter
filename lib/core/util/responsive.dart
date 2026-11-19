import 'package:material_ui/material_ui.dart';

/// Extension on BuildContext for clean, unified responsive layout throughout the app.
extension ResponsiveContext on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  Orientation get orientation => mediaQuery.orientation;

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isTablet => screenWidth >= 600;
  bool get isMobile => screenWidth < 600;

  /// Percent of screen width (e.g., `context.wp(10)` = 10% of width)
  double wp(double percent) => screenWidth * (percent / 100);

  /// Percent of screen height (e.g., `context.hp(5)` = 5% of height)
  double hp(double percent) => screenHeight * (percent / 100);

  /// Responsive padding
  EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: wp(isTablet ? 6 : 4),
    vertical: hp(isTablet ? 2.5 : 1.5),
  );

  /// Scales font size cleanly between a min and max bound
  double sp(double size, {double min = 10, double max = 32}) {
    final scale =
        screenWidth / 390.0; // standard mobile baseline (iPhone 12/13/14)
    return (size * scale).clamp(min, max);
  }

  /// Responsive card / container radius
  double get defaultRadius => (screenWidth * 0.04).clamp(12.0, 24.0);
}
