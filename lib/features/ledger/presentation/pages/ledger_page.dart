import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';

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

  final _expenseCats = [
    {
      'id': 1,
      'icon': Icons.restaurant_outlined,
      'color': Color(0xFFC96C5C),
      'name': '餐饮',
    },
    {
      'id': 2,
      'icon': Icons.directions_car_outlined,
      'color': Color(0xFF6D8BA8),
      'name': '交通',
    },
    {
      'id': 3,
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFFB88A5B),
      'name': '购物',
    },
    {
      'id': 4,
      'icon': Icons.home_outlined,
      'color': Color(0xFF8E7C66),
      'name': '住房',
    },
    {
      'id': 5,
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFFD2A84A),
      'name': '水电',
    },
    {
      'id': 6,
      'icon': Icons.phone_iphone_outlined,
      'color': Color(0xFF7D91A6),
      'name': '通讯',
    },
    {
      'id': 7,
      'icon': Icons.sports_esports_outlined,
      'color': Color(0xFF9A7BA8),
      'name': '娱乐',
    },
    {
      'id': 8,
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFF6B9D78),
      'name': '学习',
    },
    {
      'id': 9,
      'icon': Icons.medical_services_outlined,
      'color': Color(0xFFD4786E),
      'name': '医疗',
    },
    {
      'id': 10,
      'icon': Icons.flight_takeoff_outlined,
      'color': Color(0xFF6D9CA8),
      'name': '旅行',
    },
    {
      'id': 11,
      'icon': Icons.cruelty_free_outlined,
      'color': Color(0xFFA88372),
      'name': '宠物',
    },
    {
      'id': 12,
      'icon': Icons.card_giftcard_outlined,
      'color': Color(0xFFC77D90),
      'name': '礼物',
    },
    {
      'id': 13,
      'icon': Icons.spa_outlined,
      'color': Color(0xFF86B66E),
      'name': '日用品',
    },
    {
      'id': 14,
      'icon': Icons.checkroom_outlined,
      'color': Color(0xFFA982A4),
      'name': '服饰',
    },
    {
      'id': 15,
      'icon': Icons.brush_outlined,
      'color': Color(0xFFC98294),
      'name': '美妆',
    },
    {
      'id': 16,
      'icon': Icons.directions_run_outlined,
      'color': Color(0xFF7AA486),
      'name': '运动',
    },
    {
      'id': 17,
      'icon': Icons.devices_outlined,
      'color': Color(0xFF6E8FA4),
      'name': '数码',
    },
    {
      'id': 18,
      'icon': Icons.more_horiz,
      'color': Color(0xFF8E8E93),
      'name': '其他',
    },
  ];

  final _incomeCats = [
    {
      'id': 101,
      'icon': Icons.payments_outlined,
      'color': Color(0xFF6B9D78),
      'name': '工资',
    },
    {
      'id': 102,
      'icon': Icons.redeem_outlined,
      'color': Color(0xFFC77D90),
      'name': '奖金',
    },
    {
      'id': 103,
      'icon': Icons.trending_up_outlined,
      'color': Color(0xFF7AA486),
      'name': '分红',
    },
    {
      'id': 104,
      'icon': Icons.work_outline,
      'color': Color(0xFF8E7C66),
      'name': '兼职',
    },
    {
      'id': 105,
      'icon': Icons.credit_card_outlined,
      'color': Color(0xFF6D8BA8),
      'name': '收款',
    },
    {
      'id': 106,
      'icon': Icons.keyboard_return_outlined,
      'color': Color(0xFF8E8E93),
      'name': '退款',
    },
    {
      'id': 107,
      'icon': Icons.card_giftcard_outlined,
      'color': Color(0xFFC96C5C),
      'name': '红包',
    },
    {
      'id': 108,
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF5E7A6B),
      'name': '利息',
    },
    {
      'id': 109,
      'icon': Icons.insert_chart_outlined,
      'color': Color(0xFF6E8FA4),
      'name': '投资',
    },
    {
      'id': 110,
      'icon': Icons.more_horiz,
      'color': Color(0xFF8E8E93),
      'name': '其他',
    },
  ];

  final _accounts = [
    {
      'id': 1,
      'icon': Icons.chat_bubble_outline,
      'color': Color(0xFF6B9D78),
      'name': '微信',
    },
    {
      'id': 2,
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFF5F8FB8),
      'name': '支付宝',
    },
    {
      'id': 3,
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF8E7C66),
      'name': '银行卡',
    },
    {
      'id': 4,
      'icon': Icons.money_outlined,
      'color': Color(0xFF7AA486),
      'name': '现金',
    },
    {
      'id': 5,
      'icon': Icons.credit_card_outlined,
      'color': Color(0xFF9A7BA8),
      'name': '信用卡',
    },
    {
      'id': 6,
      'icon': Icons.phone_iphone_outlined,
      'color': Color(0xFF6D8BA8),
      'name': '数字钱包',
    },
  ];

  List<Map<String, dynamic>> get _cats =>
      _isExpense ? _expenseCats : _incomeCats;

  @override
  void initState() {
    super.initState();
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

              // 分类
              _SectionTitle(label: '分类'),
              const SizedBox(height: 16),
              _ChipGrid(
                items: _cats,
                selectedId: _selectedCatId,
                onSelect: (id) => setState(() => _selectedCatId = id),
                selectedColor: accent,
              ),
              const SizedBox(height: 28),

              // 账户
              _SectionTitle(label: '账户'),
              const SizedBox(height: 16),
              _ChipGrid(
                items: _accounts,
                selectedId: _selectedAccId,
                onSelect: (id) => setState(() => _selectedAccId = id),
                selectedColor: AppColors.accent,
              ),
              const SizedBox(height: 28),

              // 备注
              _SectionTitle(label: '备注'),
              const SizedBox(height: 16),
              TextField(
                controller: _noteCtrl,
                style: AppTypography.body.copyWith(fontSize: 21),
                decoration: const InputDecoration(
                  hintText: '例如：和朋友吃火锅',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 20),
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
                    const Icon(
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
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [AppShadows.card],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body.copyWith(
              color: selected ? color : AppColors.textSecondary,
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
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final id = item['id'] as int;
        final sel = selectedId == id;
        return GestureDetector(
          onTap: () => onSelect(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuart,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: sel
                  ? selectedColor.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: AppRadius.capsule,
              border: Border.all(
                color: sel
                    ? selectedColor.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 22,
                  color: sel ? selectedColor : item['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  item['name'] as String,
                  style: AppTypography.caption.copyWith(fontSize: 18),
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
