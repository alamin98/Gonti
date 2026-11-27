import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/format.dart';
import '../core/period.dart';
import '../data/db.dart';
import '../data/models.dart';
import '../data/repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repo, this.prefs) {
    bangla = prefs.getBool('bangla') ?? true;
    useBangla = bangla;
    monthStartDay = prefs.getInt('month_start_day') ?? 1;
    budgetPaisa = prefs.getInt('budget_paisa') ?? 0;
    onboarded = prefs.getBool('onboarded') ?? false;
    period = periodFor(DateTime.now(), monthStartDay);
  }

  final Repo repo;
  final SharedPreferences prefs;

  bool bangla = true;
  bool onboarded = false;
  int monthStartDay = 1;
  int budgetPaisa = 0; // প্রতি মাসে একই বাজেট (মাস বদলালে খরচ নতুন করে গোনা হয়)
  int monthOffset = 0; // 0 = চলতি মাস, -1 = আগের মাস
  int tab = 0;

  late Period period;
  Totals totals = Totals.zero;
  List<Tx> periodTx = [];
  List<Tx> recent = [];
  int dena = 0;
  int pawna = 0;

  static Future<AppState> create() async {
    final db = await AppDb.open();
    final prefs = await SharedPreferences.getInstance();
    final s = AppState(Repo(db), prefs);
    await s.refresh();
    return s;
  }

  Future<void> refresh() async {
    period = periodFor(DateTime.now(), monthStartDay, offset: monthOffset);
    totals = await repo.totals(period.start, period.end);
    periodTx = await repo.txBetween(period.start, period.end);
    recent = await repo.recent(5);
    dena = await repo.debtOutstanding('dena');
    pawna = await repo.debtOutstanding('pawna');
    notifyListeners();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  Future<void> shiftMonth(int delta) async {
    if (monthOffset + delta > 0) return; // ভবিষ্যতের মাসে যাওয়া যাবে না
    monthOffset += delta;
    await refresh();
  }

  Future<void> setLanguage(bool bn) async {
    bangla = bn;
    useBangla = bn;
    await prefs.setBool('bangla', bn);
    notifyListeners();
  }

  Future<void> setMonthStartDay(int day) async {
    monthStartDay = day;
    monthOffset = 0;
    await prefs.setInt('month_start_day', day);
    await refresh();
  }

  Future<void> setBudget(int paisa) async {
    budgetPaisa = paisa;
    await prefs.setInt('budget_paisa', paisa);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await prefs.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> addTransaction({
    required TxType type,
    required int amountPaisa,
    required int categoryId,
    required DateTime date,
    String note = '',
  }) async {
    await repo.addTx(type: type, amountPaisa: amountPaisa, categoryId: categoryId, date: date, note: note);
    await refresh();
  }

  Future<void> deleteTransaction(int id) async {
    await repo.deleteTx(id);
    await refresh();
  }

  /// বাজেট ব্যবহারের হার (০.০ – ১.০+)। বাজেট ঠিক করা না থাকলে 0।
  double get budgetRatio => budgetPaisa <= 0 ? 0 : totals.budgetUsed / budgetPaisa;
}
