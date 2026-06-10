import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// No desktop, o sqflite usa FFI em vez do plugin nativo mobile.
Future<void> initializeDatabase() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
