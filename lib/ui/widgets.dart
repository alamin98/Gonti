import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/models.dart';

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
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius), boxShadow: Shadows.card),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      ),
    );
  }
}

class IconCircle extends StatelessWidget {
  const IconCircle({super.key, required this.icon, required this.bg, required this.fg, this.size = 44, this.iconSize = 22});
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: iconSize),
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
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: on ? C.primary : C.ink200,
        borderRadius: BorderRadius.circular(R.md),
        boxShadow: on ? Shadows.action : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(R.md),
          onTap: onPressed,
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Text(label, style: Ty.s(18, FontWeight.w600, color: on ? C.onPrimary : C.ink400)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Figma: Button/Ghost
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.md))),
          child: Text(label, style: Ty.s(18, FontWeight.w600, color: C.primary)),
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(R.full),
        onTap: onTap,
        child: Container(
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
        child: FractionallySizedBox(widthFactor: v, child: Container(color: color)),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap, this.size = 36, this.bg = C.ink50});
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color bg;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: C.ink700),
        ),
      );
}

/// সাদা গোল আইকন বাটন (নোটিফিকেশন, ব্যাক ইত্যাদি)
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: Shadows.card),
        child: _RoundBtn(icon: icon, onTap: onTap, size: 40, bg: C.surface),
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
      padding: EdgeInsets.all(compact ? 4 : 6),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(R.full), boxShadow: Shadows.card),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: Ty.s(15, FontWeight.w600)),
              if (sub != null) Text(sub!, style: Ty.s(11, FontWeight.w400, color: C.ink500)),
            ]),
          ),
          Opacity(opacity: canNext ? 1 : 0.35, child: _RoundBtn(icon: Icons.chevron_right_rounded, onTap: canNext ? onNext : null)),
        ],
      ),
    );
  }
}

/// লেনদেনের এক লাইন (Figma: Transaction Row — Income / Expense)
class TxRow extends StatelessWidget {
  const TxRow({super.key, required this.tx, this.last = false});
  final Tx tx;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final inc = tx.isIncome;
    final sub = tx.note.isEmpty ? dayLabel(tx.date) : '${dayLabel(tx.date)} · ${tx.note}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: C.surfaceVariant))),
      child: Row(children: [
        IconCircle(
          icon: inc ? Icons.south_west_rounded : Icons.north_east_rounded,
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
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning ? C.amber50 : C.primary50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warning ? C.amber200 : C.primary200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, size: 18, color: warning ? C.amber700 : C.primaryStrong),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Ty.s(13, FontWeight.w400, color: warning ? C.amber800 : C.ink700))),
      ]),
    );
  }
}

/// ভাসমান নেভিগেশন বার (Figma: Bottom Nav) — মাঝে (+) বাটন
class FloatingNav extends StatelessWidget {
  const FloatingNav({super.key, required this.index, required this.onTap, required this.onAdd, required this.labels});
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;
  final List<String> labels; // home, lenden, report, more

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.home_rounded, Icons.format_list_bulleted_rounded, Icons.bar_chart_rounded, Icons.grid_view_rounded];
    Widget tab(int i) => Expanded(child: _NavTab(icon: icons[i], label: labels[i], active: index == i, onTap: () => onTap(i)));
    return SizedBox(
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 68,
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(34), boxShadow: Shadows.floating),
            child: Row(children: [tab(0), tab(1), const SizedBox(width: 84), tab(2), tab(3)]),
          ),
          Positioned(
            top: -5,
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.primary,
                  border: Border.all(color: C.bg, width: 5),
                  boxShadow: Shadows.action,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? C.primaryStrong : C.ink500;
    return InkResponse(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 52,
          height: 30,
          decoration: BoxDecoration(color: active ? C.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, size: 22, color: color),
        ),
        Text(label, style: Ty.s(11, active ? FontWeight.w700 : FontWeight.w500, color: color)),
      ]),
    );
  }
}
