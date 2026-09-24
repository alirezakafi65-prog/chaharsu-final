import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core.dart';
import 'focus_screen.dart';
import 'matrix_screen.dart';
import 'stats_screen.dart';
import 'task_sheet.dart';
import 'today_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await app.init();
  runApp(const ChaharsuApp());
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Pal.dark : Pal.light;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF14205B),
      brightness: b,
    ).copyWith(surface: p.surface, primary: p.btn, onPrimary: p.btnInk),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(color: p.surface, fontFamily: 'Vazirmatn'),
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: p.ink),
  );
}

class ChaharsuApp extends StatelessWidget {
  const ChaharsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) => MaterialApp(
        title: 'چهارسو',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: messengerKey,
        themeMode: app.themeMode,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        // کل برنامه راست‌به‌چپ است
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final overlay = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: p.surface,
      ),
      child: AnimatedBuilder(
        animation: app,
        builder: (context, _) => Scaffold(
          backgroundColor: p.bg,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: app.tab,
              children: const [
                TodayScreen(),
                MatrixScreen(),
                FocusScreen(),
                StatsScreen(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showTaskSheet(context, null),
            backgroundColor: p.btn,
            foregroundColor: p.btnInk,
            elevation: 4,
            shape: const CircleBorder(),
            tooltip: 'کار تازه',
            child: const Icon(Icons.add_rounded, size: 32),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            height: 68,
            color: p.surface,
            surfaceTintColor: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                _NavItem(i: 0, icon: Icons.event_available_outlined, label: 'امروز'),
                _NavItem(i: 1, icon: Icons.grid_view_rounded, label: 'چهارسو'),
                const SizedBox(width: 72),
                _NavItem(i: 2, icon: Icons.timer_outlined, label: 'تمرکز'),
                _NavItem(i: 3, icon: Icons.bar_chart_rounded, label: 'آمار'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int i;
  final IconData icon;
  final String label;
  const _NavItem({required this.i, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final active = app.tab == i;
    final c = active ? p.ink : p.ink2;
    return Expanded(
      child: InkResponse(
        onTap: () => app.goTab(i),
        radius: 34,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: c),
            const SizedBox(height: 2),
            Text(label,
                style: tsx(c, 11,
                    w: active ? FontWeight.w800 : FontWeight.w500, h: 1.2)),
          ],
        ),
      ),
    );
  }
}
