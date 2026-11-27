import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../widgets.dart';

void openSoon(BuildContext context, String title) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComingSoonScreen(title: title)));
}

/// যে মডিউল এখনো বানানো হয়নি, সেগুলোর জন্য সাময়িক পেজ।
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(children: [
              RoundIconButton(icon: Icons.chevron_left_rounded, onTap: () => Navigator.pop(context)),
              Expanded(child: Center(child: Text(title, style: Ty.s(19, FontWeight.w600)))),
              const SizedBox(width: 40),
            ]),
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const IconCircle(icon: Icons.construction_rounded, bg: C.primaryContainer, fg: C.primaryStrong, size: 72, iconSize: 34),
                  const SizedBox(height: 16),
                  Text(t('soon'), style: Ty.s(22, FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(t('soon_sub'), style: Ty.s(14, FontWeight.w400, color: C.textTertiary), textAlign: TextAlign.center),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
