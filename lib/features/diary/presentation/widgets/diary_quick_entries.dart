import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// "今日小幸运" & "今日小进步" 快捷入口胶囊按钮
class DiaryQuickEntries extends StatelessWidget {
  final String luckyThing;
  final String progress;
  final ValueChanged<String> onLuckySaved;
  final ValueChanged<String> onProgressSaved;

  const DiaryQuickEntries({
    super.key,
    this.luckyThing = '',
    this.progress = '',
    required this.onLuckySaved,
    required this.onProgressSaved,
  });

  void _showInputSheet(BuildContext context, {
    required String title,
    required String hint,
    required String initialValue,
    required ValueChanged<String> onSaved,
  }) {
    final controller = TextEditingController(text: initialValue);

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
            Text(title, style: AppTypography.h1_26),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 2,
              style: AppTypography.body17.copyWith(fontSize: 15),
              decoration: InputDecoration(hintText: hint),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  onSaved(value.trim());
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
                  if (controller.text.trim().isNotEmpty) {
                    onSaved(controller.text.trim());
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
                child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showInputSheet(
                context,
                title: '今日小幸运',
                hint: '记录今天的小幸运...',
                initialValue: luckyThing,
                onSaved: onLuckySaved,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.luckyBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✨', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      luckyThing.isNotEmpty ? luckyThing : '今日小幸运',
                      style: AppTypography.caption14.copyWith(
                        color: luckyThing.isNotEmpty
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _showInputSheet(
                context,
                title: '今日小进步',
                hint: '记录今天的小进步...',
                initialValue: progress,
                onSaved: onProgressSaved,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.progressBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌱', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      progress.isNotEmpty ? progress : '今日小进步',
                      style: AppTypography.caption14.copyWith(
                        color: progress.isNotEmpty
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
