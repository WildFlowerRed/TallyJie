import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/local_data_api.dart';
import '../../../../core/utils/date_helpers.dart';

Color get _primaryBlue => AppColors.accent;
Color get _secondaryText => AppColors.textSecondary;

Color _categoryVisualColor(String category, bool isIncome) {
  if (isIncome) {
    switch (category) {
      case '工资':
        return const Color(0xFF5D7A6B);
      case '奖金':
      case '红包':
        return const Color(0xFF8FAE7F);
      case '分红':
      case '投资':
        return const Color(0xFF7A9F8A);
      case '兼职':
        return const Color(0xFF8CB5A8);
      case '退款':
        return const Color(0xFF9B9187);
      default:
        return const Color(0xFF6F927D);
    }
  }

  switch (category) {
    case '住房':
      return const Color(0xFF8F8378);
    case '购物':
    case '服饰':
      return const Color(0xFFD8A47F);
    case '餐饮':
      return const Color(0xFFD27165);
    case '水电':
      return const Color(0xFFC2A85C);
    case '娱乐':
      return const Color(0xFFA68AAE);
    case '交通':
    case '旅行':
      return const Color(0xFF7E9BA8);
    case '医疗':
      return const Color(0xFFC98578);
    case '学习':
      return const Color(0xFF7F9A72);
    case '日用品':
      return const Color(0xFF8CB5A8);
    case '礼物':
      return const Color(0xFFC98A9C);
    default:
      return const Color(0xFF9B9187);
  }
}

enum _BillTypeFilter { all, expense, income }

enum _TimeFilter { today, week, month, year }

enum _ReportType { expense, income }

class StatisticsPageNavigation {
  StatisticsPageNavigation._();

  static final ValueNotifier<int> _mainPageRequests = ValueNotifier(0);

  static void requestMainPage() {
    _mainPageRequests.value++;
  }
}

/// 收支明细 / 统计报表
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  bool _showReport = false;
  _BillTypeFilter _billFilter = _BillTypeFilter.all;
  _TimeFilter _timeFilter = _TimeFilter.month;
  _ReportType _reportType = _ReportType.expense;
  String _searchQuery = '';
  late DateTime _reportMonth;
  List<_BillRecord> _records = [];
  bool _loadingRecords = true;
  MonthlyBudgetDto? _budget;
  bool _loadingBudget = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _reportMonth = DateTime(now.year, now.month);
    _loadPageData();
    LocalDataApi.instance.transactionsVersion.addListener(
      _handleTransactionsChanged,
    );
    LocalDataApi.instance.budgetVersion.addListener(_handleBudgetChanged);
    StatisticsPageNavigation._mainPageRequests.addListener(_showMainPage);
  }

  @override
  void dispose() {
    LocalDataApi.instance.transactionsVersion.removeListener(
      _handleTransactionsChanged,
    );
    LocalDataApi.instance.budgetVersion.removeListener(_handleBudgetChanged);
    StatisticsPageNavigation._mainPageRequests.removeListener(_showMainPage);
    super.dispose();
  }

  void _handleTransactionsChanged() {
    _loadPageData();
  }

  void _handleBudgetChanged() {
    _loadBudget();
  }

  Future<void> _loadPageData() async {
    final transactions = await LocalDataApi.instance.listTransactions();
    final budget = await LocalDataApi.instance.getBudget();
    if (!mounted) return;
    setState(() {
      _records = transactions.map(_BillRecord.fromDto).toList();
      _budget = budget;
      _loadingRecords = false;
      _loadingBudget = false;
    });
  }

  Future<void> _loadBudget() async {
    final budget = await LocalDataApi.instance.getBudget();
    if (!mounted) return;
    setState(() {
      _budget = budget;
      _loadingBudget = false;
    });
  }

  void _showMainPage() {
    if (mounted && _showReport) {
      setState(() => _showReport = false);
    }
  }

  List<_BillRecord> get _filteredRecords {
    final now = DateTime.now();
    final query = _searchQuery.trim().toLowerCase();
    return _records.where((record) {
      if (_billFilter == _BillTypeFilter.expense && record.isIncome) {
        return false;
      }
      if (_billFilter == _BillTypeFilter.income && !record.isIncome) {
        return false;
      }
      if (!_matchesTimeFilter(record.date, now)) return false;
      if (query.isEmpty) return true;
      final amount = record.amount.abs().toStringAsFixed(2);
      return record.category.toLowerCase().contains(query) ||
          record.note.toLowerCase().contains(query) ||
          record.account.toLowerCase().contains(query) ||
          amount.contains(query);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double get _monthlyIncome => _records
      .where((r) => r.isIncome && _isSameMonth(r.date, DateTime.now()))
      .fold(0.0, (sum, r) => sum + r.amount);

  double get _monthlyExpense => _records
      .where((r) => !r.isIncome && _isSameMonth(r.date, DateTime.now()))
      .fold(0.0, (sum, r) => sum + r.amount.abs());

  bool _matchesTimeFilter(DateTime date, DateTime now) {
    switch (_timeFilter) {
      case _TimeFilter.today:
        return DateHelpers.isSameDay(date, now);
      case _TimeFilter.week:
        final start = DateHelpers.weekStart(now);
        final end = DateHelpers.weekEnd(now);
        final day = DateTime(date.year, date.month, date.day);
        return !day.isBefore(start) && !day.isAfter(end);
      case _TimeFilter.month:
        return _isSameMonth(date, now);
      case _TimeFilter.year:
        return date.year == now.year;
    }
  }

  Future<void> _openSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);
    final query = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '查找交易',
                style: AppTypography.subtitle.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                style: AppTypography.body.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  hintText: '金额 / 备注 / 类别',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 22),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _secondaryText,
                    size: 30,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: controller.clear,
                          icon: const Icon(Icons.close, size: 28),
                          color: _secondaryText,
                        )
                      : null,
                ),
                onSubmitted: (value) => Navigator.of(context).pop(value),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('清空', style: TextStyle(fontSize: 20)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(controller.text),
                    style: AppTheme.primaryFilledButtonStyle.copyWith(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                      ),
                    ),
                    child: const Text('搜索', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (query != null) {
      setState(() => _searchQuery = query);
    }
  }

  void _showBillDetail(_BillRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => _BillDetailSheet(record: record),
    );
  }

  Future<void> _pickReportMonth() async {
    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => _MonthPickerDialog(initialMonth: _reportMonth),
    );
    if (picked != null) {
      setState(() => _reportMonth = picked);
    }
  }

  Future<void> _openBudgetEditor() async {
    final current = _budget?.budgetAmount;
    final controller = TextEditingController(
      text: current == null ? '' : _formatMoney(current),
    );
    final amount = await showDialog<double>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '编辑月预算',
                style: AppTypography.subtitle.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTypography.body.copyWith(fontSize: 24),
                decoration: InputDecoration(
                  prefixText: '¥ ',
                  hintText: '1000.00',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 22),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: AppTheme.primaryFilledButtonStyle,
                    onPressed: () {
                      final value = double.tryParse(
                        controller.text.replaceAll(',', '').trim(),
                      );
                      if (value == null || value < 0) return;
                      Navigator.of(context).pop(value);
                    },
                    child: const Text('保存', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (amount == null) return;
    await LocalDataApi.instance.setBudget(
      month: DateTime.now(),
      amount: amount,
    );
    await _loadBudget();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.themeVersion,
      builder: (context, themeVersion, child) {
        if (_showReport) {
          return _ReportPage(
            records: _records,
            reportType: _reportType,
            selectedMonth: _reportMonth,
            onBack: () => setState(() => _showReport = false),
            onReportTypeChanged: (type) => setState(() => _reportType = type),
            onMonthTap: _pickReportMonth,
          );
        }

        final balance = _monthlyIncome - _monthlyExpense;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '收支明细',
                      style: AppTypography.title.copyWith(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _BalanceCard(
                    balance: balance,
                    income: _monthlyIncome,
                    expense: _monthlyExpense,
                  ),
                  const SizedBox(height: 22),
                  _BudgetCard(
                    budget: _budget,
                    loading: _loadingBudget,
                    onEdit: _openBudgetEditor,
                  ),
                  const SizedBox(height: 22),
                  _FilterToolbar(
                    billFilter: _billFilter,
                    timeFilter: _timeFilter,
                    hasSearch: _searchQuery.isNotEmpty,
                    onBillFilterChanged: (value) =>
                        setState(() => _billFilter = value),
                    onTimeFilterChanged: (value) =>
                        setState(() => _timeFilter = value),
                    onSearchTap: _openSearchDialog,
                    onReportTap: () => setState(() => _showReport = true),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SearchStatus(
                      query: _searchQuery,
                      onClear: () => setState(() => _searchQuery = ''),
                    ),
                  ],
                  if (_budget != null && _budget!.isOverBudget) ...[
                    const SizedBox(height: 16),
                    _BudgetWarningBar(overAmount: _budget!.overAmount),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        '账单流水',
                        style: AppTypography.subtitle.copyWith(fontSize: 25),
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredRecords.length} 条',
                        style: AppTypography.caption.copyWith(
                          color: _secondaryText,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loadingRecords)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 42),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  else if (_filteredRecords.isEmpty)
                    const _EmptyBills()
                  else
                    ..._buildGroupedTransactionList(_filteredRecords),
                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupedTransactionList(List<_BillRecord> records) {
    final widgets = <Widget>[];
    var currentKey = '';
    var currentDayRecords = <_BillRecord>[];

    void flushGroup() {
      if (currentDayRecords.isEmpty) return;
      final day = DateTime(
        currentDayRecords.first.date.year,
        currentDayRecords.first.date.month,
        currentDayRecords.first.date.day,
      );
      final expenseTotal = currentDayRecords
          .where((record) => !record.isIncome)
          .fold(0.0, (sum, record) => sum + record.amount.abs());
      final incomeTotal = currentDayRecords
          .where((record) => record.isIncome)
          .fold(0.0, (sum, record) => sum + record.amount.abs());
      final showIncome = _billFilter == _BillTypeFilter.income;

      widgets.add(
        _BillDateHeader(
          date: day,
          label: showIncome ? '收入' : '支出',
          amount: showIncome ? incomeTotal : expenseTotal,
        ),
      );
      widgets.addAll(
        currentDayRecords.map(
          (record) =>
              _TxnTile(record: record, onTap: () => _showBillDetail(record)),
        ),
      );
    }

    for (final record in records) {
      final key = _dateKey(record.date);
      if (currentKey.isEmpty) {
        currentKey = key;
      }
      if (key != currentKey) {
        flushGroup();
        currentKey = key;
        currentDayRecords = [];
      }
      currentDayRecords.add(record);
    }
    flushGroup();
    return widgets;
  }
}

class _FilterToolbar extends StatelessWidget {
  final _BillTypeFilter billFilter;
  final _TimeFilter timeFilter;
  final bool hasSearch;
  final ValueChanged<_BillTypeFilter> onBillFilterChanged;
  final ValueChanged<_TimeFilter> onTimeFilterChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onReportTap;

  const _FilterToolbar({
    required this.billFilter,
    required this.timeFilter,
    required this.hasSearch,
    required this.onBillFilterChanged,
    required this.onTimeFilterChanged,
    required this.onSearchTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PopupPill<_BillTypeFilter>(
            label: _billFilterLabel(billFilter),
            options: const [
              _MenuOption(value: _BillTypeFilter.all, label: '全部'),
              _MenuOption(value: _BillTypeFilter.expense, label: '支出'),
              _MenuOption(value: _BillTypeFilter.income, label: '收入'),
            ],
            onSelected: onBillFilterChanged,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _PopupPill<_TimeFilter>(
            label: _timeFilterLabel(timeFilter),
            options: const [
              _MenuOption(value: _TimeFilter.today, label: '今天'),
              _MenuOption(value: _TimeFilter.week, label: '本周'),
              _MenuOption(value: _TimeFilter.month, label: '本月'),
              _MenuOption(value: _TimeFilter.year, label: '本年'),
            ],
            onSelected: onTimeFilterChanged,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _ActionPill(
            label: hasSearch ? '已查找' : '查找交易',
            icon: Icons.search,
            onTap: onSearchTap,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _ActionPill(label: '收支统计', onTap: onReportTap),
        ),
      ],
    );
  }
}

class _PopupPill<T> extends StatelessWidget {
  final String label;
  final List<_MenuOption<T>> options;
  final ValueChanged<T> onSelected;

  const _PopupPill({
    required this.label,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((option) {
          return PopupMenuItem<T>(
            value: option.value,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  option.label,
                  style: AppTypography.caption.copyWith(
                    color: _primaryBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList();
      },
      color: AppColors.card,
      elevation: 0,
      constraints: const BoxConstraints(minWidth: 132),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.divider.withValues(alpha: 0.72)),
      ),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      child: _PillShell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MenuOption<T> {
  final T value;
  final String label;

  const _MenuOption({required this.value, required this.label});
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _ActionPill({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _PillShell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Transform.translate(
                offset: const Offset(0, 1),
                child: Icon(icon, size: 22, color: _primaryBlue),
              ),
              const SizedBox(width: 5),
            ],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class _PillShell extends StatelessWidget {
  final Widget child;

  const _PillShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.capsule,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.72)),
        boxShadow: AppShadows.card,
      ),
      child: DefaultTextStyle.merge(
        style: AppTypography.caption.copyWith(
          color: _primaryBlue,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
        child: IconTheme(
          data: IconThemeData(color: _primaryBlue),
          child: child,
        ),
      ),
    );
  }
}

class _SearchStatus extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _SearchStatus({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _primaryBlue.withValues(alpha: 0.08),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 22, color: _primaryBlue),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '搜索：$query',
              style: AppTypography.caption.copyWith(
                color: _primaryBlue,
                fontSize: 17,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 22, color: _primaryBlue),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance, income, expense;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Color.lerp(AppColors.navSelected, AppColors.text, 0.16)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            '本月结余',
            style: AppTypography.caption.copyWith(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${balance.toStringAsFixed(2)}',
            style: AppTypography.amount.copyWith(
              color: AppColors.white,
              fontSize: 50,
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: '收入',
                  amount: income,
                  color: AppColors.income,
                ),
              ),
              Container(
                width: 1,
                height: 54,
                color: AppColors.white.withValues(alpha: 0.22),
              ),
              Expanded(
                child: _MiniStat(
                  label: '支出',
                  amount: expense,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.white.withValues(alpha: 0.78),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: AppTypography.body.copyWith(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final MonthlyBudgetDto? budget;
  final bool loading;
  final VoidCallback onEdit;

  const _BudgetCard({
    required this.budget,
    required this.loading,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budgetAmount = budget?.budgetAmount;
    final spent = budget?.spentAmount ?? 0;
    final isSet = budgetAmount != null;
    final remaining = budget?.remaining;
    final isOver = budget?.isOverBudget ?? false;
    final progressColor = isOver ? AppColors.expense : AppColors.income;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${now.month.toString().padLeft(2, '0')}月总预算',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    '编辑',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.navSelected,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: loading
                    ? Text(
                        '预算加载中',
                        style: AppTypography.subtitle.copyWith(fontSize: 25),
                      )
                    : Text(
                        isSet
                            ? '剩余预算：${_formatSignedCurrency(remaining ?? 0)}'
                            : '未设置预算',
                        style: AppTypography.subtitle.copyWith(
                          color: isOver ? AppColors.expense : AppColors.text,
                          fontSize: 25,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              _BudgetRing(
                progress: budget?.progress ?? 0,
                color: progressColor,
                isOver: isOver,
                isSet: isSet,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BudgetMiniValue(
                  label: '本月预算',
                  value: isSet ? _formatCurrency(budgetAmount) : '未设置',
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _BudgetMiniValue(
                  label: '本月支出',
                  value: _formatCurrency(spent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetMiniValue extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetMiniValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.62),
        borderRadius: AppRadius.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRing extends StatelessWidget {
  final double progress;
  final Color color;
  final bool isOver;
  final bool isSet;

  const _BudgetRing({
    required this.progress,
    required this.color,
    required this.isOver,
    required this.isSet,
  });

  @override
  Widget build(BuildContext context) {
    final displayProgress = isOver ? 1.0 : progress;
    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(
        painter: _BudgetRingPainter(progress: displayProgress, color: color),
        child: Center(
          child: Text(
            isSet ? '${(displayProgress * 100).round()}%' : '--',
            style: AppTypography.caption.copyWith(
              color: isSet ? color : AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _BudgetRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 6.0;
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.divider.withValues(alpha: 0.76);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(rect.deflate(stroke / 2), 0, math.pi * 2, false, basePaint);
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BudgetRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _BudgetWarningBar extends StatelessWidget {
  final double overAmount;

  const _BudgetWarningBar({required this.overAmount});

  @override
  Widget build(BuildContext context) {
    const warningColor = Color(0xFFD32F2F);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: warningColor,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '今月已超预算 ¥${_formatMoney(overAmount)}元',
              style: AppTypography.caption.copyWith(
                color: warningColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillDateHeader extends StatelessWidget {
  final DateTime date;
  final String label;
  final double amount;

  const _BillDateHeader({
    required this.date,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Text(
            '${date.month.toString().padLeft(2, '0')}月'
            '${date.day.toString().padLeft(2, '0')}日',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _weekdayLabel(date),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          Text(
            '$label：${_formatCompactAmount(amount)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final _BillRecord record;
  final VoidCallback onTap;

  const _TxnTile({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.navSelected;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            _StatIcon(icon: record.icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.note.isNotEmpty ? record.note : record.category,
                    style: AppTypography.body.copyWith(
                      color: themeColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${record.account} · ${_formatBillTime(record.date)}',
                    style: AppTypography.caption.copyWith(
                      fontSize: 16,
                      color: themeColor.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              record.isIncome
                  ? '+¥${record.amount.toStringAsFixed(2)}'
                  : '-¥${record.amount.abs().toStringAsFixed(2)}',
              style: AppTypography.body.copyWith(
                color: record.isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillDetailSheet extends StatelessWidget {
  final _BillRecord record;

  const _BillDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.navSelected;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              _StatIcon(icon: record.icon),
              const SizedBox(height: 14),
              Text(
                record.isIncome
                    ? '+¥${record.amount.toStringAsFixed(2)}'
                    : '-¥${record.amount.abs().toStringAsFixed(2)}',
                style: AppTypography.amount.copyWith(
                  color: record.isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              const SizedBox(height: 22),
              _DetailRow(label: '类别', value: record.category),
              _DetailRow(label: '账户', value: record.account),
              _DetailRow(label: '时间', value: _formatFullDateTime(record.date)),
              _DetailRow(
                label: '备注',
                value: record.note.isEmpty ? '无' : record.note,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '凭证附件',
                  style: AppTypography.body.copyWith(
                    color: themeColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ReceiptAttachmentPanel(
                imagePaths: record.receiptImagePaths,
                receiptCount: record.receiptCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptAttachmentPanel extends StatelessWidget {
  final List<String> imagePaths;
  final int receiptCount;

  const _ReceiptAttachmentPanel({
    required this.imagePaths,
    required this.receiptCount,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.navSelected;
    if (imagePaths.isEmpty) {
      return Container(
        width: double.infinity,
        height: 126,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Text(
          receiptCount == 0 ? '暂无图片凭证' : '图片凭证加载失败',
          style: AppTypography.caption.copyWith(
            color: themeColor.withValues(alpha: 0.64),
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: imagePaths.asMap().entries.map((entry) {
          final size = (MediaQuery.of(context).size.width - 96) / 3;
          return GestureDetector(
            onTap: () =>
                _showReceiptImageViewer(context, imagePaths, entry.key),
            child: ClipRRect(
              borderRadius: AppRadius.sm,
              child: SizedBox(
                width: size,
                height: size,
                child: _ReceiptAttachmentImage(path: entry.value),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReceiptAttachmentImage extends StatelessWidget {
  final String path;

  const _ReceiptAttachmentImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return FutureBuilder<Uint8List>(
      future: XFile(path).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          );
        }
        if (snapshot.hasError) return _fallback();
        return Container(
          color: AppColors.card,
          alignment: Alignment.center,
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.navSelected,
            ),
          ),
        );
      },
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.card,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textHint,
        size: 30,
      ),
    );
  }
}

void _showReceiptImageViewer(
  BuildContext context,
  List<String> imagePaths,
  int initialIndex,
) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    builder: (context) {
      final controller = PageController(initialPage: initialIndex);
      return Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Center(
                      child: _ReceiptAttachmentImage(path: imagePaths[index]),
                    ),
                  );
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.navSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: themeColor.withValues(alpha: 0.62),
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body.copyWith(
                color: themeColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportPage extends StatelessWidget {
  final List<_BillRecord> records;
  final _ReportType reportType;
  final DateTime selectedMonth;
  final VoidCallback onBack;
  final ValueChanged<_ReportType> onReportTypeChanged;
  final VoidCallback onMonthTap;

  const _ReportPage({
    required this.records,
    required this.reportType,
    required this.selectedMonth,
    required this.onBack,
    required this.onReportTypeChanged,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthRecords = records
        .where(
          (record) =>
              _isSameMonth(record.date, selectedMonth) &&
              (reportType == _ReportType.income
                  ? record.isIncome
                  : !record.isIncome),
        )
        .toList();
    final total = monthRecords.fold(
      0.0,
      (sum, record) => sum + record.amount.abs(),
    );
    final title = reportType == _ReportType.income ? '收入' : '支出';
    final categories = _buildCategoryStats(
      records,
      selectedMonth,
      reportType == _ReportType.income,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  _BackButton(onTap: onBack),
                  const Spacer(),
                  _ReportTabs(
                    selected: reportType,
                    onChanged: onReportTypeChanged,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: onMonthTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppRadius.capsule,
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMonth(selectedMonth),
                          style: AppTypography.body.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: _secondaryText,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _ReportSummary(
                text:
                    '共$title${monthRecords.length}笔，合计¥${total.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 22),
              _BarChartCard(
                records: records,
                selectedMonth: selectedMonth,
                reportType: reportType,
              ),
              const SizedBox(height: 22),
              _DonutSection(
                title: reportType == _ReportType.income ? '收入来源' : '支出分类',
                stats: categories,
                emptyText: '暂无$title分类数据',
              ),
              const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Icon(Icons.arrow_back_ios_new, size: 28, color: _primaryBlue),
      ),
    );
  }
}

class _ReportTabs extends StatelessWidget {
  final _ReportType selected;
  final ValueChanged<_ReportType> onChanged;

  const _ReportTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.capsule,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ReportTab(
            label: '收入',
            selected: selected == _ReportType.income,
            onTap: () => onChanged(_ReportType.income),
          ),
          _ReportTab(
            label: '支出',
            selected: selected == _ReportType.expense,
            onTap: () => onChanged(_ReportType.expense),
          ),
        ],
      ),
    );
  }
}

class _ReportTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReportTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
        width: 78,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _primaryBlue : Colors.transparent,
          borderRadius: AppRadius.capsule,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.white : _secondaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  final String text;

  const _ReportSummary({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.subtitle.copyWith(fontSize: 24),
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final List<_BillRecord> records;
  final DateTime selectedMonth;
  final _ReportType reportType;

  const _BarChartCard({
    required this.records,
    required this.selectedMonth,
    required this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    final months = List.generate(
      6,
      (index) => DateTime(selectedMonth.year, selectedMonth.month - 5 + index),
    );
    final income = reportType == _ReportType.income;
    final chartColor = income ? AppColors.income : AppColors.expense;
    final chartTitle = income ? '每月收入趋势' : '每月支出趋势';
    final maxValue = months.fold<double>(1, (max, month) {
      final value = _monthTotal(records, month, income);
      return math.max(max, value);
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chartTitle,
            style: AppTypography.subtitle.copyWith(fontSize: 23),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: months.map((month) {
              final selected = _isSameMonth(month, selectedMonth);
              return Expanded(
                child: _BarMonth(
                  month: month,
                  value: _monthTotal(records, month, income),
                  maxValue: maxValue,
                  color: chartColor,
                  selected: selected,
                  showYearMarker: month.month == 1,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: chartColor, label: income ? '收入' : '支出'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarMonth extends StatelessWidget {
  final DateTime month;
  final double value;
  final double maxValue;
  final Color color;
  final bool selected;
  final bool showYearMarker;

  const _BarMonth({
    required this.month,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.selected,
    required this.showYearMarker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: selected
          ? BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.06),
              borderRadius: AppRadius.sm,
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 138,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _MiniBar(
                value: value,
                maxValue: maxValue,
                color: color,
                selected: selected,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (showYearMarker)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _primaryBlue.withValues(alpha: 0.72),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${month.year}',
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          height: 1,
                          color: _secondaryText,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 12),
                Text(
                  '${month.month}月',
                  style: AppTypography.caption.copyWith(
                    fontSize: 16,
                    height: 1.2,
                    color: selected ? _primaryBlue : _secondaryText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;
  final bool selected;

  const _MiniBar({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final height = value <= 0 ? 6.0 : math.max(12.0, 128 * value / maxValue);
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? 0.88 : 0.28),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 17)),
      ],
    );
  }
}

class _DonutSection extends StatelessWidget {
  final String title;
  final List<_CategoryStat> stats;
  final String emptyText;

  const _DonutSection({
    required this.title,
    required this.stats,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats.fold(0.0, (sum, item) => sum + item.amount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.navSelected,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 20),
          if (stats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 34),
                child: Text(
                  emptyText,
                  style: AppTypography.caption.copyWith(fontSize: 18),
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 176,
                height: 176,
                child: CustomPaint(
                  painter: _DonutPainter(stats: stats),
                  child: Center(
                    child: Text(
                      '¥${total.toStringAsFixed(0)}',
                      style: AppTypography.body.copyWith(
                        color: AppColors.navSelected,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            ...stats.map((stat) => _CategoryStatRow(stat: stat, total: total)),
          ],
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_CategoryStat> stats;

  const _DonutPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    final total = stats.fold(0.0, (sum, item) => sum + item.amount);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    var start = -math.pi / 2;
    for (final stat in stats) {
      final sweep = (stat.amount / total) * math.pi * 2;
      paint.color = stat.color;
      canvas.drawArc(rect.deflate(16), start, sweep - 0.04, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.stats != stats;
}

class _CategoryStatRow extends StatelessWidget {
  final _CategoryStat stat;
  final double total;

  const _CategoryStatRow({required this.stat, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : stat.amount / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _StatIcon(icon: stat.icon, color: stat.color),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              stat.name,
              style: AppTypography.body.copyWith(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '¥${stat.amount.toStringAsFixed(0)}  ${(pct * 100).round()}%',
            style: AppTypography.caption.copyWith(
              color: stat.color,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialMonth;

  const _MonthPickerDialog({required this.initialMonth});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
    _month = widget.initialMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('选择月份', style: AppTypography.subtitle.copyWith(fontSize: 25)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _year,
                    items:
                        List.generate(21, (i) => DateTime.now().year - 10 + i)
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text('$year年'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _year = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _month,
                    items: List.generate(12, (i) => i + 1)
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text('${month.toString().padLeft(2, '0')}月'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _month = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消', style: TextStyle(fontSize: 17)),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(DateTime(_year, _month)),
                  style: AppTheme.primaryFilledButtonStyle,
                  child: const Text('确定', style: TextStyle(fontSize: 17)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _StatIcon({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.navSelected;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 25, color: iconColor),
    );
  }
}

class _EmptyBills extends StatelessWidget {
  const _EmptyBills();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.card,
      ),
      alignment: Alignment.center,
      child: Text(
        '没有匹配的账单',
        style: AppTypography.caption.copyWith(fontSize: 18),
      ),
    );
  }
}

class _BillRecord {
  final String id;
  final String category;
  final String note;
  final String account;
  final DateTime date;
  final double amount;
  final IconData icon;
  final int receiptCount;
  final List<String> receiptImagePaths;

  const _BillRecord({
    required this.id,
    required this.category,
    required this.note,
    required this.account,
    required this.date,
    required this.amount,
    required this.icon,
    this.receiptCount = 0,
    this.receiptImagePaths = const [],
  });

  factory _BillRecord.fromDto(LedgerTransactionDto dto) {
    return _BillRecord(
      id: dto.id.toString(),
      category: dto.categoryName,
      note: dto.note,
      account: dto.accountName,
      date: dto.transactionTime,
      amount: dto.signedAmount,
      icon: LedgerIconCatalog.icon(dto.iconCode),
      receiptCount: dto.receiptCount,
      receiptImagePaths: dto.receiptImagePaths,
    );
  }

  bool get isIncome => amount >= 0;
}

class _CategoryStat {
  final String name;
  final double amount;
  final IconData icon;
  final Color color;

  const _CategoryStat({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

List<_CategoryStat> _buildCategoryStats(
  List<_BillRecord> records,
  DateTime month,
  bool income,
) {
  final grouped = <String, _CategoryStat>{};
  for (final record in records) {
    if (!_isSameMonth(record.date, month) || record.isIncome != income) {
      continue;
    }
    final existing = grouped[record.category];
    if (existing == null) {
      grouped[record.category] = _CategoryStat(
        name: record.category,
        amount: record.amount.abs(),
        icon: record.icon,
        color: _categoryVisualColor(record.category, income),
      );
    } else {
      grouped[record.category] = _CategoryStat(
        name: existing.name,
        amount: existing.amount + record.amount.abs(),
        icon: existing.icon,
        color: existing.color,
      );
    }
  }
  final result = grouped.values.toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
  return result;
}

double _monthTotal(List<_BillRecord> records, DateTime month, bool income) {
  return records
      .where(
        (record) =>
            _isSameMonth(record.date, month) && record.isIncome == income,
      )
      .fold(0.0, (sum, record) => sum + record.amount.abs());
}

bool _isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _weekdayLabel(DateTime date) {
  const labels = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return labels[date.weekday - 1];
}

String _formatCompactAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  if (fixed.endsWith('.00')) return fixed.substring(0, fixed.length - 3);
  if (fixed.endsWith('0')) return fixed.substring(0, fixed.length - 1);
  return fixed;
}

String _formatMoney(double value) => NumberFormat('#,##0.00').format(value);

String _formatCurrency(double value) => '¥${_formatMoney(value)}';

String _formatSignedCurrency(double value) {
  if (value < 0) return '-¥${_formatMoney(value.abs())}';
  return _formatCurrency(value);
}

String _billFilterLabel(_BillTypeFilter filter) {
  switch (filter) {
    case _BillTypeFilter.all:
      return '全部账单';
    case _BillTypeFilter.expense:
      return '支出';
    case _BillTypeFilter.income:
      return '收入';
  }
}

String _timeFilterLabel(_TimeFilter filter) {
  switch (filter) {
    case _TimeFilter.today:
      return '今天';
    case _TimeFilter.week:
      return '本周';
    case _TimeFilter.month:
      return '本月';
    case _TimeFilter.year:
      return '本年';
  }
}

String _formatBillTime(DateTime date) {
  final time = DateHelpers.formatTime(date);
  if (DateHelpers.isToday(date)) return '今天$time';
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  if (DateHelpers.isSameDay(date, yesterday)) return '昨天$time';
  return '${date.month}月${date.day}日 $time';
}

String _formatFullDateTime(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日 ${DateHelpers.formatTime(date)}';
}

String _formatMonth(DateTime date) {
  return '${date.year}年${date.month.toString().padLeft(2, '0')}月';
}
