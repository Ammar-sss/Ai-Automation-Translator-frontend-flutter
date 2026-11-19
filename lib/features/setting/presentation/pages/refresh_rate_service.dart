import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RefreshRate {
  hz60('60 Hz'),
  hz120('120 Hz');

  final String label;
  const RefreshRate(this.label);

  static RefreshRate fromLabel(String label) => RefreshRate.values.firstWhere(
    (r) => r.label == label,
    orElse: () => RefreshRate.hz120,
  );
}

/// Detects whether the device can run above 60 Hz and applies the user's choice.
class RefreshRateService {
  RefreshRateService._();

  static const _prefsKey = 'refresh_rate';

  static bool supportsHigh = true;

  static RefreshRate current = RefreshRate.hz120;

  /// Call once before runApp (after WidgetsFlutterBinding.ensureInitialized).
  static Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) {
      supportsHigh = false;
      return;
    }

    try {
      final modes = await FlutterDisplayMode.supported;
      supportsHigh = modes.any((m) => m.refreshRate > 60) || modes.isEmpty;
    } catch (_) {
      supportsHigh = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && saved.isNotEmpty) {
        current = RefreshRate.fromLabel(saved);
      }
      await _apply(current);
    } catch (_) {}
  }

  /// Applies and saves the user's choice.
  static Future<void> set(RefreshRate rate) async {
    current = rate;
    await _apply(rate);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, rate.label);
    } catch (_) {}
  }

  static Future<void> _apply(RefreshRate rate) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final modes = await FlutterDisplayMode.supported;
      if (modes.isEmpty) {
        if (rate == RefreshRate.hz120) {
          await FlutterDisplayMode.setHighRefreshRate();
        } else {
          await FlutterDisplayMode.setLowRefreshRate();
        }
        return;
      }

      if (rate == RefreshRate.hz120) {
        DisplayMode? highestMode;
        for (final m in modes) {
          if (highestMode == null || m.refreshRate > highestMode.refreshRate) {
            highestMode = m;
          }
        }
        if (highestMode != null && highestMode.refreshRate > 60) {
          await FlutterDisplayMode.setPreferredMode(highestMode);
        } else {
          await FlutterDisplayMode.setHighRefreshRate();
        }
      } else {
        DisplayMode? mode60;
        for (final m in modes) {
          if (mode60 == null ||
              (m.refreshRate - 60).abs() < (mode60.refreshRate - 60).abs()) {
            mode60 = m;
          }
        }
        if (mode60 != null) {
          await FlutterDisplayMode.setPreferredMode(mode60);
        } else {
          await FlutterDisplayMode.setLowRefreshRate();
        }
      }
    } catch (_) {
      try {
        if (rate == RefreshRate.hz120) {
          await FlutterDisplayMode.setHighRefreshRate();
        } else {
          await FlutterDisplayMode.setLowRefreshRate();
        }
      } catch (_) {}
    }
  }
}
