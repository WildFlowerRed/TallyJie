import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../core/services/local_data_api.dart';

/// 记账账本
class LedgerPage extends ConsumerStatefulWidget {
  const LedgerPage({super.key});
  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  bool _isExpense = true;
  String _amount = '';
  int? _selectedCatId;
  int? _selectedAccId;
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  bool _isKeypadOpen = false;
  bool _loadingOptions = true;
  List<Map<String, dynamic>> _expenseCats = [];
  List<Map<String, dynamic>> _incomeCats = [];
  List<Map<String, dynamic>> _accounts = [];

  List<Map<String, dynamic>> get _cats =>
      _isExpense ? _expenseCats : _incomeCats;

  @override
  void initState() {
    super.initState();
    _loadOptions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showAmountKeypad();
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (key == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else {
        if (_amount.contains('.') &&
            _amount.split('.').length > 1 &&
            _amount.split('.')[1].length >= 2) {
          return;
        }
        if (_amount == '0' && key != '.') {
          _amount = key;
        } else {
          _amount += key;
        }
      }
    });
  }

  Future<void> _loadOptions() async {
    final expense = await LocalDataApi.instance.listLedgerCategories(
      type: LedgerEntryType.expense,
    );
    final income = await LocalDataApi.instance.listLedgerCategories(
      type: LedgerEntryType.income,
    );
    final accounts = await LocalDataApi.instance.listLedgerAccounts();
    if (!mounted) return;
    setState(() {
      _expenseCats = expense.map(_categoryToChip).toList();
      _incomeCats = income.map(_categoryToChip).toList();
      _accounts = accounts.map(_accountToChip).toList();
      _loadingOptions = false;
    });
  }

  Map<String, dynamic> _categoryToChip(LedgerCategoryDto category) {
    return {
      'id': category.id,
      'icon': LedgerIconCatalog.icon(category.iconCode),
      'name': category.name,
    };
  }

  Map<String, dynamic> _accountToChip(LedgerAccountDto account) {
    return {
      'id': account.id,
      'icon': LedgerIconCatalog.icon(account.iconCode),
      'name': account.name,
    };
  }

  Future<void> _showAmountKeypad() async {
    if (_isKeypadOpen) return;
    _isKeypadOpen = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final accent = _isExpense ? AppColors.expense : AppColors.income;
            return _AmountKeypadSheet(
              amount: _amount,
              accent: accent,
              bottomInset: bottomInset,
              onKey: (key) {
                _onKey(key);
                setSheetState(() {});
              },
              onDone: () => Navigator.of(ctx).pop(),
            );
          },
        );
      },
    );

    _isKeypadOpen = false;
  }

  void _switchType(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _selectedCatId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showAmountKeypad();
    });
  }

  Future<void> _save() async {
    if (_amount.isEmpty || double.tryParse(_amount) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效金额')));
      return;
    }
    if (_selectedCatId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择分类')));
      return;
    }
    if (_selectedAccId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择账户')));
      return;
    }
    try {
      await LocalDataApi.instance.createLedgerTransaction(
        CreateLedgerTransactionInput(
          type: _isExpense ? LedgerEntryType.expense : LedgerEntryType.income,
          amount: double.parse(_amount),
          categoryId: _selectedCatId!,
          accountId: _selectedAccId!,
          note: _noteCtrl.text,
          transactionTime: _selectedTime,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('账单已保存')));
      _reset();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('保存失败，请稍后重试')));
    }
  }

  void _reset() {
    setState(() {
      _amount = '';
      _selectedCatId = null;
      _selectedAccId = null;
      _noteCtrl.clear();
      _selectedTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.themeVersion,
      builder: (context, themeVersion, child) {
        final accent = _isExpense ? AppColors.expense : AppColors.income;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 22),

                  // 日期时间
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _selectedTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (!context.mounted || d == null) return;

                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedTime),
                      );
                      if (!mounted || t == null) return;

                      setState(() {
                        _selectedTime = DateTime(
                          d.year,
                          d.month,
                          d.day,
                          t.hour,
                          t.minute,
                        );
                      });
                    },
                    child: Text(
                      DateFormat('yyyy年M月d日 HH:mm').format(_selectedTime),
                      style: AppTypography.caption.copyWith(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // 金额
                  GestureDetector(
                    onTap: _showAmountKeypad,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Text(
                        _amount.isEmpty ? '¥0.00' : '¥$_amount',
                        style: AppTypography.amountLarge.copyWith(
                          color: accent,
                          fontSize: 64,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 58,
                    height: 3,
                    color: accent.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 32),

                  // 收支切换
                  Row(
                    children: [
                      Expanded(
                        child: _TypeBtn(
                          label: '支出',
                          selected: _isExpense,
                          color: AppColors.expense,
                          onTap: () => _switchType(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TypeBtn(
                          label: '收入',
                          selected: !_isExpense,
                          color: AppColors.income,
                          onTap: () => _switchType(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (_loadingOptions) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ] else ...[
                    // 分类
                    _SectionTitle(label: '分类'),
                    const SizedBox(height: 16),
                    _ChipGrid(
                      items: _cats,
                      selectedId: _selectedCatId,
                      onSelect: (id) => setState(() => _selectedCatId = id),
                    ),
                    const SizedBox(height: 28),

                    // 账户
                    _SectionTitle(label: '账户'),
                    const SizedBox(height: 16),
                    _ChipGrid(
                      items: _accounts,
                      selectedId: _selectedAccId,
                      onSelect: (id) => setState(() => _selectedAccId = id),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // 备注
                  _SectionTitle(label: '备注'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteCtrl,
                    style: AppTypography.body.copyWith(fontSize: 21),
                    decoration: InputDecoration(
                      hintText: '例如：和朋友吃火锅',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 凭证
                  _SectionTitle(label: '消费凭证'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 30,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '添加凭证',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 21,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 保存
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: AppRadius.md,
                      ),
                      child: Center(
                        child: Text(
                          '保存账单',
                          style: AppTypography.body.copyWith(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AmountKeypadSheet extends StatelessWidget {
  final String amount;
  final Color accent;
  final double bottomInset;
  final ValueChanged<String> onKey;
  final VoidCallback onDone;

  const _AmountKeypadSheet({
    required this.amount,
    required this.accent,
    required this.bottomInset,
    required this.onKey,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.5;
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: AppShadows.card,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    '输入金额',
                    style: AppTypography.subtitle.copyWith(fontSize: 25),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDone,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.capsule,
                      ),
                      child: Text(
                        '完成',
                        style: AppTypography.caption.copyWith(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                amount.isEmpty ? '¥0.00' : '¥$amount',
                style: AppTypography.amount.copyWith(
                  color: accent,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: keys.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((key) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: _KeypadButton(
                                label: key,
                                onTap: () => onKey(key),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeypadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.subtitle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = selected
        ? color
        : Color.lerp(color, AppColors.card, 0.28)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int? selectedId;
  final ValueChanged<int> onSelect;
  const _ChipGrid({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.navSelected;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final id = item['id'] as int;
        final sel = selectedId == id;
        final foreground = sel ? AppColors.white : themeColor;
        return GestureDetector(
          onTap: () => onSelect(id),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuart,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            decoration: BoxDecoration(
              color: sel ? themeColor : themeColor.withValues(alpha: 0.08),
              borderRadius: AppRadius.capsule,
              border: Border.all(
                color: sel
                    ? themeColor.withValues(alpha: 0.82)
                    : Colors.transparent,
              ),
              boxShadow: sel ? AppShadows.card : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item['icon'] as IconData, size: 23, color: foreground),
                const SizedBox(width: 9),
                Text(
                  item['name'] as String,
                  style: AppTypography.caption.copyWith(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
