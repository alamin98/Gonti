import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../state/app_state.dart';
import '../motion.dart';
import '../widgets.dart';
import 'home.dart';
import 'lenden.dart';
import 'more.dart';
import 'quick_add.dart';
import 'report.dart';

/// চার ট্যাব + মাঝে (+) বাটন। ট্যাব বদলালে হালকা fade + slide।
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    const pages = [HomeScreen(), LendenScreen(), ReportScreen(), MoreScreen()];
    return Scaffold(
      body: Stack(children: [
        for (var i = 0; i < pages.length; i++)
          // আগে TickerMode বাইরে ছিল → ট্যাব বদলালে পুরনো পেজের fade-out অ্যানিমেশন থেমে যেত,
          // পেজটা দেখা যেত আর নতুন পেজের সাথে overlap হতো। এখন TickerMode শুধু পেজের ভেতরে।
          IgnorePointer(
            ignoring: s.tab != i,
            child: AnimatedOpacity(
              opacity: s.tab == i ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: AnimatedSlide(
                offset: s.tab == i ? Offset.zero : const Offset(0, 0.015),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: TickerMode(enabled: s.tab == i, child: pages[i]),
              ),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14 + bottom,
          child: FloatingNav(
            index: s.tab,
            labels: [t('tab_home'), t('tab_lenden'), t('tab_report'), t('tab_more')],
            onTap: s.setTab,
            onAdd: () => Navigator.of(context).push(fadeRoute(const QuickAddScreen(), fullscreenDialog: true)),
          ),
        ),
      ]),
    );
  }
}
