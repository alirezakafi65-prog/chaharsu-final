import 'package:flutter/material.dart';

import 'core.dart';
import 'painters.dart';
import 'task_sheet.dart';
import 'widgets.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final p = Pal.of(context);
        final dark = Theme.of(context).brightness == Brightness.dark;
        final pend = app.pending;
        final nt = app.nextTask;
        final total = app.tasks.length;
        final doneN = total - pend.length;
        final segs = {for (final q in Q.values) q: app.minutesOf(q)};
        final totalMin = segs.values.fold<int>(0, (a, b) => a + b);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            // سرآیند
            Row(
              children: [
                const MarkIcon(size: 32),
                const SizedBox(width: 9),
                Text('چهارسو', style: tsx(p.ink, 28, display: true, h: 1.1)),
                const Spacer(),
                RoundBtn(
                  icon: dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 40,
                  bg: p.surface,
                  fg: p.ink,
                  border: p.line,
                  semantic: dark ? 'حالت روشن' : 'حالت تیره',
                  onTap: () => app.toggleTheme(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(jalaliLong(DateTime.now()), style: tsx(p.ink2, 12.5)),

            // کارت اصلی
            const SizedBox(height: 16),
            _Hero(task: nt, doneN: doneN, total: total),

            // نوار زمانی
            const SizedBox(height: 22),
            if (totalMin > 0) ...[
              Row(
                children: [
                  for (final q in Q.values)
                    if ((segs[q] ?? 0) > 0)
                      Expanded(
                        flex: segs[q]!,
                        child: Container(
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                              color: p.fill(q),
                              borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: fmtMin(totalMin),
                    style: tsx(p.ink, 12.5, w: FontWeight.w700)),
                TextSpan(text: ' کار مانده است', style: tsx(p.ink2, 12.5)),
              ])),
            ] else
              Text('کاری باقی نمانده.', style: tsx(p.ink2, 12.5)),

            // فهرست چهار سو
            for (final q in Q.values) _Section(q: q),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  final Task? task;
  final int doneN, total;
  const _Hero({required this.task, required this.doneN, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = task;
    final Widget left;
    if (t != null) {
      final q = t.q;
      left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
            decoration: BoxDecoration(
                color: op(Colors.white, .14),
                borderRadius: BorderRadius.circular(99)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: qBright[q], shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Flexible(
                  child: Text('${qInfo[q]!.name} · ${qInfo[q]!.tag}',
                      style: tsx(Colors.white, 11.5, w: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(t.title, style: tsx(Colors.white, 25, display: true, h: 1.35)),
          const SizedBox(height: 2),
          Text(fmtMin(t.min), style: tsx(op(Colors.white, .8), 12.5)),
          const SizedBox(height: 14),
          Btn(
            label: 'شروع تمرکز',
            icon: Icons.play_arrow_rounded,
            bg: const Color(0xFFFFB81C),
            fg: const Color(0xFF14205B),
            onTap: () {
              focus.pick(t.id);
              app.goTab(2);
            },
          ),
        ],
      );
    } else {
      left = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(total > 0 ? 'همه‌ی کارها انجام شد' : 'چهارسو خالی است',
              style: tsx(Colors.white, 25, display: true, h: 1.35)),
          const SizedBox(height: 4),
          Text(
              total > 0
                  ? 'حالا وقت استراحت است، یا کار تازه‌ای اضافه کن.'
                  : 'اولین کارت را اضافه کن تا روی چهارسو بنشیند.',
              style: tsx(op(Colors.white, .8), 12.5)),
          const SizedBox(height: 14),
          Btn(
            label: 'کار تازه',
            icon: Icons.add_rounded,
            bg: const Color(0xFFFFB81C),
            fg: const Color(0xFF14205B),
            onTap: () => showTaskSheet(context, null),
          ),
        ],
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: p.hero, borderRadius: BorderRadius.circular(28)),
      child: Stack(
        children: [
          Positioned.fill(child: Khatam(op(Colors.white, .06))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 12),
                SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RingPainter(
                              total == 0 ? 0 : doneN / total,
                              const Color(0xFFFFB81C),
                              op(Colors.white, .2),
                              8),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(fa(doneN),
                              style: tsx(Colors.white, 26, display: true, h: 1.1)),
                          Text('از ${fa(total)}',
                              style: tsx(op(Colors.white, .75), 10.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Q q;
  const _Section({required this.q});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final list = app.tasks.where((t) => t.q == q).toList()
      ..sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        return (b.u + b.i).compareTo(a.u + a.i);
      });
    final pmin = list.where((t) => !t.done).fold<int>(0, (a, t) => a + t.min);
    final c = p.fill(q);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsetsDirectional.only(start: 16),
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: c, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(qInfo[q]!.name, style: tsx(p.ink, 21, display: true, h: 1.3)),
              const SizedBox(width: 8),
              Text(qInfo[q]!.tag, style: tsx(p.ink2, 12)),
              const Spacer(),
              if (pmin > 0) Text(fmtMin(pmin), style: tsx(p.ink2, 11.5)),
            ],
          ),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(qInfo[q]!.empty, style: tsx(p.ink2, 12.5)),
            )
          else
            for (var i = 0; i < list.length; i++)
              _Row(task: list[i], last: i == list.length - 1),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final Task task;
  final bool last;
  const _Row({required this.task, required this.last});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final t = task;
    final c = p.fill(t.q);
    final faded = t.done ? .5 : 1.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: op(p.line, .9), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => app.setDone(t.id, !t.done),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.done ? c : Colors.transparent,
                    border: Border.all(color: c, width: 2.5),
                  ),
                  child: t.done
                      ? Icon(Icons.check_rounded, size: 16, color: p.bg)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showTaskSheet(context, t),
              child: Opacity(
                opacity: faded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: tsx(p.ink, 14.5,
                            w: FontWeight.w500,
                            h: 1.5,
                            deco: t.done ? TextDecoration.lineThrough : null)),
                    Text(fmtMin(t.min), style: tsx(p.ink2, 11.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
