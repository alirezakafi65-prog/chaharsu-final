import 'package:flutter/material.dart';

import 'core.dart';
import 'painters.dart';

class Btn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color bg, fg;
  final Color? border;
  final VoidCallback onTap;
  final bool expand;

  const Btn({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.icon,
    this.border,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(14);
    return Material(
      color: bg,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: border == null
              ? null
              : BoxDecoration(
                  border: Border.all(color: border!, width: 1.5),
                  borderRadius: r),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: tsx(fg, 13.5, w: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color bg, fg;
  final Color? border;
  final VoidCallback onTap;
  final String? semantic;

  const RoundBtn({
    super.key,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.size = 52,
    this.border,
    this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantic,
      child: Material(
        color: bg,
        shape: CircleBorder(
            side: border == null
                ? BorderSide.none
                : BorderSide(color: border!, width: 1.5)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * .44, color: fg),
          ),
        ),
      ),
    );
  }
}

/// شبکه‌ی چهار سو با الگوی ختایی. موقعیت‌ها فیزیکی‌اند:
/// q1 بالا-راست، q2 بالا-چپ، q3 پایین-راست، q4 پایین-چپ.
class QuadGrid extends StatelessWidget {
  final double w, h;
  final Q? hot;
  final bool small;

  const QuadGrid({
    super.key,
    required this.w,
    required this.h,
    this.hot,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final qw = w / 2, qh = h / 2;

    Widget quad(Q q) {
      final c = p.fill(q);
      final top = syOf(q) < 0;
      final right = sxOf(q) > 0;
      final ta = right ? TextAlign.right : TextAlign.left;
      return Positioned(
        left: right ? qw : 0,
        top: top ? 0 : qh,
        width: qw,
        height: qh,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                  color: Color.alphaBlend(op(c, hot == q ? .26 : .11), p.surface)),
            ),
            Positioned.fill(child: Khatam(op(c, .2))),
            Align(
              alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(small ? 8 : 10),
                child: IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(qInfo[q]!.name,
                          textAlign: ta,
                          style: tsx(p.text(q), small ? 15 : 19,
                              display: true, h: 1.2)),
                      Text(qInfo[q]!.tag,
                          textAlign: ta,
                          style: tsx(p.ink2, small ? 9.5 : 10.5)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          for (final q in Q.values) quad(q),
          Positioned(
              left: w / 2 - 1.5,
              top: 0,
              bottom: 0,
              width: 3,
              child: ColoredBox(color: p.surface)),
          Positioned(
              top: h / 2 - 1.5,
              left: 0,
              right: 0,
              height: 3,
              child: ColoredBox(color: p.surface)),
        ],
      ),
    );
  }
}
