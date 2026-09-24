import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core.dart';
import 'widgets.dart';

Future<void> showTaskSheet(BuildContext context, Task? task) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskSheet(task: task),
  );
}

class TaskSheet extends StatefulWidget {
  final Task? task;
  const TaskSheet({super.key, this.task});

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.task?.title ?? '');
  late double _u = widget.task?.u ?? .32;
  late double _i = widget.task?.i ?? .7;
  late int _min = widget.task?.min ?? 30;
  String? _err;
  bool _padActive = false;

  Q get _q => _i >= .5 ? (_u >= .5 ? Q.q1 : Q.q2) : (_u >= .5 ? Q.q3 : Q.q4);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _setPos(Offset o, double w, double h) {
    setState(() {
      _u = (o.dx / w).clamp(.04, .96).toDouble();
      _i = (1 - o.dy / h).clamp(.04, .96).toDouble();
    });
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _err = 'عنوان کار را بنویس.');
      return;
    }
    final t = widget.task;
    if (t == null) {
      final nt = app.addTask(title, _u, _i, _min);
      toast('به «${qInfo[nt.q]!.name}» اضافه شد');
    } else {
      app.updateTask(t.id, title, _u, _i, _min);
      toast('ذخیره شد');
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    final t = widget.task;
    if (t == null) return;
    app.deleteTask(t.id);
    Navigator.of(context).pop();
    toast('حذف شد');
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final q = _q;
    final t = widget.task;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: p.line, width: 1.5),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: _padActive
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                      color: p.line, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 12),
              Text(t == null ? 'کار تازه' : 'ویرایش کار',
                  style: tsx(p.ink, 24, display: true, h: 1.3)),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                autofocus: t == null,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.done,
                inputFormatters: [LengthLimitingTextInputFormatter(60)],
                onChanged: (_) {
                  if (_err != null) setState(() => _err = null);
                },
                onSubmitted: (_) => _save(),
                style: tsx(p.ink, 16),
                decoration: InputDecoration(
                  hintText: 'چه کاری باید انجام شود؟',
                  hintStyle: tsx(p.ink2, 15),
                  filled: true,
                  fillColor: p.surface2,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: p.ink, width: 2),
                  ),
                ),
              ),
              if (_err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_err!, style: tsx(p.q1t, 12.5)),
                ),
              const SizedBox(height: 14),
              Text('جایگاهش را روی چهارسو بگذار: بالا مهم‌تر، سمت راست فوری‌تر.',
                  style: tsx(p.ink2, 12.5)),
              const SizedBox(height: 8),
              LayoutBuilder(builder: (context, cons) {
                final w = cons.maxWidth;
                final h = w * .78;
                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) {
                    setState(() => _padActive = true);
                    _setPos(e.localPosition, w, h);
                  },
                  onPointerMove: (e) => _setPos(e.localPosition, w, h),
                  onPointerUp: (_) => setState(() => _padActive = false),
                  onPointerCancel: (_) => setState(() => _padActive = false),
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.line, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            QuadGrid(w: w, h: h, hot: q, small: true),
                            Positioned(
                              left: _u * w - 15,
                              top: (1 - _i) * h - 15,
                              width: 30,
                              height: 30,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: p.fill(q),
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.white, width: 4),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x66000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 4)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Row(
                children: [
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: p.fill(q),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: qInfo[q]!.name,
                          style: tsx(p.ink, 13.5, w: FontWeight.w700)),
                      TextSpan(
                          text: ' · ${qInfo[q]!.verdict}',
                          style: tsx(p.ink, 13.5)),
                    ])),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('چقدر طول می‌کشد؟', style: tsx(p.ink2, 12.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in const [10, 15, 30, 45, 60, 90])
                    GestureDetector(
                      onTap: () => setState(() => _min = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _min == m ? p.btn : p.surface2,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: _min == m ? p.btn : p.line, width: 1.5),
                        ),
                        child: Text('${fa(m)} دقیقه',
                            style: tsx(_min == m ? p.btnInk : p.ink, 13,
                                w: _min == m ? FontWeight.w700 : FontWeight.w500)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Btn(
                      label: t == null ? 'افزودن به چهارسو' : 'ذخیره',
                      bg: p.btn,
                      fg: p.btnInk,
                      expand: true,
                      onTap: _save,
                    ),
                  ),
                  if (t != null) ...[
                    const SizedBox(width: 10),
                    Btn(
                      label: 'حذف',
                      bg: p.surface,
                      fg: p.q1t,
                      border: p.line,
                      onTap: _delete,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
