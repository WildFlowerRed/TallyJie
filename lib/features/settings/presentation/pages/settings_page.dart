import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';

/// 设置页
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _themeMode = '浅色';

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
              Center(child: Text('设置', style: AppTypography.title)),
              const SizedBox(height: 24),

              // 头像 + 版本
              Center(
                child: Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
                    child: const Icon(Icons.person_outline, size: 36, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text('TallyJie', style: AppTypography.subtitle),
                  Text('v1.0.0', style: AppTypography.caption),
                ]),
              ),
              const SizedBox(height: 28),

              // 列表
              _SectionCard(
                title: '外观',
                children: [
                  _ListTile(
                    icon: Icons.palette_outlined,
                    label: '主题设置',
                    trailing: Text(_themeMode, style: AppTypography.caption),
                    onTap: () => _showThemePicker(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: '数据管理',
                children: [
                  _ListTile(icon: Icons.category_outlined, label: '分类管理', onTap: () {}),
                  _ListTile(icon: Icons.account_balance_wallet_outlined, label: '账户管理', onTap: () {}),
                  _ListTile(icon: Icons.mood_outlined, label: '心情管理', onTap: () {}),
                  _ListTile(icon: Icons.wb_sunny_outlined, label: '天气管理', onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: '备份与恢复',
                children: [
                  _ListTile(icon: Icons.file_download_outlined, label: '数据导出', subtitle: 'JSON / CSV 格式', onTap: () {}),
                  _ListTile(icon: Icons.file_upload_outlined, label: '数据导入', subtitle: '从备份文件恢复', onTap: () {}),
                  _ListTile(icon: Icons.backup_outlined, label: '备份管理', subtitle: '自动备份设置', onTap: () {}),
                  _ListTile(icon: Icons.cleaning_services_outlined, label: '图片缓存清理', onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: '其他',
                children: [
                  _ListTile(icon: Icons.info_outline, label: '关于 TallyJie', onTap: () {}),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('主题设置', style: AppTypography.subtitle),
              const SizedBox(height: 16),
              for (final mode in ['浅色', '深色', '跟随系统'])
                ListTile(
                  title: Text(mode, style: AppTypography.body),
                  trailing: _themeMode == mode ? const Icon(Icons.check, color: AppColors.accent) : null,
                  onTap: () {
                    setState(() => _themeMode = mode);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.lg,
            boxShadow: const [AppShadows.card],
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final last = e.key == children.length - 1;
              return Column(children: [
                e.value,
                if (!last) const Padding(
                  padding: EdgeInsets.only(left: 52),
                  child: Divider(height: 1),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _ListTile({required this.icon, required this.label, this.subtitle, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.text),
      title: Text(label, style: AppTypography.body.copyWith(fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTypography.caption.copyWith(fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
    );
  }
}
