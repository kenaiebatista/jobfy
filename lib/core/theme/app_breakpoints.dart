import 'package:flutter/widgets.dart';

/// Device class of the current viewport, derived from its width.
enum DeviceType { mobile, tablet, laptop, desktop }

/// Shared width breakpoints used to adapt pages to mobile, tablet, laptop
/// and desktop screens.
///
/// Each value is the minimum width (in logical pixels) at which that device
/// class starts, so a width of 900 is already a laptop.
class AppBreakpoints {
  AppBreakpoints._();

  /// Minimum width of a tablet.
  static const double tablet = 600;

  /// Minimum width of a laptop.
  static const double laptop = 900;

  /// Minimum width of a desktop monitor.
  static const double desktop = 1200;

  /// Below this width a page should use its mobile layout (drawer
  /// navigation, single-column content). Covers phones and tablets.
  static const double mobile = laptop;

  /// Maps a viewport [width] to its [DeviceType].
  static DeviceType deviceTypeFor(double width) {
    if (width >= desktop) return DeviceType.desktop;
    if (width >= laptop) return DeviceType.laptop;
    if (width >= tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

/// Screen-size shorthands, in the same spirit as `context.colors`:
/// `context.isMobile` instead of comparing `MediaQuery` widths by hand.
///
/// They read [MediaQuery.sizeOf], so widgets only rebuild when the size
/// changes, not on every other media query change (e.g. keyboard insets).
extension BuildContextBreakpointsX on BuildContext {
  DeviceType get deviceType =>
      AppBreakpoints.deviceTypeFor(MediaQuery.sizeOf(this).width);

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isLaptop => deviceType == DeviceType.laptop;
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// True on phones and tablets, i.e. below [AppBreakpoints.mobile]:
  /// the layout where the sidebar becomes a drawer.
  bool get isCompactLayout =>
      MediaQuery.sizeOf(this).width < AppBreakpoints.mobile;

  /// Picks the value for the current [DeviceType]. Only [mobile] is
  /// required; each larger size falls back to the next smaller one given
  /// (desktop -> laptop -> tablet -> mobile), so `responsive(mobile: 16,
  /// laptop: 28)` yields 16 on phones/tablets and 28 on laptops/desktops.
  ///
  /// Use it for any dimension that should change with the device: font
  /// sizes, paddings, gaps, column counts.
  T responsive<T>({required T mobile, T? tablet, T? laptop, T? desktop}) {
    return switch (deviceType) {
      DeviceType.desktop => desktop ?? laptop ?? tablet ?? mobile,
      DeviceType.laptop => laptop ?? tablet ?? mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.mobile => mobile,
    };
  }

  /// Horizontal/vertical page gutter that grows with the screen.
  double get pagePadding =>
      responsive(mobile: 16.0, tablet: 24.0, laptop: 28.0, desktop: 32.0);
}

/// Centers [child] with a maximum width and the device-appropriate page
/// gutter, so content stays comfortable on wide monitors and uses the full
/// width (minus gutter) on phones.
///
/// Meant to be placed inside a scroll view (its height is the child's).
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  final Widget child;
  final double maxWidth;

  /// Overrides the default [BuildContextBreakpointsX.pagePadding] gutter.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.all(context.pagePadding),
          child: child,
        ),
      ),
    );
  }
}

/// Builds a different widget per [DeviceType].
///
/// Only [mobile] is required; every larger size falls back to the next
/// smaller one that was provided (desktop -> laptop -> tablet -> mobile).
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.laptop,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? laptop;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final builder = context.responsive<WidgetBuilder>(
      mobile: mobile,
      tablet: tablet,
      laptop: laptop,
      desktop: desktop,
    );
    return builder(context);
  }
}
