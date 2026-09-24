import 'package:flutter/material.dart';

import 'core.dart';
import 'painters.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final p = Pal.of(context);
        final days = app.weekDays();
        final keys = days.map((d) => dkey(d.d)).toSet();
        final tot = {for (final q in Q.values) q: 0};
        for (final d in days) {
          for (final q in Q.values) {
            tot[q] = (tot[q] ?? 0) + (d.m[q] ?? 0);
          }
        }
        final all = tot.values.fold<int>(0, (a, b) => a + b);
        double share(Q q) => all == 0 ? 0 : (tot[q] ?? 0) / all;
        final bal = (share(Q.q2) * 100).round();

        final done7 = app.log
            .where((l) => keys.contains(l.d))
            .fold<int>(0, (a, l) => a + l.n);
        Q? topQ;
        if (all > 0) {
          topQ = Q.q1;
          for (final q in Q.values) {
            if ((tot[q] ?? 0) > (tot[topQ!] ?? 0)) topQ = q;
          }
        }

        final String verdict;
        if (all == 0) {
          verdict = 'هنوز کاری ثبت نشده. با تکمیل کارها، گلیم هفته بافته می‌شود.';
        } else if (share(Q.q2) >= .4) {
          verdict = 'تعادل خوبی داری: بیشتر وقتت صرف کارهای مهمِ برنامه‌ریزی‌شده شد.';
        } else if (share(Q.q1) > .45) {
          verdict =
              'بیشتر وقتت صرف کارهای آتشین شد. هر روز نیم‌ساعت برای «برنامه بریز» کنار بگذار تا آتش کمتر شود.';
        } else if (share(Q.q3) + share(Q.q4) > .35) {
          verdict =
              'سهم بزرگی از وقتت به کارهای کم‌اهمیت رفت. ببین کدام را می‌شود سپرد یا حذف کرد.';
        } else {
          verdict = 'نزدیک تعادل هستی. سهم «برنامه بریز» را کمی بالاتر ببر.';
        }

        Widget card(List<Widget> children) => Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: p.line, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Text('آمار هفته', style: tsx(p.ink, 30, display: true, h: 1.2)),
            Text('وقتت این هفته کجا خرج شد؟', style: tsx(p.ink2, 13)),

            card([
              Text('شاخص تعادل', style: tsx(p.ink, 21, display: true, h: 1.3)),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: DonutPainter(
                              values: {
                                for (final q in Q.values)
                                  q: (tot[q] ?? 0).toDouble()
                              },
                              colors: p.fills,
                              track: p.line,
                              stroke: 13,
                              gap: 4,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${fa(bal)}٪',
                                style: tsx(p.ink, 30, display: true, h: 1)),
                            Text('برنامه بریز', style: tsx(p.ink2, 10.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(verdict, style: tsx(p.ink, 13.5, h: 1.85)),
                  ),
                ],
              ),
            ]),

            card([
              Text('گلیم هفته', style: tsx(p.ink, 21, display: true, h: 1.3)),
              Text('هر لوزی، وقتی است که آن روز صرف آن سو شد.',
                  style: tsx(p.ink2, 13)),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: WeavePainter.w / WeavePainter.h,
                child: CustomPaint(painter: WeavePainter(days, p)),
              ),
            ]),

            // نوار آمار کوتاه
            Container(
              margin: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: p.line, width: 1.5),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Stat(value: fa(done7), label: 'کار انجام‌شده'),
                    VerticalDivider(width: 1.5, thickness: 1.5, color: p.line),
                    _Stat(value: fa(app.focusMin), label: 'دقیقه تمرکز امروز'),
                    VerticalDivider(width: 1.5, thickness: 1.5, color: p.line),
                    _Stat(
                        value: topQ == null ? '—' : qInfo[topQ]!.name,
                        label: 'پرکارترین سو'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: tsx(p.ink, 22, display: true, h: 1.3)),
            Text(label,
                textAlign: TextAlign.center, style: tsx(p.ink2, 11.5)),
          ],
        ),
      ),
    );
  }
}
