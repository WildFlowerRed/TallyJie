import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/constants.dart';
import '../../../../core/models/transaction.dart';

/// 显示新增消费 BottomSheet
void showAddExpenseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.sheet,
    ),
    builder: (context) => const _AddExpenseSheet(),
  );
}

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  int _step = 0; // 0=金额, 1=分类, 2=备注
  TransactionType _type = TransactionType.expense;
  String _amount = '';
  String _selectedCategory = '';
  String _selectedIcon = '';
  final TextEditingController _noteController = TextEditingController();

  static const _categories = [
    {'icon': '🍜', 'name': '餐饮'},
    {'icon': '🚗', 'name': '交通'},
    {'icon': '🛒', 'name': '购物'},
    {'icon': '🎮', 'name': '娱乐'},
    {'icon': '📚', 'name': '学习'},
    {'icon': '💊', 'name': '医疗'},
    {'icon': '🏠', 'name': '住房'},
    {'icon': '💰', 'name': '收入'},
    {'icon': '📌', 'name': '其他'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_amount.isEmpty || double.tryParse(_amount) == null) return;
    if (_selectedCategory.isEmpty) return;

    // TODO: Save to database via provider
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已记录: $_selectedIcon $_selectedCategory ¥$_amount'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            // 拖动指示器
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 步骤指示器
            const SizedBox(height: 16),
            _StepIndicator(currentStep: _step, totalSteps: 3),

            const SizedBox(height: 8),

            // 标题
            Text(
              AppStrings.ledgerAddTransaction,
              style: AppTypography.h1_26,
            ),
            const SizedBox(height: 8),

            // 步骤内容
            Expanded(child: _buildStep()),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildAmountStep();
      case 1:
        return _buildCategoryStep();
      case 2:
        return _buildNoteStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 第一步：金额输入
  Widget _buildAmountStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 类型切换
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TypeChip(
              label: AppStrings.ledgerExpense,
              isSelected: _type == TransactionType.expense,
              onTap: () => setState(() => _type = TransactionType.expense),
            ),
            const SizedBox(width: 12),
            _TypeChip(
              label: AppStrings.ledgerIncome,
              isSelected: _type == TransactionType.income,
              onTap: () => setState(() => _type = TransactionType.income),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 金额显示
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '¥',
              style: AppTypography.amount34.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _amount.isEmpty ? '0' : _amount,
              style: AppTypography.amountInput,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 数字键盘
        _buildKeypad(),
      ],
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
          children: row.map((key) {
            return _KeypadButton(
              label: key,
              onTap: () {
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
                    // 限制小数点后两位
                    if (_amount.contains('.') &&
                        _amount.split('.').length > 1 &&
                        _amount.split('.')[1].length >= 2) {
                      return;
                    }
                    _amount += key;
                  }
                });
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// 第二步：分类选择
  Widget _buildCategoryStep() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat['name']!;
              _selectedIcon = cat['icon']!;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navSelected : AppColors.primaryBg,
              borderRadius: AppRadius.input,
              border: isSelected
                  ? Border.all(color: AppColors.navSelected, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  cat['name']!,
                  style: AppTypography.caption14.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.primaryText,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 第三步：备注
  Widget _buildNoteStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 已选信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: AppRadius.input,
            ),
            child: Row(
              children: [
                Text(_selectedIcon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  _selectedCategory,
                  style: AppTypography.body17.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '¥$_amount',
                  style: AppTypography.amount34.copyWith(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 备注输入
          TextField(
            controller: _noteController,
            autofocus: true,
            style: AppTypography.body17,
            decoration: InputDecoration(
              hintText: AppStrings.ledgerNoteHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: _OutlinedButton(
                label: '上一步',
                onTap: () => setState(() => _step--),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: _FilledButton(
              label: _step == 2 ? AppStrings.ledgerSave : '下一步',
              onTap: () {
                if (_step == 2) {
                  _save();
                } else {
                  setState(() => _step++);
                }
              },
              enabled: _step == 0
                  ? (_amount.isNotEmpty && double.tryParse(_amount) != null)
                  : _step == 1
                      ? _selectedCategory.isNotEmpty
                      : true,
            ),
          ),
        ],
      ),
    );
  }
}

/// 步骤指示器
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentStep ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index <= currentStep
                ? AppColors.navSelected
                : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// 类型切换按钮
class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navSelected : AppColors.primaryBg,
          borderRadius: AppRadius.tag,
        ),
        child: Text(
          label,
          style: AppTypography.body17.copyWith(
            color: isSelected ? AppColors.white : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 数字键盘按钮
class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 52,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.h1_26.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _FilledButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? AppColors.navSelected : AppColors.divider,
          borderRadius: AppRadius.input,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.body17.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: AppRadius.input,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.body17.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
