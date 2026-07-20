import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFontScale {
  AppFontScale._();

  static const String _storageKey = 'tallyjie_font_scale';
  static const List<double> steps = [0.72, 0.82, 0.9, 1.0];
  static const List<String> stepLabels = ['超小', '小', '默认', '大'];
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static double current = 0.9;

  static int get selectedIndex {
    var nearest = 0;
    var distance = (steps.first - current).abs();
    for (var i = 1; i < steps.length; i++) {
      final nextDistance = (steps[i] - current).abs();
      if (nextDistance < distance) {
        nearest = i;
        distance = nextDistance;
      }
    }
    return nearest;
  }

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_storageKey);
    if (saved == null) return;
    apply(saved, persist: false);
  }

  static void apply(double value, {bool persist = true}) {
    current = _nearestStep(value);
    version.value++;
    if (persist) {
      unawaited(_save(current));
    }
  }

  static String label(double value) {
    return stepLabels[_nearestIndex(value)];
  }

  static int _nearestIndex(double value) {
    var nearest = 0;
    var distance = (steps.first - value).abs();
    for (var i = 1; i < steps.length; i++) {
      final nextDistance = (steps[i] - value).abs();
      if (nextDistance < distance) {
        nearest = i;
        distance = nextDistance;
      }
    }
    return nearest;
  }

  static double _nearestStep(double value) {
    var result = steps.first;
    var distance = (value - result).abs();
    for (final step in steps.skip(1)) {
      final nextDistance = (value - step).abs();
      if (nextDistance < distance) {
        result = step;
        distance = nextDistance;
      }
    }
    return result;
  }

  static Future<void> _save(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_storageKey, value);
  }
}
