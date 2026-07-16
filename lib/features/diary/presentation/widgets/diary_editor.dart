import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';

/// 日记编辑器 - 大文本 + 工具栏
class DiaryEditor extends StatefulWidget {
  const DiaryEditor({super.key});

  @override
  State<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends State<DiaryEditor> {
  final TextEditingController _controller = TextEditingController();
  bool _showPreview = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文本输入 / 预览
          _showPreview ? _buildPreview() : _buildEditor(),

          const SizedBox(height: 12),

          // 底部工具栏
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return TextField(
      controller: _controller,
      maxLines: 6,
      minLines: 3,
      style: AppTypography.body17,
      decoration: InputDecoration(
        hintText: AppStrings.diaryEditorHint,
        hintStyle: AppTypography.body17.copyWith(
          color: AppColors.secondaryText,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        filled: false,
      ),
    );
  }

  Widget _buildPreview() {
    final text = _controller.text;
    if (text.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            '还没有写内容',
            style: AppTypography.caption14,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: AppTypography.body17,
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ToolbarIcon(
          icon: Icons.image_outlined,
          label: '图片',
          onTap: () => _showComingSoon('图片'),
        ),
        _ToolbarIcon(
          icon: Icons.videocam_outlined,
          label: '视频',
          onTap: () => _showComingSoon('视频'),
        ),
        _ToolbarIcon(
          icon: Icons.mic_outlined,
          label: '录音',
          onTap: () => _showComingSoon('录音'),
        ),
        _ToolbarIcon(
          icon: Icons.location_on_outlined,
          label: '位置',
          onTap: () => _showComingSoon('位置'),
        ),
        _ToolbarIcon(
          icon: Icons.label_outline,
          label: '标签',
          onTap: () => _showComingSoon('标签'),
        ),
        _ToolbarIcon(
          icon: _showPreview ? Icons.edit_outlined : Icons.visibility_outlined,
          label: _showPreview ? '编辑' : '预览',
          onTap: () => setState(() => _showPreview = !_showPreview),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能即将上线'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: AppColors.secondaryText),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.navLabel.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
