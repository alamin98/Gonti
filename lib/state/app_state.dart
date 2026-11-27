import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/format.dart';
import '../core/period.dart';
import '../data/cloud.dart';
import '../data/db.dart';
import '../data/models.dart';
import '../data/repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repo, this.prefs) {
    // English এখন বন্ধ (ডিজাইনে অপশন আছে, পরের ধাপে চালু হবে)
    bangla = true;
    useBangla = true;
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

  // ---------- লগইন + ক্লাউড ব্যাকআপ
  bool get signedIn => Cloud.user != null;
  String? get userName => Cloud.user?.displayName;
  String? get userEmail => Cloud.user?.email;
  DateTime? lastBackup;
  bool syncing = false;
  Timer? _backupTimer;

  /// লগইন সফল হলে true। ক্লাউডে আগের ব্যাকআপ থাকলে lastBackup সেট হয়।
  Future<bool> signIn() async {
    final u = await Cloud.signIn();
    if (u == null) return false;
    lastBackup = await Cloud.lastBackup();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _backupTimer?.cancel();
    await Cloud.signOut();
    lastBackup = null;
    notifyListeners();
  }

  Future<bool> hasLocalData() async =>
      ((await repo.db.rawQuery('SELECT COUNT(*) AS n FROM transactions')).first['n'] as num) > 0;

  Future<void> backupNow() async {
    if (!signedIn) return;
    _backupTimer?.cancel();
    syncing = true;
    notifyListeners();
    try {
      lastBackup = await Cloud.backup(repo.db, {'month_start_day': monthStartDay, 'budget_paisa': budgetPaisa});
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  /// হিসাব বদলালে কয়েক সেকেন্ড পর নিজে থেকেই ব্যাকআপ (লগইন থাকলে)
  void _scheduleBackup() {
    if (!signedIn) return;
    _backupTimer?.cancel();
    _backupTimer = Timer(const Duration(seconds: 4), () => backupNow().catchError((_) {}));
  }

  Future<void> restoreFromCloud() async {
    syncing = true;
    notifyListeners();
    try {
      final p = await Cloud.restore(repo.db);
      if (p['month_start_day'] is num) {
        monthStartDay = (p['month_start_day'] as num).toInt();
        await prefs.setInt('month_start_day', monthStartDay);
      }
      if (p['budget_paisa'] is num) {
        budgetPaisa = (p['budget_paisa'] as num).toInt();
        await prefs.setInt('budget_paisa', budgetPaisa);
      }
      monthOffset = 0;
      lastBackup = await Cloud.lastBackup();
      await refresh();
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  static Future<AppState> create() async {
    await Cloud.init();
    final db = await AppDb.open();
    final prefs = await SharedPreferences.getInstance();
    final s = AppState(Repo(db), prefs);
    await s.refresh();
    if (s.signedIn) {
      Cloud.lastBackup().then((d) {
        s.lastBackup = d;
        s.notifyListeners();
      }).catchError((_) {});
    }
    return s;
  }

  Future<void> refresh() async {
    period = periodFor(DateTime.now(), monthStartDay, offset: monthOffset);
    totals = await repo.totals(period.start, period.end);
    periodTx = await repo.txBetween(period.start, period.end);
    recent = await repo.txBetween(period.start, period.end, limit: 5);
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

  /// English এখনো চালু হয়নি → false দিলে কিছু বদলায় না, false ফেরত দেয়।
  static const englishReady = false;
  Future<bool> setLanguage(bool bn) async {
    if (!bn && !englishReady) return false;
    bangla = bn;
    useBangla = bn;
    await prefs.setBool('bangla', bn);
    notifyListeners();
    return true;
  }

  Future<void> setMonthStartDay(int day) async {
    monthStartDay = day;
    monthOffset = 0;
    await prefs.setInt('month_start_day', day);
    await refresh();
    _scheduleBackup();
  }

  Future<void> setBudget(int paisa) async {
    budgetPaisa = paisa;
    await prefs.setInt('budget_paisa', paisa);
    notifyListeners();
    _scheduleBackup();
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
    _scheduleBackup();
  }

  Future<void> updateTransaction({
    required int id,
    required TxType type,
    required int amountPaisa,
    required int categoryId,
    required DateTime date,
    String note = '',
  }) async {
    await repo.updateTx(id: id, type: type, amountPaisa: amountPaisa, categoryId: categoryId, date: date, note: note);
    await refresh();
    _scheduleBackup();
  }

  Future<void> deleteTransaction(int id) async {
    await repo.deleteTx(id);
    await refresh();
    _scheduleBackup();
  }

  /// বাজেট ব্যবহারের হার (০.০ – ১.০+)। বাজেট ঠিক করা না থাকলে 0।
  double get budgetRatio => budgetPaisa <= 0 ? 0 : totals.budgetUsed / budgetPaisa;
}
