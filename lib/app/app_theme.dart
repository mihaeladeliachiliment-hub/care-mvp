import 'package:flutter/material.dart';

/// Temele aplicației CARE.
///
/// Aplicația urmează automat setarea telefonului: tema luminoasă ziua,
/// tema întunecată când utilizatorul a activat modul întunecat.
class AppTheme {
  const AppTheme._();

  static const Color seedColor = Colors.teal;

  static final ThemeData light = ThemeData(
    colorSchemeSeed: seedColor,
    brightness: Brightness.light,
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    colorSchemeSeed: seedColor,
    brightness: Brightness.dark,
    useMaterial3: true,
  );
}
