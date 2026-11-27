import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../dialogs.dart';
import '../widgets.dart';
import 'coming_soon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            MonthBar(
              compact: true,
              label: periodLabel(s.period),
              canNext: s.monthOffset < 0,
              onPrev: () => s.shiftMonth(-1),
              onNext: () => s.shiftMonth(1),
            ),
            RoundIconButton(icon: Icons.notifications_none_rounded, onTap: () => openSoon(context, t('notifications'))),
          ]),
          const SizedBox(height: 12),
          _Hero(s: s),
          const SizedBox(height: 12),
          _BudgetCard(s: s),
          const SizedBox(height: 12),
          const _QuickAccess(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(t('recent'), style: Ty.s(16, FontWeight.w600)),
              InkWell(onTap: () => s.setTab(1), child: Text(t('see_all'), style: Ty.s(13, FontWeight.w500, color: C.primary))),
            ]),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: s.recent.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(t('empty_tx'), textAlign: TextAlign.center, style: Ty.s(14, FontWeight.w400, color: C.textTertiary)),
                  )
                : Column(children: [
                    for (var i = 0; i < s.recent.length; i++) TxRow(tx: s.recent[i], last: i == s.recent.length - 1),
                  ]),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.size, this.color);
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

/// সারাংশ কার্ড — navy (Figma: color/hero), তথ্য দেখানোর জন্য; নীল রং শুধু অ্যাকশনের জন্য
class _Hero extends StatelessWidget {
  const _Hero({required this.s});
  final AppState s;

  Widget _flow(String label, int paisa, IconData icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: C.white16, borderRadius: BorderRadius.circular(R.md)),
      child: Row(children: [
        IconCircle(icon: icon, bg: bg, fg: fg, size: 30, iconSize: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Ty.s(12, FontWeight.w500, color: C.white85)),
            Text(taka(paisa), style: Ty.s(16, FontWeight.w600, color: C.onHero), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }

  Widget _pair(String label, int paisa) => Row(children: [
        Text('$label ', style: Ty.s(13, FontWeight.w400, color: C.white85)),
        Text(taka(paisa), style: Ty.s(14, FontWeight.w600, color: C.onHero)),
      ]);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.xl),
      child: Container(
        color: C.hero,
        child: Stack(children: [
          const Positioned(right: -50, top: -60, child: _Dot(170, C.white08)),
          const Positioned(left: -40, bottom: -55, child: _Dot(110, C.white06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('remaining_label'), style: Ty.s(13, FontWeight.w500, color: C.white85)),
              Text(taka(s.totals.balance), style: Ty.s(38, FontWeight.w700, color: C.onHero)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _flow(t('income'), s.totals.income, Icons.south_west_rounded, C.mint300, const Color(0xFF064E3B))),
                const SizedBox(width: 10),
                Expanded(child: _flow(t('expense'), s.totals.expense, Icons.north_east_rounded, C.red300, const Color(0xFF7F1D1D))),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_pair(t('pawna'), s.pawna), _pair(t('dena'), s.dena)]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.s});
  final AppState s;

  @override
  Widget build(BuildContext context) {
    if (s.budgetPaisa <= 0) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        onTap: () => showBudgetDialog(context),
        child: Row(children: [
          const IconCircle(icon: Icons.account_balance_wallet_rounded, bg: C.amber100, fg: C.amber700, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('budget_set'), style: Ty.s(15, FontWeight.w600)),
              Text(t('budget_set_sub'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: C.ink400),
        ]),
      );
    }
    final ratio = s.budgetRatio;
    final pct = (ratio * 100).round();
    final color = ratio >= 1 ? C.red400 : (ratio >= 0.8 ? C.warningFill : C.primary);
    final left = s.budgetPaisa - s.totals.budgetUsed;
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => showBudgetDialog(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t('budget_title'), style: Ty.s(15, FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: C.primaryContainer, borderRadius: BorderRadius.circular(R.sm)),
            child: Text(digits('$pct%'), style: Ty.s(13, FontWeight.w700, color: C.primaryStrong)),
          ),
        ]),
        const SizedBox(height: 10),
        ProgressBar(value: ratio, color: color),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${t('budget_spent')} ${taka(s.totals.budgetUsed)} / ${taka(s.budgetPaisa)}', style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
          Text(left >= 0 ? '${t('budget_left')} ${taka(left)}' : t('budget_over'),
              style: Ty.s(12, FontWeight.w600, color: left >= 0 ? C.ink700 : C.expense)),
        ]),
      ]),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, Color, Color)>[
      (t('dena'), Icons.north_east_rounded, C.red100, C.expense),
      (t('pawna'), Icons.south_west_rounded, C.green100, C.income),
      (t('dps'), Icons.account_balance_rounded, C.primaryContainer, C.primaryStrong),
      (t('budget'), Icons.account_balance_wallet_rounded, C.amber100, C.amber700),
      (t('tools'), Icons.calculate_rounded, C.ink100, C.ink600),
    ];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
      child: Row(children: [
        for (final it in items)
          Expanded(
            child: InkResponse(
              onTap: () => it.$1 == t('budget') ? showBudgetDialog(context) : openSoon(context, it.$1),
              child: Column(children: [
                IconCircle(icon: it.$2, bg: it.$3, fg: it.$4),
                const SizedBox(height: 6),
                Text(it.$1, style: Ty.s(12, FontWeight.w500, color: C.ink700)),
              ]),
            ),
          ),
      ]),
    );
  }
}
