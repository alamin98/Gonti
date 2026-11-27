import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../dialogs.dart';
import '../widgets.dart';
import 'quick_add.dart';

class LendenScreen extends StatefulWidget {
  const LendenScreen({super.key});

  @override
  State<LendenScreen> createState() => _LendenScreenState();
}

class _LendenScreenState extends State<LendenScreen> {
  int _filter = 0; // 0 সব, 1 আয়, 2 খরচ

  Future<bool> _confirmDelete() async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: dialogShape,
        title: Text(t('delete_title'), style: Ty.s(18, FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'), style: Ty.s(15, FontWeight.w600, color: C.ink600))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('delete'), style: Ty.s(15, FontWeight.w600, color: C.expense))),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.periodTx.where((x) => _filter == 0 || (_filter == 1 ? x.isIncome : !x.isIncome)).toList();

    // তারিখ অনুযায়ী গ্রুপ (তালিকা আগে থেকেই নতুন → পুরনো সাজানো)
    final groups = <DateTime, List<Tx>>{};
    for (final x in list) {
      groups.putIfAbsent(x.date, () => []).add(x);
    }

    final sub = s.monthOffset == 0 ? t('this_month') : (s.monthOffset == -1 ? t('prev_month') : null);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
        children: [
          Text(t('tab_lenden'), style: Ty.s(28, FontWeight.w700)),
          const SizedBox(height: 12),
          MonthBar(label: periodLabel(s.period), sub: sub, canNext: s.monthOffset < 0, onPrev: () => s.shiftMonth(-1), onNext: () => s.shiftMonth(1)),
          const SizedBox(height: 10),
          AppCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('income'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
                  Text(taka(s.totals.income), style: Ty.s(18, FontWeight.w700, color: C.income)),
                ]),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('expense'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
                  Text(taka(s.totals.expense), style: Ty.s(18, FontWeight.w700, color: C.expense)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            AppChip(label: t('all'), selected: _filter == 0, onTap: () => setState(() => _filter = 0)),
            AppChip(label: t('income'), selected: _filter == 1, onTap: () => setState(() => _filter = 1)),
            AppChip(label: t('expense'), selected: _filter == 2, onTap: () => setState(() => _filter = 2)),
          ]),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(t('empty_tx'), textAlign: TextAlign.center, style: Ty.s(14, FontWeight.w400, color: C.textTertiary)),
            ),
          for (final e in groups.entries) ...[
            _DayHeader(date: e.key, items: e.value),
            const SizedBox(height: 6),
            AppCard(
              child: Column(children: [
                for (var i = 0; i < e.value.length; i++)
                  _row(e.value[i], i == e.value.length - 1, s),
              ]),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _row(Tx tx, bool last, AppState s) {
    // চাপ দিলে বদলানো/মোছার স্ক্রিন খোলে
    final row = TxRow(tx: tx, last: last, onTap: () => openTxEditor(context, tx));
    if (!tx.isManual) {
      // দেনা/পাওনা/ডিপিএস থেকে আসা লেনদেন এখানে মোছা যাবে না (ডাবল গোনা ঠেকাতে)
      return row;
    }
    return Dismissible(
      key: ValueKey('tx-${tx.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) {
        s.deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('deleted'))));
      },
      background: Container(
        color: C.red100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: C.expense),
      ),
      child: Container(color: C.surface, child: row),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.items});
  final DateTime date;
  final List<Tx> items;

  @override
  Widget build(BuildContext context) {
    var net = 0;
    for (final x in items) {
      net += x.isIncome ? x.amountPaisa : -x.amountPaisa;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final special = sameDay(date, today) || sameDay(date, DateTime(today.year, today.month, today.day - 1));
    final title = special ? '${dayLabel(date)} · ${dayMonth(date)}' : dayMonth(date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: Ty.s(13, FontWeight.w600, color: C.ink600)),
        Text('${net >= 0 ? '+' : '−'}${taka(net.abs())}', style: Ty.s(13, FontWeight.w600, color: C.ink500)),
      ]),
    );
  }
}
