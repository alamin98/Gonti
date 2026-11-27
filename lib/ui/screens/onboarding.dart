import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import 'login.dart';

/// দুই পেজের অনবোর্ডিং। (Figma এর ইলাস্ট্রেশন পরে asset হিসেবে বসানো হবে — এখন আইকন দিয়ে সাময়িক)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  void _toLogin() => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));

  void _next() {
    if (_page == 1) {
      _toLogin();
    } else {
      _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      (Icons.account_balance_wallet_rounded, t('ob1_title'), t('ob1_desc')),
      (Icons.receipt_long_rounded, t('ob2_title'), t('ob2_desc')),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(color: C.primaryContainer, shape: BoxShape.circle),
                    child: Icon(pages[i].$1, size: 96, color: C.primary),
                  ),
                  const SizedBox(height: 40),
                  Text(pages[i].$2, textAlign: TextAlign.center, style: Ty.s(30, FontWeight.w600, color: C.ink700)),
                  const SizedBox(height: 12),
                  Text(pages[i].$3, textAlign: TextAlign.center, style: Ty.s(16, FontWeight.w400, color: C.textTertiary)),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(onPressed: _toLogin, child: Text(t('skip'), style: Ty.s(15, FontWeight.w500, color: C.ink600))),
              Row(children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(color: i == _page ? C.primary : C.ink200, borderRadius: BorderRadius.circular(4)),
                  ),
              ]),
              InkResponse(
                onTap: _next,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: C.primary, shape: BoxShape.circle, boxShadow: Shadows.action),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
