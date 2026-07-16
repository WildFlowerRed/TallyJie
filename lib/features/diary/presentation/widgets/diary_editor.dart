import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// "今天想说" 富文本输入区
class DiaryEditor extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const DiaryEditor({
    super.key,
    this.initialText = '',
    required this.onSave,
  });

  @override
  State<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends State<DiaryEditor> {
  final TextEditingController _controller = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(_controller.text);
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.edit_note, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  '今天想说',
                  style: AppTypography.caption14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // 输入框
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 3,
                  style: AppTypography.body17.copyWith(
                    fontSize: 15,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: '今天发生了什么...',
                    hintStyle: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                    filled: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 10),
                  child: GestureDetector(
                    onTap: _handleSave,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _saved
                            ? AppColors.sageGreen
                            : AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _saved ? '已保存' : '记录',
                        style: AppTypography.caption14.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
