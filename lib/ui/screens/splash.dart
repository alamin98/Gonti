import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../motion.dart';
import 'onboarding.dart';
import 'shell.dart';

/// Splash (Figma 10:2) — ৩৭৫×৮১২ ক্যানভাস হুবহু, সাথে অ্যানিমেশন:
/// মানিব্যাগ লাফিয়ে আসে → কয়েন উপর থেকে পড়ে → "Gonti / গণতি" ভেসে ওঠে।
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      final onboarded = context.read<AppState>().onboarded;
      Navigator.of(context).pushReplacement(fadeRoute(onboarded ? const Shell() : const OnboardingScreen()));
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  Animation<double> _seg(double a, double b, Curve c) => CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: c));

  @override
  Widget build(BuildContext context) {
    final walletIn = _seg(0.0, 0.40, Curves.easeOutBack);
    final walletFade = _seg(0.0, 0.25, Curves.easeOut);
    final coinsDrop = _seg(0.25, 0.70, Curves.bounceOut);
    final coinsFade = _seg(0.25, 0.40, Curves.easeOut);
    final textIn = _seg(0.55, 0.85, Curves.easeOutCubic);
    final subIn = _seg(0.68, 1.0, Curves.easeOutCubic);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: C.primary,
        body: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 375,
              height: 812,
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _loop]),
                builder: (context, _) {
                  final t = _loop.value * 2 * math.pi;
                  return Stack(clipBehavior: Clip.none, children: [
                    // পেছনের হালকা আকার — ধীরে ধীরে দোলে
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Transform.translate(
                        offset: Offset(math.sin(t) * 6, math.cos(t) * 4),
                        child: SvgPicture.asset('assets/brand/splash_decor_top.svg', width: 375, height: 215),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 321,
                      child: Transform.translate(
                        offset: Offset(math.cos(t) * 6, math.sin(t) * 5),
                        child: SvgPicture.asset('assets/brand/splash_decor_bottom.svg', width: 375, height: 491),
                      ),
                    ),
                    // লোগো 132×132, উপরে 288
                    Positioned(
                      left: 121.5,
                      top: 288,
                      width: 132,
                      height: 132,
                      child: Stack(clipBehavior: Clip.none, children: [
                        Positioned(
                          left: 16.7,
                          top: -90 * (1 - coinsDrop.value),
                          child: Opacity(
                            opacity: coinsFade.value,
                            child: SvgPicture.asset('assets/brand/coins.svg', width: 84, height: 46),
                          ),
                        ),
                        Positioned(
                          left: 4.2,
                          top: 36.35,
                          child: Opacity(
                            opacity: walletFade.value,
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * walletIn.value,
                              child: SvgPicture.asset('assets/brand/wallet_white.svg', width: 124.3, height: 96.1),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    // Gonti + গণতি (নিচে)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 637,
                      child: Column(children: [
                        Opacity(
                          opacity: textIn.value,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - textIn.value)),
                            child: SizedBox(
                              height: 50,
                              child: Center(child: SvgPicture.asset('assets/brand/wordmark.svg', width: 103, height: 33)),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: subIn.value,
                          child: Transform.translate(
                            offset: Offset(0, 14 * (1 - subIn.value)),
                            child: Text('গণতি', style: Ty.s(24, FontWeight.w600, color: C.warningFill).copyWith(height: 35 / 24)),
                          ),
                        ),
                      ]),
                    ),
                  ]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
