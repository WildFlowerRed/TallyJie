import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';

/// 收支明细 / 统计分析
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});
  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  String _range = '本月';

  // 模拟数据
  final double _balance = 3286.58;
  final double _income = 8520.00;
  final double _expense = 5233.42;

  final _expenseData = [
    {'icon': '🍜', 'name': '餐饮', 'amount': 1831.70, 'pct': 0.35, 'count': 42},
    {'icon': '🛒', 'name': '购物', 'amount': 1046.68, 'pct': 0.20, 'count': 15},
    {'icon': '🚗', 'name': '交通', 'amount': 785.01, 'pct': 0.15, 'count': 28},
    {'icon': '🎮', 'name': '娱乐', 'amount': 523.34, 'pct': 0.10, 'count': 8},
    {'icon': '💡', 'name': '水电', 'amount': 261.67, 'pct': 0.05, 'count': 2},
    {'icon': '📌', 'name': '其他', 'amount': 785.02, 'pct': 0.15, 'count': 12},
  ];

  final _incomeData = [
    {'icon': '💰', 'name': '工资', 'amount': 7500.00, 'pct': 0.88},
    {'icon': '🧧', 'name': '红包', 'amount': 620.00, 'pct': 0.07},
    {'icon': '📊', 'name': '投资', 'amount': 400.00, 'pct': 0.05},
  ];

  final _recentTxns = [
    {'icon': '🍜', 'name': '餐饮', 'note': '和朋友吃火锅', 'amount': -186.00, 'account': '微信', 'time': '今天 18:30'},
    {'icon': '🚗', 'name': '交通', 'note': '打车回家', 'amount': -32.50, 'account': '支付宝', 'time': '今天 17:00'},
    {'icon': '💰', 'name': '工资', 'note': '7月工资', 'amount': 7500.00, 'account': '银行卡', 'time': '7月15日'},
    {'icon': '🛒', 'name': '购物', 'note': '买了键盘', 'amount': -299.00, 'account': '支付宝', 'time': '7月14日'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // 标题
              Center(child: Text('收支明细', style: AppTypography.title)),
              const SizedBox(height: 16),

              // 时间筛选
              _TimeFilter(selected: _range, onChanged: (v) => setState(() => _range = v)),
              const SizedBox(height: 16),

              // 月度统计卡片
              _BalanceCard(balance: _balance, income: _income, expense: _expense),
              const SizedBox(height: 24),

              // 支出分类
              Text('支出分类', style: AppTypography.subtitle),
              const SizedBox(height: 12),
              ..._expenseData.map((e) => _CategoryBar(
                icon: e['icon'] as String, name: e['name'] as String,
                amount: e['amount'] as double, pct: e['pct'] as double,
                count: e['count'] as int, color: AppColors.expense,
              )),
              const SizedBox(height: 20),

              // 收入分类
              Text('收入来源', style: AppTypography.subtitle),
              const SizedBox(height: 12),
              ..._incomeData.map((e) => _CategoryBar(
                icon: e['icon'] as String, name: e['name'] as String,
                amount: e['amount'] as double, pct: e['pct'] as double,
                count: 0, color: AppColors.income,
              )),
              const SizedBox(height: 24),

              // 最近流水
              Text('最近流水', style: AppTypography.subtitle),
              const SizedBox(height: 12),
              ..._recentTxns.map((t) => _TxnTile(
                icon: t['icon'] as String, name: t['name'] as String,
                note: t['note'] as String, amount: t['amount'] as double,
                account: t['account'] as String, time: t['time'] as String,
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TimeFilter({required this.selected, required this.onChanged});

  static const _opts = ['今天', '本周', '本月', '本年'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _opts.map((o) {
        final sel = o == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(o),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.text : AppColors.surface,
                borderRadius: AppRadius.capsule,
              ),
              child: Text(o, style: AppTypography.caption.copyWith(
                color: sel ? AppColors.white : AppColors.textSecondary,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance, income, expense;
  const _BalanceCard({required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: AppRadius.lg,
      ),
      child: Column(
        children: [
          Text('本月结余', style: AppTypography.caption.copyWith(color: AppColors.accent)),
          const SizedBox(height: 8),
          Text('¥${balance.toStringAsFixed(2)}', style: AppTypography.amount.copyWith(color: AppColors.accent)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _MiniStat(label: '收入', amount: income, color: AppColors.income)),
              Container(width: 1, height: 40, color: AppColors.accent.withValues(alpha: 0.2)),
              Expanded(child: _MiniStat(label: '支出', amount: expense, color: AppColors.expense)),
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
  const _MiniStat({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: AppTypography.caption),
      const SizedBox(height: 4),
      Text('¥${amount.toStringAsFixed(2)}', style: AppTypography.body.copyWith(color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _CategoryBar extends StatelessWidget {
  final String icon, name;
  final double amount, pct;
  final int count;
  final Color color;
  const _CategoryBar({required this.icon, required this.name, required this.amount, required this.pct, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(children: [
            Text('$icon $name', style: AppTypography.body),
            const Spacer(),
            Text('¥${amount.toStringAsFixed(0)}  ${(pct * 100).toInt()}%', style: AppTypography.caption),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct, minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final String icon, name, note, account, time;
  final double amount;
  const _TxnTile({required this.icon, required this.name, required this.note, required this.amount, required this.account, required this.time});

  @override
  Widget build(BuildContext context) {
    final isIncome = amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: AppRadius.md, boxShadow: const [AppShadows.card]),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.isNotEmpty ? note : name, style: AppTypography.body.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text('$account · $time', style: AppTypography.caption.copyWith(fontSize: 12)),
          ],
        )),
        Text(
          isIncome ? '+¥${amount.toStringAsFixed(2)}' : '-¥${(-amount).toStringAsFixed(2)}',
          style: AppTypography.body.copyWith(color: isIncome ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ]),
    );
  }
}
