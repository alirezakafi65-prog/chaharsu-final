import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core.dart';

/// نشان چهارگلبرگ چهارسو (شبکه‌ی ۵۱۲، محدوده‌ی ۵۶ تا ۴۵۶)
class MarkPainter extends CustomPainter {
  final Map<Q, Color> colors;
  final Color dot;
  const MarkPainter(this.colors, this.dot);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 400;
    canvas.save();
    canvas.scale(k);
    canvas.translate(-56, -56);
    for (final q in Q.values) {
      final sx = sxOf(q), sy = syOf(q);
      final paint = Paint()
        ..color = colors[q]!
        ..isAntiAlias = true;
      final cx = 256 + sx * 97, cy = 256 + sy * 97;
      canvas.drawCircle(Offset(cx, cy), 85, paint);
      canvas.drawRect(
          Rect.fromPoints(Offset(256 + sx * 12, 256 + sy * 12), Offset(cx, cy)),
          paint);
    }
    canvas.drawCircle(const Offset(256, 256), 16, Paint()..color = dot);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MarkPainter old) =>
      old.colors != colors || old.dot != dot;
}

class MarkIcon extends StatelessWidget {
  final double size;
  const MarkIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: MarkPainter(p.fills, p.ink)),
    );
  }
}

/// حلقه‌ی چندرنگ (سهم زمانی هر سو)
class DonutPainter extends CustomPainter {
  final Map<Q, double> values;
  final Map<Q, Color> colors;
  final Color track;
  final double stroke;
  final double gap;
  const DonutPainter({
    required this.values,
    required this.colors,
    required this.track,
    required this.stroke,
    this.gap = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = track);
    var total = 0.0;
    for (final q in Q.values) {
      total += values[q] ?? 0;
    }
    if (total <= 0) return;
    var start = -math.pi / 2;
    final gapA = gap / r;
    for (final q in Q.values) {
      final v = values[q] ?? 0;
      if (v <= 0) continue;
      final sweep = v / total * 2 * math.pi;
      final s = math.max(sweep - gapA, 0.02);
      canvas.drawArc(
          rect,
          start,
          s,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = colors[q]!);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) => true;
}

/// حلقه‌ی پیشرفت ساده
class RingPainter extends CustomPainter {
  final double pct;
  final Color color, track;
  final double stroke;
  const RingPainter(this.pct, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = (size.width - stroke) / 2;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = track);
    if (pct <= 0) return;
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * pct.clamp(0.0, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color);
  }

  @override
  bool shouldRepaint(covariant RingPainter old) => true;
}

/// حلقه‌ی تمرکز با ۶۰ خط تیک
class FocusRingPainter extends CustomPainter {
  final double frac; // نسبت زمان باقی‌مانده
  final Color color, track;
  const FocusRingPainter(this.frac, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    final c = size.center(Offset.zero);
    final lit = (60 * frac).ceil();
    for (var k = 0; k < 60; k++) {
      final a = -math.pi / 2 + k * math.pi / 30;
      final long = k % 5 == 0;
      final r1 = 130 * s, r2 = (long ? 142 : 138) * s;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
          c + dir * r1,
          c + dir * r2,
          Paint()
            ..strokeWidth = 2 * s
            ..strokeCap = StrokeCap.round
            ..color = k < lit ? color : track);
    }
    final r = 112 * s;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14 * s
          ..color = track);
    if (frac > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          -math.pi / 2,
          2 * math.pi * frac.clamp(0.0, 1.0),
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 14 * s
            ..strokeCap = StrokeCap.round
            ..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant FocusRingPainter old) => true;
}

/// الگوی ختایی (ستاره‌ی هشت‌پر) که به‌صورت کاشی تکرار می‌شود
class KhatamPainter extends CustomPainter {
  final Color color;
  const KhatamPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    for (var y = 0.0; y < size.height; y += 36) {
      for (var x = 0.0; x < size.width; x += 36) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawRect(Rect.fromLTWH(9, 9, 18, 18), p);
        canvas.translate(18, 18);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(Rect.fromLTWH(-9, -9, 18, 18), p);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant KhatamPainter old) => old.color != color;
}

class Khatam extends StatelessWidget {
  final Color color;
  const Khatam(this.color, {super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ClipRect(
          child: CustomPaint(
              painter: KhatamPainter(color), size: Size.infinite),
        ),
      );
}

void drawText(Canvas c, String text, double x, double y, TextStyle style,
    {bool end = false}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.rtl,
  )..layout();
  final base = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  final dx = end ? x - tp.width : x - tp.width / 2;
  tp.paint(c, Offset(dx, y - base));
}

/// «گلیم هفته»: جدول ۴×۷ از لوزی‌هایی که اندازه‌شان وقت صرف‌شده را نشان می‌دهد
class WeavePainter extends CustomPainter {
  final List<DayData> days;
  final Pal pal;
  const WeavePainter(this.days, this.pal);

  static const double w = 340, lw = 86, cw = 36, rh = 50, top = 62;
  static const double h = top + rh * 4 + 26;

  void _diamond(Canvas c, double x, double y, double r, Paint p) {
    final path = Path()
      ..moveTo(x, y - r)
      ..lineTo(x + r, y)
      ..lineTo(x, y + r)
      ..lineTo(x - r, y)
      ..close();
    c.drawPath(path, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / w);
    double cx(int j) => w - lw - (j + .5) * cw;

    // حاشیه‌ی گلیم
    for (var k = 0; k < 28; k++) {
      final x = 6.0 + k * 12;
      final p = Paint()..color = op(pal.ink2, k.isOdd ? .28 : .6);
      _diamond(canvas, x, 8, 4, p);
      _diamond(canvas, x, h - 8, 4, p);
    }

    final totals = {for (final q in Q.values) q: 0};
    for (final d in days) {
      for (final q in Q.values) {
        totals[q] = (totals[q] ?? 0) + (d.m[q] ?? 0);
      }
    }

    for (var j = 0; j < days.length; j++) {
      final d = days[j];
      if (d.today) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(cx(j) - cw / 2 + 2, 20, cw - 4, top - 24 + rh * 4),
                const Radius.circular(14)),
            Paint()..color = op(pal.ink, .07));
      }
      drawText(canvas, weekdayNarrow(d.d), cx(j), 38,
          tsx(pal.ink, 12, w: d.today ? FontWeight.w800 : FontWeight.w500));
      drawText(canvas, jalaliDay(d.d), cx(j), 54, tsx(pal.ink2, 10));
    }

    for (var r = 0; r < 4; r++) {
      final q = Q.values[r];
      final cy = top + 6 + (r + .5) * rh;
      _diamond(canvas, w - 12, cy - 8, 6, Paint()..color = pal.fill(q));
      drawText(canvas, qInfo[q]!.name, w - 22, cy - 3,
          tsx(pal.ink, 12, w: FontWeight.w700),
          end: true);
      drawText(canvas, '${fa(totals[q] ?? 0)} دقیقه', w - 22, cy + 12,
          tsx(pal.ink2, 10),
          end: true);
      for (var j = 0; j < days.length; j++) {
        final m = days[j].m[q] ?? 0;
        final x = cx(j), y = cy - 6;
        if (m <= 0) {
          canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = pal.line);
          continue;
        }
        final hh = 4 + 14 * math.sqrt(math.min(m, 120) / 120);
        _diamond(canvas, x, y, hh, Paint()..color = pal.fill(q));
        _diamond(canvas, x, y, hh * .42, Paint()..color = op(pal.surface, .55));
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeavePainter old) => true;
}
