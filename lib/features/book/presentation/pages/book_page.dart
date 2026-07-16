import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';

/// 书本模式 - 翻页浏览日记
class BookPage extends ConsumerStatefulWidget {
  const BookPage({super.key});

  @override
  ConsumerState<BookPage> createState() => _BookPageState();
}

class _BookPageState extends ConsumerState<BookPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 模拟日记数据
  final _pages = [
    _BookPageData(title: '2026', subtitle: '新的一年', content: ''),
    _BookPageData(title: '春天', subtitle: '万物复苏的季节', content: ''),
    _BookPageData(title: '4月', subtitle: '春意盎然', content: ''),
    _BookPageData(
      title: '今天',
      subtitle: '2026年7月16日',
      content: '今天去喝了瑞幸的冰美式，\n下午吃了兰州拉面，\n晚上去超市买了些日用品。\n\n生活平淡但充实。',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        title: const Text('书本模式'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _BookSpread(
                  page: page,
                  pageNumber: index + 1,
                );
              },
            ),
          ),

          // 底部页码
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _currentPage > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
                Text(
                  '第 ${_currentPage + 1} 页 / 共 ${_pages.length} 页',
                  style: AppTypography.caption14,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _currentPage < _pages.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookPageData {
  final String title;
  final String subtitle;
  final String content;

  _BookPageData({
    required this.title,
    required this.subtitle,
    required this.content,
  });
}

/// 书本展开的两页
class _BookSpread extends StatelessWidget {
  final _BookPageData page;
  final int pageNumber;

  const _BookSpread({
    required this.page,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.card,
          boxShadow: [
            AppShadows.card,
            BoxShadow(
              color: AppColors.navSelected.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(4, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 左页 - 装订线效果
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 页码
                    Text(
                      '$pageNumber',
                      style: AppTypography.caption14.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    // 内容
                    Text(
                      page.content,
                      style: AppTypography.body17.copyWith(height: 1.8),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // 中间装订线
            Container(
              width: 2,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.divider.withValues(alpha: 0.3),
                    AppColors.divider.withValues(alpha: 0.5),
                    AppColors.divider.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 右页
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        page.title,
                        style: AppTypography.title32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        page.subtitle,
                        style: AppTypography.body17.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 40,
                        height: 2,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
