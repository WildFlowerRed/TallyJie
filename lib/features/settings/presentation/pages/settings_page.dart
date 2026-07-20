import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_font_family.dart';
import '../../../../app/theme/app_font_scale.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/services/local_data_api.dart';

const _backupChannel = MethodChannel('com.tallyjie.tallyjie/backup');

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
  String _theme = AppColors.currentTheme;
  String _fontFamilyKey = AppFontFamily.currentKey;
  int _fontScaleIndex = AppFontScale.selectedIndex;
  String? _fileStatus;
  bool _busy = false;

  Future<void> _exportData() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _fileStatus = '正在整理本地数据...';
    });
    try {
      final backup = await LocalDataApi.instance.exportBackupPackage();
      if (!mounted) return;
      setState(() => _fileStatus = '请选择导出保存位置');

      final file = XFile.fromData(
        backup.bytes,
        name: backup.fileName,
        mimeType: 'application/zip',
      );
      final saved = await _saveBackupFile(backup, file);
      if (!saved) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _fileStatus = '已取消导出';
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _fileStatus =
            '导出成功：${backup.transactionCount} 条账单、${backup.diaryCount} 篇日记';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _fileStatus = '导出失败：$error';
      });
    }
  }

  Future<bool> _saveBackupFile(BackupPackageDto backup, XFile file) async {
    final typeGroups = [
      const XTypeGroup(label: 'TallyJie 备份包', extensions: ['zip']),
    ];

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final uri = await _backupChannel.invokeMethod<String>('saveZip', {
        'fileName': backup.fileName,
        'bytes': backup.bytes,
      });
      return uri != null;
    }

    final location = await getSaveLocation(
      suggestedName: backup.fileName,
      acceptedTypeGroups: typeGroups,
      confirmButtonText: '导出',
      canCreateDirectories: true,
    );
    if (location == null) return false;
    await file.saveTo(location.path);
    return true;
  }

  Future<void> _importData() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _fileStatus = '请选择 TallyJie 备份包';
    });
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(label: 'TallyJie 备份包', extensions: ['zip', 'json']),
        ],
        confirmButtonText: '导入',
      );
      if (file == null) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _fileStatus = '已取消导入';
        });
        return;
      }
      final result = await LocalDataApi.instance.importBackupPackage(
        await file.readAsBytes(),
        fileName: file.name,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _fileStatus =
            '导入成功：${result.transactionCount} 条账单、${result.diaryCount} 篇日记、${result.budgetCount} 条预算';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _fileStatus = '导入失败：$error';
      });
    }
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
              boxShadow: AppShadows.card,
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 48),
                        child: Text(
                          '设置',
                          style: AppTypography.subtitle.copyWith(fontSize: 26),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        icon: Icons.font_download_outlined,
                        title: '字体选择',
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < AppFontFamily.options.length;
                              i++
                            ) ...[
                              _FontFamilyTile(
                                option: AppFontFamily.options[i],
                                selected:
                                    _fontFamilyKey ==
                                    AppFontFamily.options[i].key,
                                onTap: () {
                                  AppFontFamily.apply(
                                    AppFontFamily.options[i].key,
                                  );
                                  setState(
                                    () => _fontFamilyKey =
                                        AppFontFamily.options[i].key,
                                  );
                                },
                              ),
                              if (i != AppFontFamily.options.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        icon: Icons.format_size_outlined,
                        title: '字体大小',
                        child: _FontScaleControl(
                          selectedIndex: _fontScaleIndex,
                          onChanged: (index) {
                            AppFontScale.apply(AppFontScale.steps[index]);
                            setState(() => _fontScaleIndex = index);
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        icon: Icons.palette_outlined,
                        title: '主题设置',
                        child: Column(
                          children: [
                            for (
                              var i = 0;
                              i < AppColors.palettes.length;
                              i++
                            ) ...[
                              _ThemeTile(
                                option: AppColors.palettes[i],
                                selected: _theme == AppColors.palettes[i].label,
                                onTap: () {
                                  AppColors.applyPalette(AppColors.palettes[i]);
                                  setState(
                                    () => _theme = AppColors.palettes[i].label,
                                  );
                                },
                              ),
                              if (i != AppColors.palettes.length - 1)
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
                          buttonLabel: _busy ? '处理中' : '选择导出位置',
                          onTap: _exportData,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        icon: Icons.file_upload_outlined,
                        title: '数据导入',
                        child: _FileAction(
                          title: '导入 ZIP 备份包',
                          subtitle: '从手机本地文件中选择 TallyJie 备份包',
                          buttonLabel: _busy ? '处理中' : '选择导入文件',
                          onTap: _importData,
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
                Positioned(
                  top: -6,
                  right: -8,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 28),
                    color: AppColors.navUnselected,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
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

class _FontScaleControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _FontScaleControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  void _updateFromPosition(double dx, double width) {
    if (width <= 0) return;
    final usableWidth = width - 44;
    final value = ((dx - 22) / usableWidth).clamp(0.0, 1.0);
    final index = (value * (AppFontScale.steps.length - 1)).round();
    onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final percent = AppFontScale.label(AppFontScale.steps[selectedIndex]);
    return Column(
      children: [
        Center(
          child: Text(
            percent,
            style: AppTypography.title.copyWith(
              color: AppColors.navSelected,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'A',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 28,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: SizedBox(
                height: 52,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final progress =
                        selectedIndex / (AppFontScale.steps.length - 1);
                    final centerX = 22 + (width - 44) * progress;
                    final activeWidth = (centerX + 20).clamp(40.0, width);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) =>
                          _updateFromPosition(details.localPosition.dx, width),
                      onHorizontalDragUpdate: (details) =>
                          _updateFromPosition(details.localPosition.dx, width),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.capsule,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutQuart,
                            width: activeWidth,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.navSelected,
                              borderRadius: AppRadius.capsule,
                            ),
                          ),
                          for (var i = 0; i < AppFontScale.steps.length; i++)
                            Positioned(
                              left:
                                  22 +
                                  (width - 44) *
                                      (i / (AppFontScale.steps.length - 1)) -
                                  5,
                              top: 21,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: i <= selectedIndex
                                      ? AppColors.white.withValues(alpha: 0.45)
                                      : AppColors.divider,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutQuart,
                            left: centerX - 20,
                            top: 6,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowColor.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 18),
            Text(
              'A',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 44,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FontFamilyTile extends StatelessWidget {
  final AppFontOption option;
  final bool selected;
  final VoidCallback onTap;

  const _FontFamilyTile({
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.navSelected.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected
                ? AppColors.navSelected.withValues(alpha: 0.38)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navSelected.withValues(alpha: 0.09),
                borderRadius: AppRadius.sm,
              ),
              child: Text(
                option.sample,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.subtitle.copyWith(
                  fontFamily: option.family,
                  color: AppColors.navSelected,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTypography.body.copyWith(
                      fontFamily: option.family,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: AppTypography.caption.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? Icon(
                      Icons.check_circle,
                      key: const ValueKey('selected'),
                      color: AppColors.navSelected,
                      size: 25,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: const ValueKey('unselected'),
                      color: AppColors.textHint,
                      size: 22,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final AppThemePalette option;
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? option.accent.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: selected
                ? option.accent.withValues(alpha: 0.36)
                : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: AppTypography.body.copyWith(
                      fontSize: 20,
                      color: option.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, size: 25, color: option.accent),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option.description,
                style: AppTypography.caption.copyWith(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PalettePreview(option: option),
          ],
        ),
      ),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  final AppThemePalette option;

  const _PalettePreview({required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: option.bg,
        borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: option.card,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _PaletteDot(color: option.accent),
                  const SizedBox(width: 6),
                  _PaletteBar(color: option.text, width: 30),
                  const SizedBox(width: 4),
                  _PaletteBar(color: option.textSecondary, width: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PaletteSwatch(color: option.surface),
          const SizedBox(width: 6),
          _PaletteSwatch(color: option.textSecondary),
          const SizedBox(width: 6),
          _PaletteSwatch(color: option.accent),
        ],
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  final Color color;

  const _PaletteDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PaletteBar extends StatelessWidget {
  final Color color;
  final double width;

  const _PaletteBar({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final Color color;

  const _PaletteSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
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
