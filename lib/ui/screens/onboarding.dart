import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../motion.dart';
import 'login.dart';

/// অনবোর্ডিং (Figma 11:171, 17:1474)। Swipe/তীর চাপলে ছবি parallax এ সরে,
/// লেখা fade হয়, ছবি হালকা ভাসতে থাকে।
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _ctrl = PageController();
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
  double _page = 0;

  // (ছবি, ছবির জায়গা: left/top/w/h — Figma তে ইলাস্ট্রেশন এলাকার সাপেক্ষে)
  static const _art = [
    ('assets/images/onboarding_1.png', Rect.fromLTWH(56, 46, 264, 226)),
    ('assets/images/onboarding_2.png', Rect.fromLTWH(59, 6, 260, 271)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _page = _ctrl.page ?? 0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _float.dispose();
    super.dispose();
  }

  void _toLogin() => Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));

  void _next() {
    if (_page.round() >= _art.length - 1) {
      _toLogin();
    } else {
      _ctrl.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = [(t('ob1_title'), t('ob1_desc')), (t('ob2_title'), t('ob2_desc'))];
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: C.onboardBg,
        body: Stack(children: [
          // নীল blob (দুই পেজে একই, swipe এ হালকা বড়-ছোট হয়)
          Positioned(
            top: safeTop + 130,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.scale(
                scale: 1 + 0.05 * math.sin(_page * math.pi),
                child: SvgPicture.asset('assets/brand/onboarding_blob.svg', width: 329, height: 250),
              ),
            ),
          ),
          PageView.builder(
            controller: _ctrl,
            itemCount: _art.length,
            itemBuilder: (_, i) {
              final delta = i - _page; // -1..1
              final vis = (1 - delta.abs()).clamp(0.0, 1.0);
              return Stack(children: [
                // ছবি — parallax + ভাসা
                Positioned(
                  top: safeTop + 100,
                  left: 0,
                  right: 0,
                  height: 301,
                  child: AnimatedBuilder(
                    animation: _float,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(delta * 140, math.sin(_float.value * 2 * math.pi + i) * 5),
                      child: Opacity(opacity: vis, child: Transform.scale(scale: 0.9 + 0.1 * vis, child: child)),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 375,
                        height: 301,
                        child: Stack(children: [
                          Positioned.fromRect(rect: _art[i].$2, child: Image.asset(_art[i].$1, fit: BoxFit.contain)),
                          // নিচের দিকে হালকা মিলিয়ে যাওয়া (Figma: gradient + blur)
                          Positioned(
                            left: 16,
                            top: 234,
                            width: 343,
                            height: 67,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0x00F2F2F7), C.onboardBg],
                                  stops: [0, 0.35],
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
                // লেখা
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: safeBottom + 42 + 42 + 78,
                  child: Opacity(
                    opacity: vis,
                    child: Transform.translate(
                      offset: Offset(delta * 60, (1 - vis) * 12),
                      child: Center(
                        child: SizedBox(
                          width: 308,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            SizedBox(width: i == 1 ? 231 : 308, child: Text(texts[i].$1, textAlign: TextAlign.center, style: Ty.s(28, FontWeight.w600, color: C.ink700).copyWith(height: 41 / 28))),
                            const SizedBox(height: 16),
                            Text(texts[i].$2, textAlign: TextAlign.center, style: Ty.s(16, FontWeight.w400, color: C.ink600).copyWith(height: 23 / 16)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),
          // পেছনে যাও (২য় পেজে)
          Positioned(
            top: safeTop + 24,
            left: 16,
            child: IgnorePointer(
              ignoring: _page < 0.5,
              child: Opacity(
                opacity: _page.clamp(0.0, 1.0),
                child: Pressable(
                  onTap: () => _ctrl.previousPage(duration: const Duration(milliseconds: 520), curve: Curves.easeInOutCubic),
                  scale: 0.88,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8)),
                    child: const Ic('back', size: 16),
                  ),
                ),
              ),
            ),
          ),
          // বাদ দিন + তীর
          Positioned(
            left: 20,
            right: 20,
            bottom: safeBottom + 42,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Pressable(onTap: _toLogin, child: Text(t('skip'), style: Ty.s(15, FontWeight.w500, color: C.ink600).copyWith(height: 22 / 15))),
              Pressable(
                onTap: _next,
                scale: 0.88,
                child: Container(
                  padding: const EdgeInsets.all(0.875),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.primary, width: 0.875)),
                  child: Container(
                    padding: const EdgeInsets.all(8.75),
                    decoration: const BoxDecoration(color: C.primary, shape: BoxShape.circle),
                    child: const Ic('arrow', size: 21),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
