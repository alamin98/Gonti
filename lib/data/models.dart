import '../core/format.dart';

enum TxType { income, expense }

TxType txTypeFrom(String s) => s == 'income' ? TxType.income : TxType.expense;

int _i(Object? v) => (v as num?)?.toInt() ?? 0;

class Category {
  const Category({required this.id, required this.name, this.nameEn, required this.type, required this.inBudget, this.systemKey});
  final int id;
  final String name;
  final String? nameEn;
  final TxType type;
  final bool inBudget;
  final String? systemKey;

  bool get isSystem => systemKey != null;
  String get label => (!useBangla && nameEn != null && nameEn!.isNotEmpty) ? nameEn! : name;

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: _i(m['id']),
        name: m['name'] as String,
        nameEn: m['name_en'] as String?,
        type: txTypeFrom(m['type'] as String),
        inBudget: _i(m['in_budget']) == 1,
        systemKey: m['system_key'] as String?,
      );
}

class Tx {
  const Tx({
    required this.id,
    required this.type,
    required this.amountPaisa,
    required this.categoryId,
    required this.categoryName,
    this.categoryNameEn,
    required this.note,
    required this.date,
    required this.source,
  });
  final int id;
  final TxType type;
  final int amountPaisa;
  final int categoryId;
  final String categoryName;
  final String? categoryNameEn;
  final String note;
  final DateTime date;
  final String source; // manual | dena | pawna | dps

  bool get isIncome => type == TxType.income;
  bool get isManual => source == 'manual';
  String get categoryLabel => (!useBangla && categoryNameEn != null && categoryNameEn!.isNotEmpty) ? categoryNameEn! : categoryName;

  factory Tx.fromMap(Map<String, Object?> m) => Tx(
        id: _i(m['id']),
        type: txTypeFrom(m['type'] as String),
        amountPaisa: _i(m['amount_paisa']),
        categoryId: _i(m['category_id']),
        categoryName: m['cat_name'] as String,
        categoryNameEn: m['cat_name_en'] as String?,
        note: (m['note'] as String?) ?? '',
        date: parseKey(m['date'] as String),
        source: (m['source'] as String?) ?? 'manual',
      );
}

class Totals {
  const Totals({this.income = 0, this.expense = 0, this.budgetUsed = 0});
  final int income;
  final int expense;
  final int budgetUsed; // শুধু "বাজেটে ধরা হবে" ক্যাটাগরির খরচ
  int get balance => income - expense;
  static const zero = Totals();
}
