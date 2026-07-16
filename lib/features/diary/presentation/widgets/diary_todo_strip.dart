import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/models/todo_item.dart';

/// 今日完成 — 水平滚动标签条
class DiaryTodoStrip extends StatefulWidget {
  final List<TodoItem> items;
  final ValueChanged<String> onAdd;

  const DiaryTodoStrip({
    super.key,
    required this.items,
    required this.onAdd,
  });

  @override
  State<DiaryTodoStrip> createState() => _DiaryTodoStripState();
}

class _DiaryTodoStripState extends State<DiaryTodoStrip> {
  final TextEditingController _controller = TextEditingController();

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('快速添加待办', style: AppTypography.h1_26),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              style: AppTypography.body17,
              decoration: const InputDecoration(
                hintText: '输入待办事项...',
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onAdd(value.trim());
                  _controller.clear();
                  Navigator.pop(ctx);
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onAdd(_controller.text.trim());
                    _controller.clear();
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navSelected,
                  foregroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('添加', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedItems = widget.items.where((t) => t.isCompleted).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 16, color: AppColors.sageGreen),
                const SizedBox(width: 6),
                Text(
                  '今日完成',
                  style: AppTypography.caption14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // 标签滚动条
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: completedItems.length + 1,
              itemBuilder: (context, index) {
                // "+" 按钮
                if (index == completedItems.length) {
                  return GestureDetector(
                    onTap: _showAddDialog,
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  );
                }

                // 已完成标签
                final item = completedItems[index];
                return Container(
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 14, color: AppColors.sageGreen),
                      const SizedBox(width: 4),
                      Text(
                        item.title,
                        style: AppTypography.caption14.copyWith(
                          color: AppColors.sageGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
