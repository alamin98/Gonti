import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

/// browser এ SQLite (WebAssembly) — হিসাব browser এর ভেতরেই জমা থাকে (IndexedDB)।
void setupDbFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
