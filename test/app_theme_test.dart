import 'package:care/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('tema luminoasă are fundal deschis', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
    });

    test('tema întunecată are fundal închis', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    });

    test('ambele teme folosesc Material 3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.dark.useMaterial3, isTrue);
    });

    test('textul are culori diferite în cele două teme', () {
      expect(
        AppTheme.light.colorScheme.onSurface,
        isNot(AppTheme.dark.colorScheme.onSurface),
      );
    });
  });
}
