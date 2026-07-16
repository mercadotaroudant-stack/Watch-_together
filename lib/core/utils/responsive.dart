import 'package:flutter/widgets.dart';

/// Screen-size breakpoints, in logical pixels of width.
///
/// These follow common Material guidance (compact / medium / expanded)
/// relabeled to match how the product spec talks about devices: small
/// phones, large phones, and tablets.
enum DeviceType { smallPhone, largePhone, tablet }

abstract final class Breakpoints {
  static const double smallPhoneMax = 360;
  static const double largePhoneMax = 600;
  // Anything >= largePhoneMax is treated as a tablet.
}

/// Lightweight, dependency-free responsive helpers.
///
/// A custom implementation was chosen over a package like
/// `flutter_screenutil` to avoid pulling in a dependency for what is a
/// straightforward `MediaQuery` calculation, per the "no unnecessary
/// packages" requirement.
extension ResponsiveContext on BuildContext {
  Size get _screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;

  DeviceType get deviceType {
    final double width = screenWidth;
    if (width < Breakpoints.smallPhoneMax) return DeviceType.smallPhone;
    if (width < Breakpoints.largePhoneMax) return DeviceType.largePhone;
    return DeviceType.tablet;
  }

  bool get isSmallPhone => deviceType == DeviceType.smallPhone;
  bool get isLargePhone => deviceType == DeviceType.largePhone;
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Picks a value based on the current [DeviceType], falling back to the
  /// closest smaller breakpoint's value when a larger one isn't provided.
  ///
  /// Example:
  /// ```dart
  /// final columns = context.responsiveValue(
  ///   smallPhone: 1,
  ///   largePhone: 2,
  ///   tablet: 4,
  /// );
  /// ```
  T responsiveValue<T>({
    required T smallPhone,
    T? largePhone,
    T? tablet,
  }) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return smallPhone;
      case DeviceType.largePhone:
        return largePhone ?? smallPhone;
      case DeviceType.tablet:
        return tablet ?? largePhone ?? smallPhone;
    }
  }

  /// Clamps horizontal content width on very wide screens (tablets), so
  /// text/forms don't stretch edge-to-edge.
  double get maxContentWidth => isTablet ? 640 : double.infinity;
}
