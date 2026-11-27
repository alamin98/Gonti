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
import 'login.dart';
import 'settings.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = <(IconData, Color, Color, String, String, VoidCallback)>[
      (Icons.north_east_rounded, C.red100, C.expense, t('dena'), t('dena_sub'), () => openSoon(context, t('dena'))),
      (Icons.south_west_rounded, C.green100, C.income, t('pawna'), t('pawna_sub'), () => openSoon(context, t('pawna'))),
      (Icons.account_balance_rounded, C.primaryContainer, C.primaryStrong, t('dps_title'), t('dps_sub'), () => openSoon(context, t('dps_title'))),
      (Icons.account_balance_wallet_rounded, C.amber100, C.amber700, t('budget'), t('budget_sub'), () => showBudgetDialog(context)),
      (Icons.calculate_rounded, C.ink100, C.ink600, t('tools'), t('tools_sub'), () => openSoon(context, t('tools'))),
      (Icons.shield_outlined, C.green100, const Color(0xFF047857), t('settings'), t('settings_sub'), () => Navigator.of(context).push(fadeRoute(const SettingsScreen()))),
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
        children: [
          Text(t('tab_more'), style: Ty.s(28, FontWeight.w700)),
          const SizedBox(height: 12),
          if (s.signedIn) _AccountCard(s: s) else ...[
            AppCard(
              radius: 22,
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const IconCircle(icon: Icons.person_outline_rounded, bg: C.primaryContainer, fg: C.primaryStrong, size: 52, iconSize: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t('guest'), style: Ty.s(17, FontWeight.w600)),
                    Text(t('guest_sub'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
                  ]),
                ),
                Pressable(
                  onTap: () => Navigator.of(context).push(fadeRoute(const LoginScreen(fromMore: true))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const ShapeDecoration(color: C.primary, shape: StadiumBorder()),
                    child: Text(t('login'), style: Ty.s(14, FontWeight.w600, color: C.onPrimary)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            InfoBanner(text: t('login_hint'), warning: true),
          ],
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: [
              for (var i = 0; i < items.length; i++)
                InkWell(
                  onTap: items[i].$6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(border: i == items.length - 1 ? null : const Border(bottom: BorderSide(color: C.surfaceVariant))),
                    child: Row(children: [
                      IconCircle(icon: items[i].$1, bg: items[i].$2, fg: items[i].$3, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(items[i].$4, style: Ty.s(16, FontWeight.w600)),
                          Text(items[i].$5, style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: C.ink400),
                    ]),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// লগইন থাকলে: নাম, ইমেইল, শেষ ব্যাকআপ, এখন ব্যাকআপ, লগআউট
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.s});
  final AppState s;

  Future<void> _backup(BuildContext context) async {
    final m = ScaffoldMessenger.of(context);
    try {
      await s.backupNow();
      m.showSnackBar(SnackBar(content: Text(t('backup_done'))));
    } catch (_) {
      m.showSnackBar(SnackBar(content: Text(t('backup_failed'))));
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: dialogShape,
        title: Text(t('logout_title'), style: Ty.s(18, FontWeight.w600)),
        content: Text(t('logout_body'), style: Ty.s(14, FontWeight.w400, color: C.ink600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'), style: Ty.s(15, FontWeight.w600, color: C.ink600))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('logout'), style: Ty.s(15, FontWeight.w600, color: C.expense))),
        ],
      ),
    );
    if (ok == true) await s.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final name = (s.userName ?? '').trim();
    final lb = s.lastBackup;
    final when = lb == null
        ? t('no_backup_yet')
        : '${t('last_backup')}: ${dayLabel(lb)}, ${digits('${lb.hour % 12 == 0 ? 12 : lb.hour % 12}:${lb.minute.toString().padLeft(2, '0')}')}';
    return AppCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: C.primaryContainer, shape: BoxShape.circle),
            child: Text(name.isEmpty ? 'G' : name.characters.first.toUpperCase(), style: Ty.s(22, FontWeight.w700, color: C.primaryStrong)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.isEmpty ? (s.userEmail ?? '') : name, style: Ty.s(17, FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(s.userEmail ?? '', style: Ty.s(12, FontWeight.w400, color: C.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Pressable(
            onTap: () => _logout(context),
            child: Padding(padding: const EdgeInsets.all(6), child: Text(t('logout'), style: Ty.s(13, FontWeight.w600, color: C.expense))),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(color: C.green100.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(R.sm)),
          child: Row(children: [
            const Icon(Icons.cloud_done_rounded, size: 20, color: C.income),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(s.syncing ? t('syncing') : when, key: ValueKey(s.syncing ? 'sync' : when), style: Ty.s(13, FontWeight.w600, color: C.ink700)),
                ),
                Text(t('auto_backup_on'), style: Ty.s(11, FontWeight.w400, color: C.textTertiary)),
              ]),
            ),
            Pressable(
              onTap: s.syncing ? null : () => _backup(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(R.full), border: Border.all(color: C.primary300)),
                child: s.syncing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(t('backup_now'), style: Ty.s(12, FontWeight.w600, color: C.primaryStrong)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
