import 'package:sqflite/sqflite.dart';
import '../core/format.dart';
import 'models.dart';

class Repo {
  Repo(this.db);
  final Database db;

  // ---------- ক্যাটাগরি
  Future<List<Category>> categories(TxType type, {bool includeSystem = false}) async {
    final rows = await db.query(
      'categories',
      where: includeSystem ? 'type = ?' : 'type = ? AND system_key IS NULL',
      whereArgs: [type.name],
      orderBy: 'sort ASC, id ASC',
    );
    return rows.map(Category.fromMap).toList();
  }

  /// একই নামের ক্যাটাগরি থাকলে নতুন বানায় না, আগেরটার id ফেরত দেয়।
  Future<int> addCategory(String name, TxType type, {required bool inBudget}) async {
    final clean = name.trim();
    final dup = await db.query('categories',
        where: 'LOWER(name) = LOWER(?) AND type = ?', whereArgs: [clean, type.name], limit: 1);
    if (dup.isNotEmpty) return (dup.first['id'] as num).toInt();
    final maxSort = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COALESCE(MAX(sort), 0) FROM categories WHERE type = ?', [type.name])) ??
        0;
    return db.insert('categories', {
      'name': clean,
      'type': type.name,
      'in_budget': inBudget ? 1 : 0,
      'sort': maxSort + 1,
      'is_default': 0,
    });
  }

  Future<void> setInBudget(int categoryId, bool value) =>
      db.update('categories', {'in_budget': value ? 1 : 0}, where: 'id = ?', whereArgs: [categoryId]);

  // ---------- লেনদেন
  Future<int> addTx({
    required TxType type,
    required int amountPaisa,
    required int categoryId,
    required DateTime date,
    String note = '',
    String source = 'manual',
    int? sourceId,
  }) =>
      db.insert('transactions', {
        'type': type.name,
        'amount_paisa': amountPaisa,
        'category_id': categoryId,
        'note': note.trim(),
        'date': dateKey(date),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'source': source,
        'source_id': sourceId,
      });

  /// শুধু manual লেনদেন বদলানো যায় (দেনা/পাওনা/ডিপিএস থেকে আসা গুলো মডিউল থেকে বদলাবে)
  Future<void> updateTx({
    required int id,
    required TxType type,
    required int amountPaisa,
    required int categoryId,
    required DateTime date,
    String note = '',
  }) =>
      db.update(
        'transactions',
        {'type': type.name, 'amount_paisa': amountPaisa, 'category_id': categoryId, 'note': note.trim(), 'date': dateKey(date)},
        where: "id = ? AND source = 'manual'",
        whereArgs: [id],
      );

  Future<void> deleteTx(int id) => db.delete('transactions', where: 'id = ?', whereArgs: [id]);

  static const _txSelect = '''
    SELECT t.*, c.name AS cat_name, c.name_en AS cat_name_en
    FROM transactions t JOIN categories c ON c.id = t.category_id''';

  Future<List<Tx>> txBetween(DateTime from, DateTime to, {int? limit}) async {
    final rows = await db.rawQuery(
      '$_txSelect WHERE t.date BETWEEN ? AND ? ORDER BY t.date DESC, t.id DESC${limit != null ? ' LIMIT $limit' : ''}',
      [dateKey(from), dateKey(to)],
    );
    return rows.map(Tx.fromMap).toList();
  }

  Future<List<Tx>> recent(int n) async {
    final rows = await db.rawQuery('$_txSelect ORDER BY t.date DESC, t.id DESC LIMIT $n');
    return rows.map(Tx.fromMap).toList();
  }

  Future<Totals> totals(DateTime from, DateTime to) async {
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount_paisa END), 0) AS inc,
        COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount_paisa END), 0) AS exp,
        COALESCE(SUM(CASE WHEN t.type = 'expense' AND c.in_budget = 1 THEN t.amount_paisa END), 0) AS bud
      FROM transactions t JOIN categories c ON c.id = t.category_id
      WHERE t.date BETWEEN ? AND ?''', [dateKey(from), dateKey(to)]);
    final r = rows.first;
    return Totals(
      income: (r['inc'] as num).toInt(),
      expense: (r['exp'] as num).toInt(),
      budgetUsed: (r['bud'] as num).toInt(),
    );
  }

  // ---------- দেনা / পাওনা (বাকি) — মডিউল তৈরি হলে এটাই ব্যবহার হবে
  Future<int> debtOutstanding(String kind) async {
    final rows = await db.rawQuery('''
      SELECT
        COALESCE((SELECT SUM(total_paisa) FROM debts WHERE kind = ?), 0) -
        COALESCE((SELECT SUM(p.amount_paisa) FROM debt_payments p JOIN debts d ON d.id = p.debt_id WHERE d.kind = ?), 0) AS v
    ''', [kind, kind]);
    return (rows.first['v'] as num).toInt();
  }
}
