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
import 'login.dart';
import 'settings.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    final items = <(IconData, Color, Color, String, String, VoidCallback)>[
      (Icons.north_east_rounded, C.red100, C.expense, t('dena'), t('dena_sub'), () => openSoon(context, t('dena'))),
      (Icons.south_west_rounded, C.green100, C.income, t('pawna'), t('pawna_sub'), () => openSoon(context, t('pawna'))),
      (Icons.account_balance_rounded, C.primaryContainer, C.primaryStrong, t('dps_title'), t('dps_sub'), () => openSoon(context, t('dps_title'))),
      (Icons.account_balance_wallet_rounded, C.amber100, C.amber700, t('budget'), t('budget_sub'), () => showBudgetDialog(context)),
      (Icons.calculate_rounded, C.ink100, C.ink600, t('tools'), t('tools_sub'), () => openSoon(context, t('tools'))),
      (Icons.shield_outlined, C.green100, const Color(0xFF047857), t('settings'), t('settings_sub'), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
        children: [
          Text(t('tab_more'), style: Ty.s(28, FontWeight.w700)),
          const SizedBox(height: 12),
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
              TextButton(
                style: TextButton.styleFrom(backgroundColor: C.primary, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 16)),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen(fromMore: true))),
                child: Text(t('login'), style: Ty.s(14, FontWeight.w600, color: C.onPrimary)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          InfoBanner(text: t('login_hint'), warning: true),
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
