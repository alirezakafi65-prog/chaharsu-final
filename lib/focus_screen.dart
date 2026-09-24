import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core.dart';
import 'painters.dart';
import 'task_sheet.dart';
import 'widgets.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([app, focus]),
      builder: (context, _) {
        final p = Pal.of(context);
        focus.ensure();
        final t = app.byId(focus.id);
        final pend = app.pending
          ..sort((a, b) => a.q.index.compareTo(b.q.index));

        final header = <Widget>[
          Text('تمرکز', style: tsx(p.ink, 30, display: true, h: 1.2)),
          Text('یک کار، یک زمان‌سنج، بدون حواس‌پرتی.', style: tsx(p.ink2, 13)),
        ];

        if (t == null) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              ...header,
              const SizedBox(height: 40),
              Center(
                child: Text('کار باقی‌مانده‌ای نیست.',
                    style: tsx(p.ink2, 14)),
              ),
              const SizedBox(height: 18),
              Center(
                child: Btn(
                  label: 'کار تازه',
                  icon: Icons.add_rounded,
                  bg: p.btn,
                  fg: p.btnInk,
                  onTap: () => showTaskSheet(context, null),
                ),
              ),
            ],
          );
        }

        final q = t.q;
        final c = p.fill(q);
        final frac = focus.total == 0 ? 0.0 : focus.left / focus.total;
        final ringSize = math.min(300.0, MediaQuery.of(context).size.width - 60);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            ...header,
            const SizedBox(height: 16),
            // انتخاب کار
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final x in pend)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: _PickChip(task: x, selected: x.id == focus.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // حلقه
            Center(
              child: SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                          painter: FocusRingPainter(frac, c, p.line)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${two(focus.left ~/ 60)}:${two(focus.left % 60)}',
                            style: tsx(p.ink, 64, display: true, h: 1),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: ringSize * .5,
                          child: Text(t.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tsx(p.ink2, 12.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // مدت جلسه
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final m in const [15, 25, 50])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => focus.setDur(m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: focus.dur == m ? p.btn : p.surface,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: focus.dur == m ? p.btn : p.line,
                              width: 1.5),
                        ),
                        child: Text('${fa(m)} دقیقه',
                            style: tsx(focus.dur == m ? p.btnInk : p.ink, 13,
                                w: focus.dur == m
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            // کنترل‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Ctl(
                  label: 'از اول',
                  child: RoundBtn(
                    icon: Icons.replay_rounded,
                    bg: p.surface,
                    fg: p.ink2,
                    border: p.line,
                    semantic: 'از اول',
                    onTap: focus.reset,
                  ),
                ),
                const SizedBox(width: 22),
                RoundBtn(
                  icon: focus.running
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 80,
                  bg: p.btn,
                  fg: p.btnInk,
                  semantic: focus.running ? 'توقف' : 'شروع',
                  onTap: focus.toggle,
                ),
                const SizedBox(width: 22),
                _Ctl(
                  label: 'انجام شد',
                  child: RoundBtn(
                    icon: Icons.check_rounded,
                    bg: p.surface,
                    fg: p.ink2,
                    border: p.line,
                    semantic: 'انجام شد',
                    onTap: () {
                      final id = focus.id;
                      if (id == null) return;
                      focus.reset();
                      app.setDone(id, true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'تمرکز امروز: ', style: tsx(p.ink2, 13)),
                TextSpan(
                    text: fmtMin(app.focusMin),
                    style: tsx(p.ink, 13, w: FontWeight.w700)),
              ])),
            ),
          ],
        );
      },
    );
  }
}

class _Ctl extends StatelessWidget {
  final String label;
  final Widget child;
  const _Ctl({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          child,
          const SizedBox(height: 4),
          Text(label, style: tsx(p.ink2, 11.5)),
        ],
      ),
    );
  }
}

class _PickChip extends StatelessWidget {
  final Task task;
  final bool selected;
  const _PickChip({required this.task, required this.selected});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = p.fill(task.q);
    return GestureDetector(
      onTap: () => focus.pick(task.id),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Color.alphaBlend(op(c, .3), p.surface) : p.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: c, width: 2),
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
              child: Text(task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tsx(p.ink, 12.5,
                      w: selected ? FontWeight.w700 : FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
