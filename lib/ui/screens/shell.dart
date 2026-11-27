import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../state/app_state.dart';
import '../widgets.dart';
import 'home.dart';
import 'lenden.dart';
import 'more.dart';
import 'quick_add.dart';
import 'report.dart';

/// চার ট্যাব + মাঝে (+) বাটন
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      body: Stack(children: [
        IndexedStack(index: s.tab, children: const [HomeScreen(), LendenScreen(), ReportScreen(), MoreScreen()]),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14 + bottom,
          child: FloatingNav(
            index: s.tab,
            labels: [t('tab_home'), t('tab_lenden'), t('tab_report'), t('tab_more')],
            onTap: s.setTab,
            onAdd: () => Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const QuickAddScreen())),
          ),
        ),
      ]),
    );
  }
}
