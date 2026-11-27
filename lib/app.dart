import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'state/app_state.dart';
import 'ui/motion.dart';
import 'ui/screens/splash.dart';

class GontiApp extends StatelessWidget {
  const GontiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bangla = context.select<AppState, bool>((s) => s.bangla);
    return MaterialApp(
      title: 'গণতি',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: Locale(bangla ? 'bn' : 'en'),
      supportedLocales: const [Locale('bn'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => DesignScale(child: child ?? const SizedBox()),
      home: const SplashScreen(),
    );
  }
}
