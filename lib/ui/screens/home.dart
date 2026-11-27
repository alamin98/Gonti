import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../dialogs.dart';
import '../motion.dart';
import '../widgets.dart';
import 'coming_soon.dart';
import 'quick_add.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 124),
        children: [
          Reveal(
            index: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              MonthBar(
                compact: true,
                label: periodLabel(s.period),
                canNext: s.monthOffset < 0,
                onPrev: () => s.shiftMonth(-1),
                onNext: () => s.shiftMonth(1),
              ),
              RoundIconButton(icon: 'bell', onTap: () => openSoon(context, t('notifications'))),
            ]),
          ),
          const SizedBox(height: 12),
          Reveal(index: 1, child: _Hero(s: s)),
          const SizedBox(height: 12),
          Reveal(index: 2, child: _BudgetCard(s: s)),
          const SizedBox(height: 12),
          const Reveal(index: 3, child: _QuickAccess()),
          const SizedBox(height: 12),
          Reveal(
            index: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(t('recent'), style: Ty.s(16, FontWeight.w600, color: C.hero)),
                Pressable(onTap: () => s.setTab(1), child: Text(t('see_all'), style: Ty.s(13, FontWeight.w500, color: C.primary))),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Reveal(
            index: 5,
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: s.recent.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(t('empty_tx'), textAlign: TextAlign.center, style: Ty.s(14, FontWeight.w400, color: C.textTertiary)),
                    )
                  : Column(children: [
                      for (var i = 0; i < s.recent.length; i++)
                        TxRow(tx: s.recent[i], last: i == s.recent.length - 1, onTap: () => openTxEditor(context, s.recent[i])),
                    ]),
            ),
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

  Widget _flow(String label, int paisa, String icon, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: C.white16, borderRadius: BorderRadius.circular(R.md)),
      child: Row(children: [
        IconCircle(svg: icon, bg: bg, fg: fg, size: 30, iconSize: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Ty.s(12, FontWeight.w500, color: C.white85)),
            CountUp(paisa: paisa, style: Ty.s(16, FontWeight.w600, color: C.onHero)),
          ]),
        ),
      ]),
    );
  }

  Widget _pair(String label, int paisa) => Row(children: [
        Text(label, style: Ty.s(13, FontWeight.w400, color: C.white80)),
        const SizedBox(width: 6),
        CountUp(paisa: paisa, style: Ty.s(14, FontWeight.w600, color: C.onHero)),
      ]);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.xl),
      child: Container(
        color: C.hero,
        child: Stack(children: [
          const Positioned(left: 248, top: -70, child: _Dot(170, C.white08)),
          const Positioned(left: -40, top: 175, child: _Dot(110, C.white06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('remaining_label'), style: Ty.s(13, FontWeight.w500, color: C.white85).copyWith(height: 19 / 13)),
              const SizedBox(height: 2),
              CountUp(paisa: s.totals.balance, style: Ty.s(36, FontWeight.w700, color: C.onHero).copyWith(height: 52 / 36)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _flow(t('income'), s.totals.income, 'inn', C.mint300, const Color(0xFF064E3B))),
                const SizedBox(width: 10),
                Expanded(child: _flow(t('expense'), s.totals.expense, 'out', C.red300, const Color(0xFF7F1D1D))),
              ]),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_pair(t('pawna'), s.pawna), _pair(t('dena'), s.dena)]),
              ),
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
          const IconCircle(svg: 'wallet', bg: C.amber100, fg: C.amber700, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('budget_set'), style: Ty.s(15, FontWeight.w600)),
              Text(t('budget_set_sub'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
            ]),
          ),
          const Ic('right', size: 18, color: C.ink400),
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
          Text(t('budget_title'), style: Ty.s(15, FontWeight.w600, color: C.hero)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: C.primaryContainer, borderRadius: BorderRadius.circular(R.sm)),
            child: Text(digits('$pct%'), style: Ty.s(12, FontWeight.w700, color: C.primaryStrong)),
          ),
        ]),
        const SizedBox(height: 10),
        ProgressBar(value: ratio, color: color),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('${t('budget_spent')} ${taka(s.totals.budgetUsed)} / ${taka(s.budgetPaisa)}', style: Ty.s(12, FontWeight.w400, color: C.ink600), overflow: TextOverflow.ellipsis)),
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
    final items = <(String, String, Color, Color)>[
      (t('dena'), 'out', C.red100, C.expense),
      (t('pawna'), 'inn', C.green100, C.income),
      (t('dps'), 'bank', C.primaryContainer, C.primaryStrong),
      (t('budget'), 'wallet', C.amber100, C.amber700),
      (t('tools'), 'calc', C.ink100, C.ink600),
    ];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
      child: Row(children: [
        for (final it in items)
          Expanded(
            child: Pressable(
              scale: 0.9,
              onTap: () => it.$1 == t('budget') ? showBudgetDialog(context) : openSoon(context, it.$1),
              child: Column(children: [
                IconCircle(svg: it.$2, bg: it.$3, fg: it.$4),
                const SizedBox(height: 6),
                Text(it.$1, style: Ty.s(12, FontWeight.w500, color: C.ink700)),
              ]),
            ),
          ),
      ]),
    );
  }
}

/// টাকার অঙ্ক গুনে গুনে বাড়ে/কমে (হিসাব বদলালে চোখে পড়ে)
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.paisa, required this.style});
  final int paisa;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: paisa.toDouble()),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text(taka(v.round()), style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
}
