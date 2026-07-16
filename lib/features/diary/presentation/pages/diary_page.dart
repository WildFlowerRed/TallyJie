import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/constants.dart';
import '../widgets/diary_header.dart';
import '../widgets/diary_editor.dart';
import '../widgets/spending_summary.dart';

/// 日记页 - App 首页
class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 日期头部
            SliverToBoxAdapter(
              child: DiaryHeader(
                date: today,
                weather: 'sunny',
                mood: 4,
                onWeatherChanged: (w) {},
                onMoodChanged: (m) {},
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 今日消费
            SliverToBoxAdapter(
              child: _buildSection(
                title: AppStrings.diaryTodaySpending,
                child: const SpendingSummary(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 今天想说
            SliverToBoxAdapter(
              child: _buildSection(
                title: AppStrings.diaryTodayThoughts,
                child: const DiaryEditor(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: AppTypography.caption14.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
