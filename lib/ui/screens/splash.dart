import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import 'onboarding.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final onboarded = context.read<AppState>().onboarded;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => onboarded ? const Shell() : const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.primary,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.account_balance_wallet_rounded, size: 84, color: Colors.white),
          const SizedBox(height: 12),
          Text(t('app_name'), style: Ty.s(40, FontWeight.w700, color: C.onPrimary)),
        ]),
      ),
    );
  }
}
