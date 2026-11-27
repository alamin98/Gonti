import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/format.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../state/app_state.dart';

RoundedRectangleBorder get dialogShape => RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xl));

/// মাসের বাজেট ঠিক করার ডায়ালগ (Home ও Settings দুই জায়গা থেকেই খোলে)
Future<void> showBudgetDialog(BuildContext context) async {
  final state = context.read<AppState>();
  final ctrl = TextEditingController(text: state.budgetPaisa > 0 ? (state.budgetPaisa ~/ 100).toString() : '');
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: dialogShape,
      title: Text(t('budget_set'), style: Ty.s(18, FontWeight.w600)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Ty.s(22, FontWeight.w700),
        decoration: InputDecoration(prefixText: '৳ ', hintText: '0', labelText: t('budget_amount')),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'), style: Ty.s(15, FontWeight.w600, color: C.ink600))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('save'), style: Ty.s(15, FontWeight.w600, color: C.primary))),
      ],
    ),
  );
  if (ok == true) {
    final v = int.tryParse(ctrl.text.trim()) ?? 0;
    await state.setBudget(v * 100);
  }
}
