import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// چهار سوی ماتریس آیزنهاور
enum Q { q1, q2, q3, q4 }

class QInfo {
  final String name, tag, verdict, empty;
  const QInfo(this.name, this.tag, this.verdict, this.empty);
}

const Map<Q, QInfo> qInfo = {
  Q.q1: QInfo('انجام بده', 'مهم و فوری', 'همین حالا سراغش برو', 'کار فوری‌ای باقی نمانده.'),
  Q.q2: QInfo('برنامه بریز', 'مهم و غیرفوری', 'زمانش را در برنامه‌ات بگذار', 'برای کارهای مهم هنوز وقتی نگذاشته‌ای.'),
  Q.q3: QInfo('بسپار', 'فوری و کم‌اهمیت', 'به کسی بسپار یا کوتاه تمامش کن', 'چیزی برای سپردن نیست.'),
  Q.q4: QInfo('کنار بگذار', 'نه مهم، نه فوری', 'حذفش کن یا برای وقت آزاد نگه دار', 'فهرست کنار گذاشته‌ها خالی است.'),
};

/// موقعیت فیزیکی هر سو روی صفحه: q1 بالا-راست، q2 بالا-چپ، q3 پایین-راست، q4 پایین-چپ
double sxOf(Q q) => (q == Q.q1 || q == Q.q3) ? 1.0 : -1.0;
double syOf(Q q) => (q == Q.q1 || q == Q.q2) ? -1.0 : 1.0;

/// رنگ‌های روشن ثابت (برای استفاده روی زمینه‌ی لاجوردی)
const Map<Q, Color> qBright = {
  Q.q1: Color(0xFFFF4D5E),
  Q.q2: Color(0xFF1FC8B4),
  Q.q3: Color(0xFFFFB81C),
  Q.q4: Color(0xFFA9B4DC),
};

Color op(Color c, double o) =>
    c.withAlpha((o * 255).round().clamp(0, 255).toInt());

class Pal {
  final Color bg, surface, surface2, ink, ink2, line, hero, btn, btnInk;
  final Color q1, q2, q3, q4, q1t, q2t, q3t, q4t;

  const Pal({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.ink2,
    required this.line,
    required this.hero,
    required this.btn,
    required this.btnInk,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q1t,
    required this.q2t,
    required this.q3t,
    required this.q4t,
  });

  Color fill(Q q) {
    switch (q) {
      case Q.q1:
        return q1;
      case Q.q2:
        return q2;
      case Q.q3:
        return q3;
      case Q.q4:
        return q4;
    }
  }

  Color text(Q q) {
    switch (q) {
      case Q.q1:
        return q1t;
      case Q.q2:
        return q2t;
      case Q.q3:
        return q3t;
      case Q.q4:
        return q4t;
    }
  }

  Map<Q, Color> get fills => {Q.q1: q1, Q.q2: q2, Q.q3: q3, Q.q4: q4};

  static const light = Pal(
    bg: Color(0xFFEDF1F8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4F6FC),
    ink: Color(0xFF14205B),
    ink2: Color(0xFF4F5A8C),
    line: Color(0xFFDAE0EF),
    hero: Color(0xFF14205B),
    btn: Color(0xFF14205B),
    btnInk: Color(0xFFFFFFFF),
    q1: Color(0xFFE63548),
    q2: Color(0xFF0FA897),
    q3: Color(0xFFE89B00),
    q4: Color(0xFF8593C4),
    q1t: Color(0xFFC0233A),
    q2t: Color(0xFF0A7A6E),
    q3t: Color(0xFF96600A),
    q4t: Color(0xFF525E96),
  );

  static const dark = Pal(
    bg: Color(0xFF0A1130),
    surface: Color(0xFF131C48),
    surface2: Color(0xFF1A2456),
    ink: Color(0xFFEEF1FF),
    ink2: Color(0xFFA9B3DD),
    line: Color(0xFF2A3566),
    hero: Color(0xFF1F2C6E),
    btn: Color(0xFFFFB81C),
    btnInk: Color(0xFF14205B),
    q1: Color(0xFFFF4D5E),
    q2: Color(0xFF1FC8B4),
    q3: Color(0xFFFFB81C),
    q4: Color(0xFFA9B4DC),
    q1t: Color(0xFFFF8391),
    q2t: Color(0xFF57E3D3),
    q3t: Color(0xFFFFCB55),
    q4t: Color(0xFFBCC6EC),
  );

  static Pal of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

/// متن با فونت وزیرمتن (متن) یا لالزار (عنوان‌ها). اگر فونت‌ها همراه برنامه نباشند،
/// اندروید به‌صورت خودکار از فونت سیستم استفاده می‌کند.
TextStyle tsx(Color c, double size,
        {FontWeight w = FontWeight.w400,
        bool display = false,
        double? h,
        TextDecoration? deco}) =>
    TextStyle(
      color: c,
      fontSize: size,
      fontWeight: w,
      fontFamily: display ? 'Lalezar' : 'Vazirmatn',
      height: h,
      decoration: deco,
    );

// ---------------------------------------------------------------- ابزارهای متنی

const List<String> _digits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

String fa(int n) {
  final sb = StringBuffer();
  for (final u in n.toString().codeUnits) {
    if (u >= 48 && u <= 57) {
      sb.write(_digits[u - 48]);
    } else {
      sb.writeCharCode(u);
    }
  }
  return sb.toString();
}

String two(int n) => fa(n ~/ 10) + fa(n % 10);

String fmtMin(int m) {
  final h = m ~/ 60, r = m % 60;
  if (h == 0) return '${fa(r)} دقیقه';
  if (r == 0) return '${fa(h)} ساعت';
  return '${fa(h)} ساعت و ${fa(r)} دقیقه';
}

String short(String s, [int n = 22]) =>
    s.length > n ? '${s.substring(0, n - 1)}…' : s;

String dkey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ---------------------------------------------------------------- تاریخ شمسی

List<int> toJalali(int gy, int gm, int gd) {
  const gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  int jy;
  if (gy > 1600) {
    jy = 979;
    gy -= 1600;
  } else {
    jy = 0;
    gy -= 621;
  }
  final gy2 = gm > 2 ? gy + 1 : gy;
  int days = (365 * gy) +
      ((gy2 + 3) ~/ 4) -
      ((gy2 + 99) ~/ 100) +
      ((gy2 + 399) ~/ 400) -
      80 +
      gd +
      gdm[gm - 1];
  jy += 33 * (days ~/ 12053);
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }
  int jm, jd;
  if (days < 186) {
    jm = 1 + days ~/ 31;
    jd = 1 + (days % 31);
  } else {
    jm = 7 + (days - 186) ~/ 30;
    jd = 1 + ((days - 186) % 30);
  }
  return [jy, jm, jd];
}

const List<String> jMonths = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
];
const Map<int, String> _wdLong = {
  1: 'دوشنبه', 2: 'سه‌شنبه', 3: 'چهارشنبه', 4: 'پنجشنبه',
  5: 'جمعه', 6: 'شنبه', 7: 'یکشنبه'
};
const Map<int, String> _wdNarrow = {
  1: 'د', 2: 'س', 3: 'چ', 4: 'پ', 5: 'ج', 6: 'ش', 7: 'ی'
};

String jalaliLong(DateTime d) {
  final j = toJalali(d.year, d.month, d.day);
  return '${_wdLong[d.weekday]} ${fa(j[2])} ${jMonths[j[1] - 1]}';
}

String weekdayNarrow(DateTime d) => _wdNarrow[d.weekday] ?? '';
String jalaliDay(DateTime d) => fa(toJalali(d.year, d.month, d.day)[2]);

// ---------------------------------------------------------------- مدل‌ها

class Task {
  int id;
  String title;
  double u; // فوریت: ۰ تا ۱ (۱ = فوری‌تر، سمت راست)
  double i; // اهمیت: ۰ تا ۱ (۱ = مهم‌تر، بالا)
  int min;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.u,
    required this.i,
    required this.min,
    this.done = false,
  });

  Q get q => i >= .5 ? (u >= .5 ? Q.q1 : Q.q2) : (u >= .5 ? Q.q3 : Q.q4);

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'u': u, 'i': i, 'min': min, 'done': done};

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        title: j['title'] as String,
        u: (j['u'] as num).toDouble(),
        i: (j['i'] as num).toDouble(),
        min: j['min'] as int,
        done: (j['done'] as bool?) ?? false,
      );
}

class LogEntry {
  final String d;
  final Q q;
  final int m;
  final int n;
  final int? tid;
  const LogEntry(this.d, this.q, this.m, this.n, this.tid);

  Map<String, dynamic> toJson() =>
      {'d': d, 'q': q.name, 'm': m, 'n': n, 'tid': tid};

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
        j['d'] as String,
        Q.values.byName(j['q'] as String),
        j['m'] as int,
        (j['n'] as int?) ?? 1,
        j['tid'] as int?,
      );
}

class DayData {
  final DateTime d;
  final Map<Q, int> m;
  final bool today;
  const DayData(this.d, this.m, this.today);
}

// ---------------------------------------------------------------- وضعیت برنامه

class AppState extends ChangeNotifier {
  List<Task> tasks = [];
  List<LogEntry> log = [];
  String focusDate = '';
  int focusMin = 0;
  bool hintSeen = false;
  String? theme; // 'light' | 'dark' | null (پیرو سیستم)
  int nid = 1;
  int tab = 0;
  int? selected;

  static const _key = 'chaharsu.v1';
  SharedPreferences? _prefs;

  ThemeMode get themeMode => theme == 'dark'
      ? ThemeMode.dark
      : (theme == 'light' ? ThemeMode.light : ThemeMode.system);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    var ok = false;
    if (raw != null) {
      try {
        _decode(jsonDecode(raw) as Map<String, dynamic>);
        ok = true;
      } catch (_) {
        ok = false;
      }
    }
    if (!ok) _seed();
    final today = dkey(DateTime.now());
    if (focusDate != today) {
      focusDate = today;
      focusMin = 0;
    }
  }

  void _decode(Map<String, dynamic> j) {
    tasks = (j['tasks'] as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
    log = (j['log'] as List)
        .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    focusDate = (j['focusDate'] as String?) ?? '';
    focusMin = (j['focusMin'] as int?) ?? 0;
    hintSeen = (j['hintSeen'] as bool?) ?? false;
    theme = j['theme'] as String?;
    nid = (j['nid'] as int?) ?? (tasks.length + 1);
  }

  void _seed() {
    final t = <Task>[
      Task(id: 1, title: 'ارسال پیشنهاد به مشتری', u: .78, i: .80, min: 60),
      Task(id: 2, title: 'پرداخت قسط بیمه', u: .72, i: .62, min: 10),
      Task(id: 3, title: 'مطالعه‌ی کتاب', u: .20, i: .68, min: 45),
      Task(id: 4, title: 'ورزش صبحگاهی', u: .30, i: .80, min: 30),
      Task(id: 5, title: 'طرح‌ریزی اهداف فصل', u: .27, i: .56, min: 60),
      Task(id: 6, title: 'پاسخ به ایمیل‌ها', u: .64, i: .36, min: 25),
      Task(id: 7, title: 'هماهنگی جلسه', u: .80, i: .22, min: 15),
      Task(id: 8, title: 'گشتن در شبکه‌های اجتماعی', u: .30, i: .28, min: 20),
    ];
    tasks = t;
    nid = t.length + 1;
    const hist = [
      [90, 30, 40, 20],
      [60, 45, 30, 10],
      [120, 20, 50, 0],
      [70, 60, 25, 15],
      [45, 90, 20, 0],
      [30, 75, 15, 10],
    ];
    final now = DateTime.now();
    final l = <LogEntry>[];
    for (var idx = 0; idx < hist.length; idx++) {
      final day = DateTime(now.year, now.month, now.day - (6 - idx));
      for (var qi = 0; qi < 4; qi++) {
        final m = hist[idx][qi];
        if (m > 0) {
          final n = (m / 25).round();
          l.add(LogEntry(dkey(day), Q.values[qi], m, n < 1 ? 1 : n, null));
        }
      }
    }
    log = l;
    hintSeen = false;
    theme = null;
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setString(
      _key,
      jsonEncode({
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'log': log.map((e) => e.toJson()).toList(),
        'focusDate': focusDate,
        'focusMin': focusMin,
        'hintSeen': hintSeen,
        'theme': theme,
        'nid': nid,
      }),
    );
  }

  void changed() {
    _save();
    notifyListeners();
  }

  // --- پرس‌وجو

  List<Task> get pending => tasks.where((t) => !t.done).toList();

  Task? get nextTask {
    final p = pending;
    if (p.isEmpty) return null;
    p.sort((a, b) {
      final r = a.q.index.compareTo(b.q.index);
      if (r != 0) return r;
      return (b.u + b.i).compareTo(a.u + a.i);
    });
    return p.first;
  }

  Task? byId(int? id) {
    if (id == null) return null;
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  int minutesOf(Q q) =>
      tasks.where((t) => !t.done && t.q == q).fold<int>(0, (a, t) => a + t.min);

  List<DayData> weekDays() {
    final now = DateTime.now();
    final out = <DayData>[];
    for (var k = 6; k >= 0; k--) {
      final d = DateTime(now.year, now.month, now.day - k);
      final key = dkey(d);
      final m = {for (final q in Q.values) q: 0};
      for (final l in log) {
        if (l.d == key) m[l.q] = (m[l.q] ?? 0) + l.m;
      }
      out.add(DayData(d, m, k == 0));
    }
    return out;
  }

  // --- کنش‌ها

  void goTab(int i) {
    tab = i;
    notifyListeners();
  }

  void select(int? id) {
    selected = id;
    notifyListeners();
  }

  void toggleTheme(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    theme = dark ? 'light' : 'dark';
    changed();
  }

  Task addTask(String title, double u, double i, int min) {
    final t = Task(id: nid++, title: title, u: u, i: i, min: min);
    tasks.add(t);
    selected = t.id;
    changed();
    return t;
  }

  void updateTask(int id, String title, double u, double i, int min) {
    final t = byId(id);
    if (t == null) return;
    t.title = title;
    t.u = u;
    t.i = i;
    t.min = min;
    changed();
  }

  void moveTask(int id, double u, double i) {
    final t = byId(id);
    if (t == null) return;
    t.u = u;
    t.i = i;
    hintSeen = true;
    changed();
  }

  void deleteTask(int id) {
    tasks.removeWhere((t) => t.id == id);
    log.removeWhere((l) => l.tid == id);
    if (selected == id) selected = null;
    changed();
  }

  void setDone(int id, bool val) {
    final t = byId(id);
    if (t == null || t.done == val) return;
    t.done = val;
    if (val) {
      log.add(LogEntry(dkey(DateTime.now()), t.q, t.min, 1, t.id));
      toast('«${short(t.title)}» انجام شد');
    } else {
      log.removeWhere((l) => l.tid == id);
    }
    changed();
  }

  void addFocusMinutes(int m) {
    final today = dkey(DateTime.now());
    if (focusDate != today) {
      focusDate = today;
      focusMin = 0;
    }
    focusMin += m;
    changed();
  }
}

// ---------------------------------------------------------------- تمرکز (زمان‌سنج)

class FocusController extends ChangeNotifier {
  int? id;
  int dur = 25;
  int left = 25 * 60;
  int total = 25 * 60;
  bool running = false;
  DateTime? _end;
  Timer? _timer;

  /// اگر کار انتخاب‌شده حذف یا انجام شده باشد، کار بعدی انتخاب می‌شود.
  void ensure() {
    final t = app.byId(id);
    if (t == null || t.done) {
      id = app.nextTask?.id;
    }
  }

  void pick(int newId) {
    if (running) {
      toast('اول جلسه‌ی جاری را متوقف کن.');
      return;
    }
    id = newId;
    left = total = dur * 60;
    notifyListeners();
  }

  void setDur(int m) {
    if (running) {
      toast('اول جلسه‌ی جاری را متوقف کن.');
      return;
    }
    dur = m;
    left = total = m * 60;
    notifyListeners();
  }

  void toggle() {
    if (running) {
      running = false;
      _timer?.cancel();
      notifyListeners();
      return;
    }
    if (id == null) return;
    running = true;
    _end = DateTime.now().add(Duration(seconds: left));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    running = false;
    left = total = dur * 60;
    notifyListeners();
  }

  void _tick() {
    final end = _end;
    if (end == null) return;
    final ms = end.difference(DateTime.now()).inMilliseconds;
    left = ms <= 0 ? 0 : (ms / 1000).ceil();
    if (left <= 0) {
      _timer?.cancel();
      running = false;
      app.addFocusMinutes(dur);
      left = total = dur * 60;
      toast('جلسه‌ی تمرکز تمام شد. دستت درد نکند!');
      HapticFeedback.heavyImpact();
    }
    notifyListeners();
  }
}

final AppState app = AppState();
final FocusController focus = FocusController();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void toast(String msg) {
  final m = messengerKey.currentState;
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500)),
    duration: const Duration(milliseconds: 2400),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ));
}
