import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core.dart';
import 'painters.dart';
import 'task_sheet.dart';
import 'widgets.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  final GlobalKey _planeKey = GlobalKey();
  int? _dragId;
  double _du = 0, _di = 0;

  double _clamp(double v, double a, double b) => v < a ? a : (v > b ? b : v);

  void _update(Offset global) {
    final box = _planeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _dragId == null) return;
    final local = box.globalToLocal(global);
    setState(() {
      _du = _clamp(local.dx / box.size.width, .12, .88);
      _di = _clamp(1 - local.dy / box.size.height, .18, .82);
    });
  }

  void _end() {
    final id = _dragId;
    if (id == null) return;
    final t = app.byId(id);
    final before = t?.q;
    setState(() => _dragId = null);
    if (t != null) {
      app.moveTask(id, _du, _di);
      if (t.q != before) {
        toast('«${short(t.title)}» حالا در «${qInfo[t.q]!.name}» است');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final p = Pal.of(context);
        return LayoutBuilder(builder: (context, cons) {
          final w = cons.maxWidth - 36;
          final avail = cons.maxHeight - 262;
          final h = math.min(w * 1.1, math.max(avail, 240.0));
          final pend = app.pending;
          final vals = {
            for (final q in Q.values) q: app.minutesOf(q).toDouble()
          };

          Q? hot;
          final dt = app.byId(_dragId);
          if (dt != null) {
            hot = _du >= .5
                ? (_di >= .5 ? Q.q1 : Q.q3)
                : (_di >= .5 ? Q.q2 : Q.q4);
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('چهارسو', style: tsx(p.ink, 30, display: true, h: 1.2)),
                Text('جایگاه هر کار روی صفحه، اولویت آن است.',
                    style: tsx(p.ink2, 13)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('فوری', style: tsx(p.ink2, 12, w: FontWeight.w500)),
                    const SizedBox(width: 10),
                    Expanded(child: Container(height: 1.5, color: p.line)),
                    const SizedBox(width: 10),
                    Text('غیرفوری', style: tsx(p.ink2, 12, w: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                // صفحه‌ی ماتریس
                Container(
                  key: _planeKey,
                  width: w,
                  height: h,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: p.line, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => app.select(null),
                          child: QuadGrid(w: w, h: h, hot: hot),
                        ),
                      ),
                      // حلقه‌ی وسط: سهم زمانی هر سو
                      Positioned(
                        left: w / 2 - 35,
                        top: h / 2 - 35,
                        width: 70,
                        height: 70,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                                color: p.surface, shape: BoxShape.circle),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: DonutPainter(
                                      values: vals,
                                      colors: p.fills,
                                      track: p.line,
                                      stroke: 8,
                                      gap: 4,
                                    ),
                                  ),
                                ),
                                Text(fa(pend.length),
                                    style: tsx(p.ink, 19, display: true, h: 1)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // چیپ‌ها
                      for (final t in app.tasks) _chip(t, p, w, h),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Detail(),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _chip(Task t, Pal p, double w, double h) {
    final dragging = _dragId == t.id;
    final u = dragging ? _du : t.u;
    final i = dragging ? _di : t.i;
    final q = dragging
        ? (u >= .5 ? (i >= .5 ? Q.q1 : Q.q2) : (i >= .5 ? Q.q3 : Q.q4))
        : t.q;
    final c = p.fill(q);
    final sel = app.selected == t.id;

    return Positioned(
      key: ValueKey('chip-${t.id}'),
      left: u * w,
      top: (1 - i) * h,
      child: FractionalTranslation(
        translation: const Offset(-.5, -.5),
        child: GestureDetector(
          onTap: () => app.select(t.id),
          onPanStart: (_) {
            setState(() {
              _dragId = t.id;
              _du = t.u;
              _di = t.i;
            });
          },
          onPanUpdate: (d) => _update(d.globalPosition),
          onPanEnd: (_) => _end(),
          onPanCancel: _end,
          child: AnimatedScale(
            scale: dragging ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Opacity(
              opacity: t.done ? .5 : 1,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 142),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c, width: 2),
                  boxShadow: sel || dragging
                      ? [
                          BoxShadow(
                              color: op(c, .35),
                              spreadRadius: 4,
                              blurRadius: 0),
                        ]
                      : const [
                          BoxShadow(
                              color: Color(0x4014205B),
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        short(t.title, 26),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tsx(p.ink, 11.5,
                            w: FontWeight.w700,
                            h: 1.4,
                            deco: t.done ? TextDecoration.lineThrough : null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = app.byId(app.selected);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line, width: 1.5),
      ),
      child: t == null
          ? Row(
              children: [
                Icon(Icons.open_with_rounded, size: 26, color: p.ink2),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    app.hintSeen
                        ? 'یک کار را لمس کن تا گزینه‌هایش را ببینی.'
                        : 'هر کار را با انگشت بکش و روی سوی دیگر رها کن؛ اولویتش همان‌جا عوض می‌شود.',
                    style: tsx(p.ink2, 13, h: 1.6),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: p.fill(t.q),
                              borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tsx(p.ink, 15, w: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${qInfo[t.q]!.name} · ${qInfo[t.q]!.tag} · ${fmtMin(t.min)}',
                    style: tsx(p.ink2, 12.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Btn(
                        label: t.done ? 'برگردان' : 'انجام شد',
                        bg: p.btn,
                        fg: p.btnInk,
                        expand: true,
                        onTap: () => app.setDone(t.id, !t.done),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Btn(
                        label: 'تمرکز',
                        bg: p.surface,
                        fg: p.ink,
                        border: p.line,
                        expand: true,
                        onTap: () {
                          focus.pick(t.id);
                          app.goTab(2);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Btn(
                        label: 'ویرایش',
                        bg: p.surface,
                        fg: p.ink,
                        border: p.line,
                        expand: true,
                        onTap: () => showTaskSheet(context, t),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
