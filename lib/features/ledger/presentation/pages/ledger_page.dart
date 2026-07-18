import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';

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

  final _expenseCats = [
    {'id': 1, 'icon': '🍜', 'name': '餐饮'},
    {'id': 2, 'icon': '🚗', 'name': '交通'},
    {'id': 3, 'icon': '🛒', 'name': '购物'},
    {'id': 4, 'icon': '🏠', 'name': '住房'},
    {'id': 5, 'icon': '💡', 'name': '水电'},
    {'id': 6, 'icon': '📱', 'name': '通讯'},
    {'id': 7, 'icon': '🎮', 'name': '娱乐'},
    {'id': 8, 'icon': '📚', 'name': '学习'},
    {'id': 9, 'icon': '💊', 'name': '医疗'},
    {'id': 10, 'icon': '✈️', 'name': '旅行'},
    {'id': 11, 'icon': '🐱', 'name': '宠物'},
    {'id': 12, 'icon': '🎁', 'name': '礼物'},
    {'id': 13, 'icon': '🧴', 'name': '日用品'},
    {'id': 14, 'icon': '👗', 'name': '服饰'},
    {'id': 15, 'icon': '💄', 'name': '美妆'},
    {'id': 16, 'icon': '🏃', 'name': '运动'},
    {'id': 17, 'icon': '💻', 'name': '数码'},
    {'id': 18, 'icon': '📌', 'name': '其他'},
  ];

  final _incomeCats = [
    {'id': 101, 'icon': '💰', 'name': '工资'},
    {'id': 102, 'icon': '🧧', 'name': '奖金'},
    {'id': 103, 'icon': '📈', 'name': '分红'},
    {'id': 104, 'icon': '💼', 'name': '兼职'},
    {'id': 105, 'icon': '💳', 'name': '收款'},
    {'id': 106, 'icon': '↩️', 'name': '退款'},
    {'id': 107, 'icon': '🎁', 'name': '红包'},
    {'id': 108, 'icon': '🏦', 'name': '利息'},
    {'id': 109, 'icon': '📊', 'name': '投资'},
    {'id': 110, 'icon': '📌', 'name': '其他'},
  ];

  final _accounts = [
    {'id': 1, 'icon': '💚', 'name': '微信'},
    {'id': 2, 'icon': '💙', 'name': '支付宝'},
    {'id': 3, 'icon': '🏦', 'name': '银行卡'},
    {'id': 4, 'icon': '💵', 'name': '现金'},
    {'id': 5, 'icon': '💳', 'name': '信用卡'},
    {'id': 6, 'icon': '📱', 'name': '数字钱包'},
  ];

  List<Map<String, dynamic>> get _cats =>
      _isExpense ? _expenseCats : _incomeCats;

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

  void _save() {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('账单已保存')));
    _reset();
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
    final accent = _isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

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
                  style: AppTypography.caption,
                ),
              ),
              const SizedBox(height: 20),

              // 金额
              Text(
                _amount.isEmpty ? '¥0.00' : '¥$_amount',
                style: AppTypography.amountLarge.copyWith(color: accent),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 2,
                color: accent.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),

              // 收支切换
              Row(
                children: [
                  Expanded(
                    child: _TypeBtn(
                      label: '支出',
                      selected: _isExpense,
                      color: AppColors.expense,
                      onTap: () => setState(() => _isExpense = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeBtn(
                      label: '收入',
                      selected: !_isExpense,
                      color: AppColors.income,
                      onTap: () => setState(() => _isExpense = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 数字键盘
              _buildKeypad(),
              const SizedBox(height: 24),

              // 分类
              _SectionTitle(label: '分类'),
              const SizedBox(height: 10),
              _ChipGrid(
                items: _cats,
                selectedId: _selectedCatId,
                onSelect: (id) => setState(() => _selectedCatId = id),
                selectedColor: accent,
              ),
              const SizedBox(height: 20),

              // 账户
              _SectionTitle(label: '账户'),
              const SizedBox(height: 10),
              _ChipGrid(
                items: _accounts,
                selectedId: _selectedAccId,
                onSelect: (id) => setState(() => _selectedAccId = id),
                selectedColor: AppColors.accent,
              ),
              const SizedBox(height: 20),

              // 备注
              _SectionTitle(label: '备注'),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                style: AppTypography.body,
                decoration: const InputDecoration(hintText: '例如：和朋友吃火锅'),
              ),
              const SizedBox(height: 20),

              // 凭证
              _SectionTitle(label: '消费凭证'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '添加凭证',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 保存
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.text,
                    borderRadius: AppRadius.md,
                  ),
                  child: Center(
                    child: Text(
                      '保存账单',
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((k) {
            return GestureDetector(
              onTap: () => _onKey(k),
              child: Container(
                width: 72,
                height: 52,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.md,
                ),
                alignment: Alignment.center,
                child: Text(
                  k,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: AppRadius.md,
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              color: selected ? color : AppColors.textSecondary,
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
  final Color selectedColor;
  const _ChipGrid({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final id = item['id'] as int;
        final sel = selectedId == id;
        return GestureDetector(
          onTap: () => onSelect(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel
                  ? selectedColor.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: AppRadius.capsule,
              border: sel
                  ? Border.all(color: selectedColor.withValues(alpha: 0.3))
                  : null,
            ),
            child: Text(
              '${item['icon']} ${item['name']}',
              style: AppTypography.caption.copyWith(fontSize: 13),
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
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
