import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../motion.dart';
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
      Navigator.of(context).pushAndRemoveUntil(fadeRoute(const Shell()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    Future<void> lang(bool bn) async {
      final ok = await s.setLanguage(bn);
      if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('english_soon'))));
    }

    const gap = SizedBox(height: 14);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              child: Align(alignment: Alignment.centerRight, child: _LangSwitch(bangla: s.bangla, onChanged: lang)),
            ),
            const Reveal(index: 0, child: Center(child: _LogoTile())),
            gap,
            Reveal(
              index: 1,
              child: Column(children: [
                Text(t('welcome'), textAlign: TextAlign.center, style: Ty.s(28, FontWeight.w700, color: C.hero).copyWith(height: 41 / 28)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 279,
                  child: Text(t('welcome_sub'), textAlign: TextAlign.center, style: Ty.s(15, FontWeight.w400, color: C.ink600).copyWith(height: 22 / 15)),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            gap,
            Reveal(
              index: 2,
              child: AppCard(
                radius: R.xl,
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const IconCircle(svg: 'cloud', bg: C.primaryContainer, fg: C.primaryStrong, size: 30, iconSize: 16),
                    const SizedBox(width: 8),
                    Text(t('login_gets'), style: Ty.s(15, FontWeight.w600, color: C.hero)),
                  ]),
                  const SizedBox(height: 10),
                  for (final k in ['benefit1', 'benefit2']) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(children: [
                        const IconCircle(svg: 'check', bg: C.green100, fg: C.income, size: 20, iconSize: 12),
                        const SizedBox(width: 8),
                        Text(t(k), style: Ty.s(14, FontWeight.w400, color: C.ink700).copyWith(height: 20 / 14)),
                      ]),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    height: 54,
                    child: PrimaryButton(
                      label: t('google'),
                      leading: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Text('G', style: Ty.s(20, FontWeight.w700, color: C.primary).copyWith(height: 1.1)),
                      ),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('soon')))),
                    ),
                  ),
                ]),
              ),
            ),
            gap,
            Reveal(
              index: 3,
              child: Row(children: [
                const Expanded(child: Divider(color: C.ink200, height: 1)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(t('or'), style: Ty.s(13, FontWeight.w400, color: C.ink500))),
                const Expanded(child: Divider(color: C.ink200, height: 1)),
              ]),
            ),
            gap,
            Reveal(index: 4, child: GhostButton(label: t('continue_guest'), onPressed: () => _skip(context))),
            gap,
            Reveal(index: 5, child: InfoBanner(text: t('guest_warning'), warning: true)),
          ],
        ),
      ),
    );
  }
}

/// Figma Logo Tile (70px): নীল মানিব্যাগ + কয়েন। কয়েন হালকা দোলে।
class _LogoTile extends StatefulWidget {
  const _LogoTile();

  @override
  State<_LogoTile> createState() => _LogoTileState();
}

class _LogoTileState extends State<_LogoTile> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const k = 60.9 / 132; // Figma লোগো 132 → 60.9
    return SizedBox(
      width: 70,
      height: 70,
      child: Center(
        child: SizedBox(
          width: 60.9,
          height: 60.9,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 16.7 * k,
                top: -3 * Curves.easeInOut.transform(_c.value),
                child: SvgPicture.asset('assets/brand/coins.svg', width: 84 * k, height: 46 * k),
              ),
              Positioned(
                left: 4.2 * k,
                top: 36.35 * k,
                child: SvgPicture.asset('assets/brand/wallet_blue.svg', width: 124.3 * k, height: 96.1 * k),
              ),
            ]),
          ),
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
      return Pressable(
        onTap: () => onChanged(bn),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
