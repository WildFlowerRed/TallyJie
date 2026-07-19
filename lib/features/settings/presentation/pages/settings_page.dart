import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_typography.dart';

Future<void> showSettingsDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭设置',
    barrierColor: Colors.black.withValues(alpha: 0.18),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _SettingsDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  String _theme = '默认浅色';
  String? _fileStatus;

  static const _themes = [
    _ThemeOption('默认浅色', Color(0xFFFAF8F5), Color(0xFF1C1C1E)),
    _ThemeOption('流心粉色', Color(0xFFFFEEF3), Color(0xFFC96C86)),
    _ThemeOption('风雅青色', Color(0xFFE7F2EF), Color(0xFF5E7A6B)),
    _ThemeOption('经典黑白', Color(0xFFF7F7F7), Color(0xFF222222)),
  ];

  void _setFileStatus(String value) {
    setState(() => _fileStatus = value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 520),
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [AppShadows.card],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '设置',
                        style: AppTypography.subtitle.copyWith(fontSize: 26),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 28),
                        color: AppColors.navUnselected,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    icon: Icons.palette_outlined,
                    title: '主题设置',
                    child: Column(
                      children: [
                        for (var i = 0; i < _themes.length; i++) ...[
                          _ThemeTile(
                            option: _themes[i],
                            selected: _theme == _themes[i].label,
                            onTap: () {
                              setState(() => _theme = _themes[i].label);
                            },
                          ),
                          if (i != _themes.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    icon: Icons.file_download_outlined,
                    title: '数据导出',
                    child: _FileAction(
                      title: 'TallyJie_backup.zip',
                      subtitle: '选择手机本地位置保存 ZIP 备份包',
                      buttonLabel: '选择导出位置',
                      onTap: () => _setFileStatus('已选择导出位置，等待后端打包 ZIP'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    icon: Icons.file_upload_outlined,
                    title: '数据导入',
                    child: _FileAction(
                      title: '导入 ZIP 备份包',
                      subtitle: '从手机本地文件中选择 TallyJie 备份包',
                      buttonLabel: '选择导入文件',
                      onTap: () => _setFileStatus('已打开本地文件选择器，等待选择 ZIP'),
                    ),
                  ),
                  if (_fileStatus != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.sm,
                      ),
                      child: Text(
                        _fileStatus!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.text,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 26, color: AppColors.text),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.body.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final _ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.text : AppColors.card,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected ? AppColors.text : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: option.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: option.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: AppTypography.body.copyWith(
                  fontSize: 20,
                  color: selected ? AppColors.white : AppColors.text,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 25, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

class _FileAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _FileAction({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Text(subtitle, style: AppTypography.caption.copyWith(fontSize: 17)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: AppRadius.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonLabel,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.folder_open_outlined,
                  size: 25,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption {
  final String label;
  final Color background;
  final Color accent;

  const _ThemeOption(this.label, this.background, this.accent);
}
