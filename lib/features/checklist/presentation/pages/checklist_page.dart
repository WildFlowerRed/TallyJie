import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_durations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/constants.dart';
import '../../../../core/models/todo_item.dart';

/// 清单页
class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({super.key});

  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  final List<TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    // TODO: Replace with actual database loading
    setState(() {
      _items.clear();
      _items.addAll([
        TodoItem(title: '学习 Flutter 动画', priority: 2),
        TodoItem(title: '去超市购物', priority: 1),
        TodoItem(title: '阅读《设计中的设计》', isCompleted: true),
        TodoItem(title: '整理桌面', isCompleted: true),
      ]);
    });
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(
        isCompleted: !_items[index].isCompleted,
        completedAt: _items[index].isCompleted ? null : DateTime.now(),
      );
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final incompleteItems = _items.where((t) => !t.isCompleted).toList();
    final completedItems = _items.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                AppStrings.checklistTitle,
                style: AppTypography.title32,
              ),
            ),

            // 列表
            Expanded(
              child: _items.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (incompleteItems.isNotEmpty) ...[
                          _sectionHeader('待完成', incompleteItems.length),
                          ...incompleteItems.asMap().entries.map(
                                (e) => _TodoTile(
                                  item: e.value,
                                  onToggle: () => _toggleItem(
                                    _items.indexOf(e.value),
                                  ),
                                  onDelete: () => _deleteItem(
                                    _items.indexOf(e.value),
                                  ),
                                ),
                              ),
                        ],
                        if (completedItems.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _sectionHeader('已完成', completedItems.length),
                          ...completedItems.asMap().entries.map(
                                (e) => _TodoTile(
                                  item: e.value,
                                  onToggle: () => _toggleItem(
                                    _items.indexOf(e.value),
                                  ),
                                  onDelete: () => _deleteItem(
                                    _items.indexOf(e.value),
                                  ),
                                ),
                              ),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSheet(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
      child: Text(
        '$title · $count',
        style: AppTypography.caption14.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.checklist, size: 64, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(
            AppStrings.checklistEmpty,
            style: AppTypography.body17.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.checklistEmptySubtitle,
            style: AppTypography.caption14,
          ),
        ],
      ),
    );
  }

  void _showAddTodoSheet(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheet,
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖动指示器
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
              const SizedBox(height: 20),

              Text(
                AppStrings.checklistAddTodo,
                style: AppTypography.h1_26,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller,
                autofocus: true,
                style: AppTypography.body17,
                decoration: const InputDecoration(
                  hintText: '输入待办事项...',
                ),
              ),
              const SizedBox(height: 20),

              // 添加按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() {
                        _items.insert(
                          0,
                          TodoItem(title: controller.text.trim()),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navSelected,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.input,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '添加',
                    style: AppTypography.body17.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 待办事项 Tile
class _TodoTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todo_${item.id ?? item.title}'),
      onDismissed: (_) => onDelete(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: AppDurations.short,
          curve: AppTheme.easeOutQuart,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.card,
            boxShadow: const [AppShadows.card],
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: AppDurations.short,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? AppColors.success
                      : Colors.transparent,
                  border: Border.all(
                    color: item.isCompleted
                        ? AppColors.success
                        : AppColors.divider,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: item.isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),

              // 标题
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.body17.copyWith(
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isCompleted
                            ? AppColors.secondaryText
                            : AppColors.primaryText,
                      ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.notes!,
                          style: AppTypography.caption14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // 优先级指示器
              if (item.priority > 0)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _priorityColor(item.priority),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return AppColors.expense;
      case 2:
        return const Color(0xFFE8A84C);
      case 1:
        return AppColors.accent;
      default:
        return AppColors.divider;
    }
  }
}
