import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../state/app_state.dart';
import '../widgets.dart';

/// রিপোর্ট — পরের ধাপে (ক্যাটাগরি অনুযায়ী খরচের ডোনাট চার্ট ও আগের মাসের তুলনা)
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
        children: [
          Text(t('tab_report'), style: Ty.s(28, FontWeight.w700)),
          const SizedBox(height: 40),
          Center(
            child: Column(children: [
              const IconCircle(icon: Icons.bar_chart_rounded, bg: C.primaryContainer, fg: C.primaryStrong, size: 72, iconSize: 34),
              const SizedBox(height: 16),
              Text(t('soon'), style: Ty.s(22, FontWeight.w700)),
              Text(t('soon_sub'), style: Ty.s(14, FontWeight.w400, color: C.textTertiary)),
            ]),
          ),
        ],
      ),
    );
  }
}
