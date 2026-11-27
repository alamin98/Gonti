import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../widgets.dart';
import 'shell.dart';

/// লগইন ঐচ্ছিক। ভাষা এখানেই বদলানো যায় (ডিফল্ট বাংলা)।
/// Google লগইন + ক্লাউড ব্যাকআপ Phase 2 তে আসবে — এখন বাটন শুধু "শীঘ্রই আসছে" দেখায়।
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.fromMore = false});
  final bool fromMore; // true হলে আরও ট্যাব থেকে খোলা হয়েছে → স্কিপে শুধু ফিরে যাবে

  Future<void> _skip(BuildContext context) async {
    final state = context.read<AppState>();
    await state.completeOnboarding();
    if (!context.mounted) return;
    if (fromMore) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const Shell()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(alignment: Alignment.centerRight, child: _LangSwitch(bangla: s.bangla, onChanged: s.setLanguage)),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(R.xl), boxShadow: Shadows.action),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 44, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            Text(t('welcome'), textAlign: TextAlign.center, style: Ty.s(30, FontWeight.w700)),
            const SizedBox(height: 4),
            Text(t('welcome_sub'), textAlign: TextAlign.center, style: Ty.s(15, FontWeight.w400, color: C.textTertiary)),
            const SizedBox(height: 28),
            AppCard(
              radius: R.xl,
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const IconCircle(icon: Icons.cloud_outlined, bg: C.primaryContainer, fg: C.primaryStrong, size: 30, iconSize: 16),
                  const SizedBox(width: 8),
                  Text(t('login_gets'), style: Ty.s(15, FontWeight.w600)),
                ]),
                const SizedBox(height: 10),
                for (final k in ['benefit1', 'benefit2'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Row(children: [
                      const IconCircle(icon: Icons.check_rounded, bg: C.green100, fg: C.income, size: 20, iconSize: 12),
                      const SizedBox(width: 8),
                      Text(t(k), style: Ty.s(14, FontWeight.w400, color: C.ink700)),
                    ]),
                  ),
                const SizedBox(height: 4),
                PrimaryButton(
                  label: t('google'),
                  leading: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Text('G', style: Ty.s(18, FontWeight.w800, color: C.primary)),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('soon')))),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Expanded(child: Divider(color: C.ink200)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(t('or'), style: Ty.s(13, FontWeight.w400, color: C.ink500))),
              const Expanded(child: Divider(color: C.ink200)),
            ]),
            const SizedBox(height: 8),
            GhostButton(label: t('continue_guest'), onPressed: () => _skip(context)),
            const SizedBox(height: 8),
            InfoBanner(text: t('guest_warning'), warning: true),
          ],
        ),
      ),
    );
  }
}

class _LangSwitch extends StatelessWidget {
  const _LangSwitch({required this.bangla, required this.onChanged});
  final bool bangla;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool bn) {
      final on = bangla == bn;
      return GestureDetector(
        onTap: () => onChanged(bn),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(color: on ? C.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(R.full)),
          child: Text(label, style: Ty.s(14, on ? FontWeight.w600 : FontWeight.w500, color: on ? C.primaryStrong : C.ink600)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(R.full), boxShadow: Shadows.card),
      child: Row(mainAxisSize: MainAxisSize.min, children: [seg('বাংলা', true), seg('English', false)]),
    );
  }
}
