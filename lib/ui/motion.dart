import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma এর আইকন (assets/icons/*.svg)। রং বদলানো যায়।
class Ic extends StatelessWidget {
  const Ic(this.name, {super.key, this.size = 22, this.color});
  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/icons/$name.svg',
        width: size,
        height: size,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
}

/// চাপ দিলে একটু ছোট হয়ে আবার ফিরে আসে (সব বাটন/কার্ডে একই অনুভূতি)।
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.onLongPress, this.scale = 0.96, this.haptic = true});
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Duration(milliseconds: _down ? 90 : 220),
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// নতুন স্ক্রিন: হালকা fade + নিচ থেকে উঠে আসা।
Route<T> fadeRoute<T>(Widget page, {bool fullscreenDialog = false}) => PageRouteBuilder<T>(
      fullscreenDialog: fullscreenDialog,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: c,
          child: SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(c), child: child),
        );
      },
    );

/// লিস্ট/কার্ড একটার পর একটা ভেসে আসে (index অনুযায়ী দেরি)।
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.index = 0, this.dy = 16});
  final Widget child;
  final int index;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 70),
      curve: Interval((index * 70) / (420 + index * 70), 1, curve: Curves.easeOutCubic),
      builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: c)),
      child: child,
    );
  }
}

/// Figma ডিজাইন 375px চওড়া ফোনে করা। বড় ফোনে (যেমন 411px) সবকিছু ছোট দেখায়,
/// তাই পুরো অ্যাপটা ফোনের চওড়া অনুযায়ী একটু বড় করে দেখানো হয় — Figma এর অনুপাত ঠিক থাকে।
class DesignScale extends StatelessWidget {
  const DesignScale({super.key, required this.child});
  final Widget child;
  static const designWidth = 375.0;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = (mq.size.width / designWidth).clamp(1.0, 1.2);
    if (scale <= 1.01) return child;
    final logical = mq.size / scale;
    return FittedBox(
      fit: BoxFit.fill,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: logical.width,
        height: logical.height,
        child: MediaQuery(
          data: mq.copyWith(
            size: logical,
            devicePixelRatio: mq.devicePixelRatio * scale,
            padding: mq.padding / scale,
            viewPadding: mq.viewPadding / scale,
            viewInsets: mq.viewInsets / scale,
            systemGestureInsets: mq.systemGestureInsets / scale,
          ),
          child: child,
        ),
      ),
    );
  }
}
