import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/period.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../dialogs.dart';
import '../widgets.dart';
import 'coming_soon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickMonthStart(BuildContext context) async {
    final state = context.read<AppState>();
    var day = state.monthStartDay;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final preview = periodFor(DateTime.now(), day);
          return AlertDialog(
            shape: dialogShape,
            title: Text(t('month_start'), style: Ty.s(18, FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t('month_start_hint'), style: Ty.s(13, FontWeight.w400, color: C.textTertiary)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (var d = 1; d <= 31; d++) AppChip(label: digits('$d'), selected: d == day, onTap: () => setD(() => day = d)),
                ]),
                const SizedBox(height: 14),
                Text(t('current_period'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
                Text(periodLabel(preview), style: Ty.s(16, FontWeight.w700, color: C.primaryStrong)),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'), style: Ty.s(15, FontWeight.w600, color: C.ink600))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('save'), style: Ty.s(15, FontWeight.w600, color: C.primary))),
            ],
          );
        },
      ),
    );
    if (ok == true) await state.setMonthStartDay(day);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final state = context.read<AppState>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(R.xl))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          for (final e in [(true, t('lang_bn')), (false, t('lang_en'))])
            ListTile(
              title: Text(e.$2, style: Ty.s(16, FontWeight.w600)),
              trailing: state.bangla == e.$1 ? const Icon(Icons.check_rounded, color: C.primary) : null,
              onTap: () {
                state.setLanguage(e.$1);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              RoundIconButton(icon: Icons.chevron_left_rounded, onTap: () => Navigator.pop(context)),
              Expanded(child: Center(child: Text(t('settings'), style: Ty.s(19, FontWeight.w600)))),
              const SizedBox(width: 40),
            ]),
            const SizedBox(height: 16),
            _Section(t('sec_accounting')),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(children: [
                _Row(Icons.calendar_today_rounded, C.primaryContainer, C.primaryStrong, t('month_start'),
                    value: '${digits('${s.monthStartDay}')} ${t('day_suffix')}'.trim(), onTap: () => _pickMonthStart(context)),
                _Row(Icons.account_balance_wallet_rounded, C.amber100, C.amber700, t('budget_title'),
                    value: s.budgetPaisa > 0 ? taka(s.budgetPaisa) : t('not_set'), onTap: () => showBudgetDialog(context)),
                _Row(Icons.sell_outlined, C.amber100, C.amber700, t('categories'), onTap: () => openSoon(context, t('categories')), last: true),
              ]),
            ),
            const SizedBox(height: 16),
            _Section(t('sec_app')),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(children: [
                _Row(Icons.language_rounded, C.primaryContainer, C.primaryStrong, t('language'),
                    value: s.bangla ? t('lang_bn') : t('lang_en'), onTap: () => _pickLanguage(context)),
                _Row(Icons.lock_outline_rounded, C.red100, C.expense, t('pin_lock'), onTap: () => openSoon(context, t('pin_lock')), last: true),
              ]),
            ),
            const SizedBox(height: 16),
            _Section(t('sec_backup')),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(children: [
                _Row(Icons.cloud_upload_outlined, C.ink100, C.ink600, t('backup_now'), lockChip: true),
                _Row(Icons.cloud_download_outlined, C.ink100, C.ink600, t('restore'), lockChip: true, last: true),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title, style: Ty.s(13, FontWeight.w600, color: C.ink500)),
      );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.bg, this.fg, this.title, {this.value, this.onTap, this.last = false, this.lockChip = false});
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool last;
  final bool lockChip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: C.surfaceVariant))),
        child: Row(children: [
          IconCircle(icon: icon, bg: bg, fg: fg, size: 36, iconSize: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Ty.s(15, FontWeight.w500))),
          if (value != null) Text(value!, style: Ty.s(14, FontWeight.w600, color: C.ink600)),
          if (lockChip)
            Container(
              padding: const EdgeInsets.fromLTRB(8, 3, 10, 3),
              decoration: BoxDecoration(color: C.amber100, borderRadius: BorderRadius.circular(R.sm)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock_outline_rounded, size: 12, color: C.amber700),
                const SizedBox(width: 4),
                Text(t('login_needed'), style: Ty.s(12, FontWeight.w600, color: C.amber800)),
              ]),
            )
          else if (onTap != null)
            const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.chevron_right_rounded, size: 20, color: C.ink400)),
        ]),
      ),
    );
  }
}
