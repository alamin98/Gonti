import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite ডাটাবেস। টাকা সবসময় পয়সায় (int) রাখা হয় যাতে দশমিক ভুল না হয়।
/// সব মডিউলের টেবিল শুরুতেই আছে, তাই পরে নতুন মডিউল যোগ করতে migration লাগবে না।
class AppDb {
  AppDb._();
  static Database? _db;

  static Future<Database> open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'gonti.db'),
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
    );
    return _db!;
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_en TEXT,
        type TEXT NOT NULL,            -- income | expense
        in_budget INTEGER NOT NULL DEFAULT 0,
        system_key TEXT UNIQUE,        -- dps, dena_payment, pawna_given, dena_taken, pawna_received
        sort INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,            -- income | expense
        amount_paisa INTEGER NOT NULL,
        category_id INTEGER NOT NULL REFERENCES categories(id),
        note TEXT,
        date TEXT NOT NULL,            -- yyyy-MM-dd
        created_at INTEGER NOT NULL,
        source TEXT NOT NULL DEFAULT 'manual',  -- manual | dena | pawna | dps
        source_id INTEGER
      )''');
    await db.execute('CREATE INDEX idx_tx_date ON transactions(date)');
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT NOT NULL,            -- dena | pawna
        person TEXT NOT NULL,
        purpose TEXT,
        total_paisa INTEGER NOT NULL,
        date TEXT NOT NULL,
        due_date TEXT,
        interest_rate REAL,
        created_at INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE debt_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL REFERENCES debts(id) ON DELETE CASCADE,
        amount_paisa INTEGER NOT NULL,
        date TEXT NOT NULL,
        transaction_id INTEGER REFERENCES transactions(id) ON DELETE SET NULL
      )''');
    await db.execute('''
      CREATE TABLE dps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        installment_paisa INTEGER NOT NULL,
        frequency TEXT NOT NULL,       -- weekly | monthly | yearly
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE dps_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dps_id INTEGER NOT NULL REFERENCES dps(id) ON DELETE CASCADE,
        amount_paisa INTEGER NOT NULL,
        date TEXT NOT NULL,
        transaction_id INTEGER REFERENCES transactions(id) ON DELETE SET NULL
      )''');
    await db.execute('''
      CREATE TABLE budget_limits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL UNIQUE REFERENCES categories(id) ON DELETE CASCADE,
        limit_paisa INTEGER NOT NULL
      )''');
    await _seed(db);
  }

  static Future<void> _seed(Database db) async {
    // (বাংলা, English, type, বাজেটে ধরা, system_key)
    const rows = <List<Object?>>[
      ['বাজার', 'Groceries', 'expense', 1, null],
      ['বাসা ভাড়া', 'Rent', 'expense', 1, null],
      ['যাতায়াত', 'Transport', 'expense', 1, null],
      ['বিল', 'Bills', 'expense', 1, null],
      ['চিকিৎসা', 'Health', 'expense', 1, null],
      ['শিক্ষা', 'Education', 'expense', 1, null],
      ['অন্যান্য', 'Other', 'expense', 1, null],
      ['ডিপিএস', 'DPS', 'expense', 0, 'dps'],
      ['দেনা শোধ', 'Debt repaid', 'expense', 0, 'dena_payment'],
      ['ধার দিলাম', 'Lent', 'expense', 0, 'pawna_given'],
      ['বেতন', 'Salary', 'income', 0, null],
      ['ব্যবসা', 'Business', 'income', 0, null],
      ['বোনাস', 'Bonus', 'income', 0, null],
      ['ফ্রিল্যান্সিং', 'Freelancing', 'income', 0, null],
      ['উপহার', 'Gift', 'income', 0, null],
      ['অন্যান্য', 'Other', 'income', 0, null],
      ['ধার নিলাম', 'Borrowed', 'income', 0, 'dena_taken'],
      ['পাওনা ফেরত', 'Repaid to me', 'income', 0, 'pawna_received'],
    ];
    var i = 0;
    for (final r in rows) {
      await db.insert('categories', {
        'name': r[0],
        'name_en': r[1],
        'type': r[2],
        'in_budget': r[3],
        'system_key': r[4],
        'sort': i++,
        'is_default': 1,
      });
    }
  }
}
