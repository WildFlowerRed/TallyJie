import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';

/// 我的页面
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // 头像
              _buildAvatar(),
              const SizedBox(height: 16),

              // 昵称
              Text(
                'LifeOS',
                style: AppTypography.title32,
              ),
              const SizedBox(height: 8),

              // 连续记录天数
              _buildStreakBadge(),
              const SizedBox(height: 32),

              // 统计数据
              _buildStatsRow(),
              const SizedBox(height: 32),

              // 生活值
              _buildLifeValueCard(),
              const SizedBox(height: 24),

              // 快捷操作
              _buildQuickActions(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryBg,
        border: Border.all(
          color: AppColors.accent,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 40,
        color: AppColors.accent,
      ),
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryBg,
        borderRadius: AppRadius.tag,
      ),
      child: Text(
        '${AppStrings.profileStreak} 128 ${AppStrings.profileDays}',
        style: AppTypography.caption14.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: '256', label: AppStrings.profileDiaries),
        _buildDivider(),
        _StatItem(value: '2,580', label: AppStrings.profileTransactions),
        _buildDivider(),
        _StatItem(value: '620', label: AppStrings.profilePhotos),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.divider,
    );
  }

  Widget _buildLifeValueCard() {
    return GestureDetector(
      onTap: () => context.push('/profile/statistics'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.card,
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          children: [
            Text(
              AppStrings.statsLifeValue,
              style: AppTypography.h1_26,
            ),
            const SizedBox(height: 20),

            // 圆形进度
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 0.78,
                      strokeWidth: 8,
                      backgroundColor: AppColors.secondaryBg,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent,
                      ),
                    ),
                  ),
                  Text(
                    '78%',
                    style: AppTypography.amount34.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '这个月奶茶喝得有点多。',
              style: AppTypography.caption14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionItem(
        icon: Icons.menu_book_outlined,
        label: AppStrings.profileBookMode,
        onTap: () => context.push('/profile/book'),
      ),
      _ActionItem(
        icon: Icons.bar_chart_outlined,
        label: AppStrings.statsTitle,
        onTap: () => context.push('/profile/statistics'),
      ),
      _ActionItem(
        icon: Icons.settings_outlined,
        label: AppStrings.profileSettings,
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final isLast = entry.key == actions.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  entry.value.icon,
                  color: AppColors.primaryText,
                ),
                title: Text(
                  entry.value.label,
                  style: AppTypography.body17,
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.secondaryText,
                ),
                onTap: entry.value.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: Divider(height: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h1_26.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption14),
      ],
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
