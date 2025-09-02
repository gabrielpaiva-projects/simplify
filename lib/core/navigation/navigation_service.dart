import 'package:flutter/material.dart';

import '../routes/route_arguments.dart';

/// Navigation service for handling navigation without context
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();

  /// Get current navigation context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(
    String routeName, {
    RouteArguments? arguments,
  }) async {
    return await navigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace current
  static Future<T?> navigateAndReplace<T>(
    String routeName, {
    RouteArguments? arguments,
  }) async {
    return await navigatorKey.currentState?.pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(
    String routeName, {
    RouteArguments? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return await navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void goBack<T>([T? result]) {
    if (canGoBack()) {
      navigatorKey.currentState?.pop(result);
    }
  }

  /// Check if can go back
  static bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(
      (route) => route.settings.name == routeName,
    );
  }

  /// Show dialog
  static Future<T?> showDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    return await showGeneralDialog<T>(
      context: currentContext!,
      pageBuilder: (context, animation, secondaryAnimation) => dialog,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(currentContext!)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required Widget sheet,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
  }) async {
    return await showModalBottomSheet<T>(
      context: currentContext!,
      builder: (context) => sheet,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}