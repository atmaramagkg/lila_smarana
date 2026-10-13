import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'services/app_settings.dart';
import 'services/translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On desktop (Windows/Linux/macOS) sqflite has no native implementation;
  // route the database through the FFI factory backed by sqlite3.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await AppSettings.load();
  // Open the single unified database.
  await AppDatabase.instance.init();
  await Translations.load();

  runApp(
    const LilaSmaranaApp(),
  );
}
