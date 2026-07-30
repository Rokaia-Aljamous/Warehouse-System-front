import 'package:flutter/material.dart';

/// Navigation helpers that gracefully handle the "back" gesture/button.
///
/// Problem this solves:
///   The app uses [Navigator.pushReplacement] for bottom-tab navigation
///   and [Navigator.pushAndRemoveUntil] after login. As a result, the
///   navigation stack often contains only one route. Calling
///   [Navigator.pop] in that state closes the app on Android.
///
/// Solution:
///   Use [safePop] instead of [Navigator.pop] for any back affordance
///   triggered by the user (back arrow, "Go Back" button, etc.). If the
///   current route is the only route on the stack, [safePop] is a no-op
///   rather than closing the app.
class NavUtils {
  NavUtils._();

  /// Pops the current route ONLY if there's a previous route to go back to.
  ///
  /// Returns `true` if the route was popped, `false` otherwise (no-op).
  static bool safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  /// Pops the current route if possible, otherwise navigates to [fallback].
  ///
  /// Use this on root tab screens where pressing back should keep the user
  /// in the app (e.g. go to Home) rather than exit.
  static void popOrFallback(BuildContext context, Widget fallback) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => fallback),
      );
    }
  }
}
