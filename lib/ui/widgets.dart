import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import 'motion.dart';

/// সাদা কার্ড (Figma: Elevation/Card)
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = EdgeInsets.zero, this.radius = R.lg, this.color = C.surface, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius), boxShadow: Shadows.card),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: Padding(padding: padding, child: child)),
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: 0.98, child: card);
  }
}

class IconCircle extends StatelessWidget {
  const IconCircle({super.key, this.icon, this.svg, required this.bg, required this.fg, this.size = 44, this.iconSize = 22});
  final IconData? icon;
  final String? svg; // assets/icons/<svg>.svg (Figma আইকন)
  final Color bg;
  final Color fg;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: svg != null ? Ic(svg!, size: iconSize, color: fg) : Icon(icon, color: fg, size: iconSize),
      );
}

/// প্রতি স্ক্রিনে শুধু একটাই PrimaryButton (Figma: Button/Primary)
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.leading});
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final on = onPressed != null;
    return Pressable(onTap: onPressed, child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: on ? C.primary : C.ink200,
        borderRadius: BorderRadius.circular(R.md),
        boxShadow: on ? Shadows.action : null,
      ),
      child: Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Text(label, style: Ty.s(18, FontWeight.w600, color: on ? C.onPrimary : C.ink400)),
        ]),
      ),
    ));
  }
}

/// Figma: Button/Ghost
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onPressed,
        child: SizedBox(height: 56, child: Center(child: Text(label, style: Ty.s(18, FontWeight.w600, color: C.primary)))),
      );
}

/// Figma: Chip (Selected = হালকা নীল, সলিড নীল নয়)
class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.selected = false, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.93,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? C.primaryContainer : (icon != null ? C.primary50 : C.surface),
            borderRadius: BorderRadius.circular(R.full),
            border: Border.all(color: selected || icon != null ? C.primary300 : C.outline, width: selected ? 1.5 : 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: C.primaryStrong), const SizedBox(width: 4)],
            Text(label,
                style: Ty.s(14, selected || icon != null ? FontWeight.w600 : FontWeight.w500,
                    color: selected || icon != null ? C.primaryStrong : C.textSecondary)),
          ]),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.color = C.primary, this.height = 10});
  final double value; // 0..1
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.full),
      child: Container(
        height: height,
        color: C.ink100,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: v),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, x, __) => FractionallySizedBox(
            widthFactor: x,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(R.full))),
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap, this.size = 32, this.bg = C.ink50, this.iconSize = 18});
  final String icon; // svg নাম
  final double iconSize;
  final VoidCallback? onTap;
  final double size;
  final Color bg;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        scale: 0.88,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Ic(icon, size: iconSize, color: C.ink700),
        ),
      );
}

/// সাদা গোল আইকন বাটন (নোটিফিকেশন, ব্যাক ইত্যাদি)
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap});
  final String icon; // svg নাম: left, bell ...
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: Shadows.card),
        child: _RoundBtn(icon: icon, onTap: onTap, size: 40, bg: C.surface, iconSize: icon == 'bell' ? 20 : 18),
      );
}

/// মাস বদলানোর বার: ‹ ২৭ অক্টো – ২৬ নভে ›
class MonthBar extends StatelessWidget {
  const MonthBar({super.key, required this.label, this.sub, required this.onPrev, required this.onNext, this.compact = false, this.canNext = true});
  final String label;
  final String? sub;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool compact;
  final bool canNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(R.full), boxShadow: Shadows.card),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundBtn(icon: 'left', onTap: onPrev),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a), child: c)),
                child: Text(label, key: ValueKey(label), style: Ty.s(14, FontWeight.w600, color: C.hero)),
              ),
              if (sub != null) Text(sub!, style: Ty.s(11, FontWeight.w400, color: C.ink500)),
            ]),
          ),
          Opacity(opacity: canNext ? 1 : 0.35, child: _RoundBtn(icon: 'right', onTap: canNext ? onNext : null)),
        ],
      ),
    );
  }
}

/// লেনদেনের এক লাইন (Figma: Transaction Row — Income / Expense)
class TxRow extends StatelessWidget {
  const TxRow({super.key, required this.tx, this.last = false, this.onTap});
  final Tx tx;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inc = tx.isIncome;
    final sub = tx.note.isEmpty ? dayLabel(tx.date) : '${dayLabel(tx.date)} · ${tx.note}';
    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: C.surface, border: last ? null : const Border(bottom: BorderSide(color: C.surfaceVariant))),
      child: Row(children: [
        IconCircle(
          svg: inc ? 'inn' : 'out',
          bg: inc ? C.green100 : C.red100,
          fg: inc ? C.income : C.expense,
          size: 38,
          iconSize: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.categoryLabel, style: Ty.s(15, FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(sub, style: Ty.s(12, FontWeight.w400, color: C.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 8),
        Text(signedTaka(tx.amountPaisa, inc), style: Ty.s(15, FontWeight.w600, color: inc ? C.income : C.expense)),
      ]),
    );
    if (onTap == null) return row;
    return Pressable(onTap: onTap, scale: 0.98, child: row);
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: warning ? C.amber50 : C.primary50,
        borderRadius: BorderRadius.circular(R.sm),
        border: Border.all(color: warning ? C.amber200 : C.primary200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Ic('info', size: 18, color: warning ? C.amber700 : C.primaryStrong),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Ty.s(13, FontWeight.w400, color: warning ? C.amber800 : C.ink700))),
      ]),
    );
  }
}

/// ভাসমান নেভিগেশন বার (Figma: Bottom Nav 343×68, ট্যাব x: 38, 100, 243, 305; (+) 60px, উপরে -28)
class FloatingNav extends StatelessWidget {
  const FloatingNav({super.key, required this.index, required this.onTap, required this.onAdd, required this.labels});
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;
  final List<String> labels; // home, lenden, report, more

  static const _icons = ['home', 'list', 'chart', 'more'];
  static const _cx = [38.0, 100.0, 243.0, 305.0];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final k = box.maxWidth / 343; // Figma 343px চওড়া
      return SizedBox(
        height: 68 + 28,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 68,
            child: Container(decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(R.full), boxShadow: Shadows.floating)),
          ),
          for (var i = 0; i < 4; i++)
            Positioned(
              left: _cx[i] * k - 33,
              width: 66,
              bottom: 0,
              height: 68,
              child: _NavTab(icon: _icons[i], label: labels[i], active: index == i, onTap: () => onTap(i)),
            ),
          Positioned(
            left: box.maxWidth / 2 - 30,
            top: 0,
            child: Pressable(
              onTap: onAdd,
              scale: 0.88,
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.primary,
                  border: Border.all(color: C.bg, width: 5),
                  boxShadow: Shadows.action,
                ),
                child: const Ic('plus', size: 28),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.icon, required this.label, required this.active, required this.onTap});
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? C.primaryStrong : C.ink500;
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Column(children: [
        const SizedBox(height: 9),
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: active ? C.primaryContainer : C.primaryContainer.withValues(alpha: 0), borderRadius: BorderRadius.circular(R.full)),
          child: AnimatedScale(scale: active ? 1.08 : 1, duration: const Duration(milliseconds: 260), curve: Curves.easeOutBack, child: Ic(icon, size: 22, color: color)),
        ),
        const SizedBox(height: 1),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: Ty.s(11, active ? FontWeight.w700 : FontWeight.w500, color: color).copyWith(height: 16 / 11),
          child: Text(label, maxLines: 1),
        ),
      ]),
    );
  }
}
