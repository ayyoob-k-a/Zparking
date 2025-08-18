import 'package:flutter/material.dart';

class NavigationUtils {
  NavigationUtils._();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T extends Object?>(String route, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(route, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(String route, {TO? result, Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(route, result: result, arguments: arguments);
  }

  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String newRouteName, RoutePredicate predicate, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(newRouteName, predicate, arguments: arguments);
  }
}


