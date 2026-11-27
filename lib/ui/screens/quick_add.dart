import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../dialogs.dart';
import '../motion.dart';
import '../widgets.dart';

/// লেনদেনে চাপ দিলে: বদলানো/মোছার স্ক্রিন। দেনা/পাওনা/ডিপিএস থেকে আসা গুলো এখানে বদলানো যাবে না।
void openTxEditor(BuildContext context, Tx tx) {
  if (!tx.isManual) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('delete_locked'))));
    return;
  }
  Navigator.of(context).push(fadeRoute(QuickAddScreen(edit: tx), fullscreenDialog: true));
}

/// নতুন লেনদেন: আয় / খরচ — ১০-১৫ সেকেন্ডে হিসাব লেখার স্ক্রিন
class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key, this.edit});
  final Tx? edit; // null = নতুন, না হলে বদলানো

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  TxType _type = TxType.expense;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  List<Category> _cats = [];
  int? _selectedId;

  bool get _editing => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      _type = e.type;
      final whole = e.amountPaisa % 100 == 0;
      _amount.text = whole ? '${e.amountPaisa ~/ 100}' : (e.amountPaisa / 100).toStringAsFixed(2);
      _note.text = e.note;
      _date = e.date;
      _selectedId = e.categoryId;
    }
    _loadCats();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: dialogShape,
        title: Text(t('delete_title'), style: Ty.s(18, FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'), style: Ty.s(15, FontWeight.w600, color: C.ink600))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('delete'), style: Ty.s(15, FontWeight.w600, color: C.expense))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AppState>().deleteTransaction(widget.edit!.id);
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(t('deleted'))));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Category? get _selected {
    for (final c in _cats) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  Future<void> _loadCats({int? select}) async {
    final repo = context.read<AppState>().repo;
    final list = await repo.categories(_type);
    if (!mounted) return;
    setState(() {
      _cats = list;
      final keep = select ?? _selectedId;
      _selectedId = list.any((c) => c.id == keep) ? keep : (list.isEmpty ? null : list.first.id);
    });
  }

  void _setType(TxType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _selectedId = null;
    });
    _loadCats();
  }

  Future<void> _addCategory() async {
    final repo = context.read<AppState>().repo;
    final name = TextEditingController();
    var inBudget = _type == TxType.expense;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: dialogShape,
          title: Text(t('cat_new_title'), style: Ty.s(18, FontWeight.w600)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, style: Ty.s(16, FontWeight.w500), decoration: InputDecoration(labelText: t('cat_name'))),
            if (_type == TxType.expense)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: inBudget,
                onChanged: (v) => setD(() => inBudget = v),
                title: Text(t('in_budget'), style: Ty.s(15, FontWeight.w600)),
              ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('cancel'), style: Ty.s(15, FontWeight.w600, color: C.ink600))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('add'), style: Ty.s(15, FontWeight.w600, color: C.primary))),
          ],
        ),
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      final id = await repo.addCategory(name.text, _type, inBudget: _type == TxType.expense && inBudget);
      await _loadCats(select: id);
    }
  }

  Future<void> _toggleBudget(bool v) async {
    final c = _selected;
    if (c == null) return;
    await context.read<AppState>().repo.setInBudget(c.id, v);
    await _loadCats(select: c.id);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null && mounted) setState(() => _date = d);
  }

  Future<void> _save() async {
    final v = double.tryParse(_amount.text.trim());
    final paisa = v == null ? 0 : (v * 100).round();
    final messenger = ScaffoldMessenger.of(context);
    if (paisa <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(t('err_amount'))));
      return;
    }
    final cat = _selected;
    if (cat == null) {
      messenger.showSnackBar(SnackBar(content: Text(t('err_cat'))));
      return;
    }
    final nav = Navigator.of(context);
    final state = context.read<AppState>();
    HapticFeedback.lightImpact();
    if (_editing) {
      await state.updateTransaction(id: widget.edit!.id, type: _type, amountPaisa: paisa, categoryId: cat.id, date: _date, note: _note.text);
    } else {
      await state.addTransaction(type: _type, amountPaisa: paisa, categoryId: cat.id, date: _date, note: _note.text);
    }
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(_editing ? t('updated') : t('saved'))));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>(); // ভাষা বদলালে রিফ্রেশ
    final isExpense = _type == TxType.expense;
    final cat = _selected;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                Row(children: [
                  RoundIconButton(icon: 'left', onTap: () => Navigator.pop(context)),
                  Expanded(child: Center(child: Text(_editing ? t('edit_txn') : t('new_txn'), style: Ty.s(19, FontWeight.w600)))),
                  if (_editing)
                    Pressable(
                      onTap: _delete,
                      scale: 0.88,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: C.red100, shape: BoxShape.circle),
                        child: const Icon(Icons.delete_outline_rounded, size: 20, color: C.expense),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ]),
                const SizedBox(height: 12),
                _TypeToggle(type: _type, onChanged: _setType),
                const SizedBox(height: 10),
                AppCard(
                  radius: R.xl,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(children: [
                    Text(t('amount_label'), style: Ty.s(13, FontWeight.w500, color: C.textTertiary)),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('৳ ', style: Ty.s(44, FontWeight.w700)),
                      IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 48, maxWidth: 230),
                          child: TextField(
                            controller: _amount,
                            autofocus: !_editing,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                            style: Ty.s(44, FontWeight.w700),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: '0',
                              hintStyle: Ty.s(44, FontWeight.w700, color: C.ink300),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    Container(width: 120, height: 3, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(2))),
                  ]),
                ),
                const SizedBox(height: 16),
                Text(t('category'), style: Ty.s(14, FontWeight.w600, color: C.ink700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in _cats) AppChip(label: c.label, selected: c.id == _selectedId, onTap: () => setState(() => _selectedId = c.id)),
                  AppChip(label: t('new_cat'), icon: Icons.add_rounded, onTap: _addCategory),
                ]),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    const IconCircle(icon: Icons.verified_user_outlined, bg: C.primaryContainer, fg: C.primaryStrong, size: 36, iconSize: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(isExpense ? t('in_budget') : t('income_no_budget'), style: Ty.s(15, FontWeight.w600)),
                        Text(isExpense ? t('in_budget_sub') : t('income_no_budget_sub'), style: Ty.s(12, FontWeight.w400, color: C.textTertiary)),
                      ]),
                    ),
                    if (isExpense) Switch(value: cat?.inBudget ?? false, onChanged: cat == null ? null : _toggleBudget),
                  ]),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(children: [
                    InkWell(
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded, size: 20, color: C.ink600),
                          const SizedBox(width: 12),
                          Text(t('date'), style: Ty.s(14, FontWeight.w500, color: C.ink600)),
                          const Spacer(),
                          Text(sameDay(_date, DateTime.now()) ? '${t('today')}, ${dayMonth(_date)}' : fullDate(_date), style: Ty.s(14, FontWeight.w600)),
                        ]),
                      ),
                    ),
                    const Divider(height: 1, color: C.surfaceVariant),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(children: [
                        const Icon(Icons.edit_outlined, size: 20, color: C.ink600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _note,
                            style: Ty.s(14, FontWeight.w500),
                            decoration: InputDecoration(border: InputBorder.none, hintText: t('note_hint'), hintStyle: Ty.s(14, FontWeight.w400, color: C.ink400)),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: PrimaryButton(label: t('save'), onPressed: _save)),
        ]),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});
  final TxType type;
  final ValueChanged<TxType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(TxType v, String label, Color color) {
      final on = type == v;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? C.surface : Colors.transparent, borderRadius: BorderRadius.circular(R.full), boxShadow: on ? Shadows.card : null),
            child: Text(label, style: Ty.s(16, on ? FontWeight.w700 : FontWeight.w500, color: on ? color : C.ink600)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: C.ink100, borderRadius: BorderRadius.circular(R.full)),
      child: Row(children: [seg(TxType.income, t('income'), C.income), const SizedBox(width: 4), seg(TxType.expense, t('expense'), C.expense)]),
    );
  }
}
