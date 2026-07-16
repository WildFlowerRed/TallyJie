import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';
import '../../../../core/utils/date_helpers.dart';

/// 单页日记 — 一天一页，左右滑动翻页
class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  late DateTime _currentDate;
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _textController = TextEditingController();
  Timer? _autoSaveTimer;

  String _mood = '😊';
  String _moodLabel = '开心';
  String _weather = 'sunny';
  String _weatherLabel = '晴';
  String _content = '';
  List<String> _images = [];
  String? _savedTime;

  // 缓存三天的数据
  final Map<String, _DayData> _cache = {};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    final newDate = _currentDate.add(Duration(days: page - _currentPageIndex));
    if (!DateHelpers.isSameDay(newDate, _currentDate)) {
      _saveCurrent();
      _currentDate = newDate;
      _loadDate(newDate);
      setState(() {});
    }
  }

  int get _currentPageIndex => 0;

  void _saveCurrent() {
    _cache[_dateKey(_currentDate)] = _DayData(
      content: _content, mood: _mood, moodLabel: _moodLabel,
      weather: _weather, weatherLabel: _weatherLabel, images: List.from(_images),
    );
  }

  void _loadDate(DateTime date) {
    final key = _dateKey(date);
    final cached = _cache[key];
    if (cached != null) {
      _content = cached.content;
      _mood = cached.mood;
      _moodLabel = cached.moodLabel;
      _weather = cached.weather;
      _weatherLabel = cached.weatherLabel;
      _images = List.from(cached.images);
    } else {
      _content = '';
      _mood = '😊';
      _moodLabel = '开心';
      _weather = 'sunny';
      _weatherLabel = '晴';
      _images = [];
    }
    _textController.text = _content;
    _savedTime = null;
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      _content = _textController.text;
      _saveCurrent();
      setState(() {
        _savedTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      });
    });
  }

  void _goToPrevDay() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goToNextDay() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // Placeholder builders for the 3 pages in PageView
  Widget _buildDayPage(DateTime date) {
    final key = _dateKey(date);
    final data = _cache[key];
    final isCurrent = DateHelpers.isSameDay(date, _currentDate);

    return _DiaryContent(
      date: date,
      content: isCurrent ? _textController.text : (data?.content ?? ''),
      mood: isCurrent ? _mood : (data?.mood ?? '😊'),
      moodLabel: isCurrent ? _moodLabel : (data?.moodLabel ?? '开心'),
      weather: isCurrent ? _weather : (data?.weather ?? 'sunny'),
      weatherLabel: isCurrent ? _weatherLabel : (data?.weatherLabel ?? '晴'),
      images: isCurrent ? _images : (data?.images ?? []),
      savedTime: isCurrent ? _savedTime : null,
      isCurrent: isCurrent,
      textController: isCurrent ? _textController : null,
      onTextChanged: isCurrent ? () => _scheduleAutoSave() : null,
      onMoodTap: isCurrent ? _showMoodPicker : null,
      onWeatherTap: isCurrent ? _showWeatherPicker : null,
      onAddImage: isCurrent ? _addImage : null,
      onRemoveImage: isCurrent ? (int i) { setState(() { _images.removeAt(i); }); } : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // For now, use a simpler approach - show current day with navigation buttons
    // PageView with 3 pages (prev, current, next) would need more complex state management
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 导航栏 (~90px, 居中两行)
            _buildNavHeader(),
            // 内容区
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! > 300) {
                    _goToPrevDay();
                  } else if (details.primaryVelocity! < -300) {
                    _goToNextDay();
                  }
                },
                child: _buildDayPage(_currentDate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavHeader() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 上一天
          _CircleBtn(icon: Icons.chevron_left, onTap: _goToPrevDay),
          const Spacer(),
          // 居中标题
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.navDiary, style: AppTypography.title),
              const SizedBox(height: 2),
              Text(
                DateHelpers.formatFullDate(_currentDate),
                style: AppTypography.caption,
              ),
              if (_savedTime != null) ...[
                const SizedBox(height: 2),
                Text('已保存 $_savedTime', style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.accent)),
              ],
            ],
          ),
          const Spacer(),
          // 下一天
          _CircleBtn(icon: Icons.chevron_right, onTap: _goToNextDay),
        ],
      ),
    );
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择心情', style: AppTypography.subtitle),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _defaultMoods.map((m) => GestureDetector(
                  onTap: () {
                    setState(() { _mood = m[0]; _moodLabel = m[1]; });
                    _saveCurrent();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _mood == m[0] ? AppColors.accentLight : AppColors.surface,
                      borderRadius: AppRadius.capsule,
                    ),
                    child: Text('${m[0]} ${m[1]}', style: AppTypography.body.copyWith(fontSize: 15)),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeatherPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择天气', style: AppTypography.subtitle),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _defaultWeathers.map((w) => GestureDetector(
                  onTap: () {
                    setState(() { _weather = w[0]; _weatherLabel = w[2]; });
                    _saveCurrent();
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _weather == w[0] ? AppColors.accentLight : AppColors.surface,
                      borderRadius: AppRadius.capsule,
                    ),
                    child: Text('${w[1]} ${w[2]}', style: AppTypography.body.copyWith(fontSize: 15)),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addImage() {
    // TODO: image_picker integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片功能即将接入系统相册')),
    );
  }

  static const _defaultMoods = [
    ['😊', '开心'], ['😌', '平静'], ['😢', '难过'],
    ['😡', '生气'], ['😫', '疲惫'], ['😲', '惊喜'],
    ['😰', '焦虑'], ['🥰', '满足'],
  ];

  static const _defaultWeathers = [
    ['sunny', '☀️', '晴'], ['cloudy', '⛅', '多云'],
    ['overcast', '☁️', '阴天'], ['light_rain', '🌧️', '小雨'],
    ['heavy_rain', '⛈️', '大雨'], ['snow', '❄️', '雪天'],
    ['fog', '🌫️', '雾天'],
  ];
}

/// 单日日记内容
class _DiaryContent extends StatelessWidget {
  final DateTime date;
  final String content;
  final String mood;
  final String moodLabel;
  final String weather;
  final String weatherLabel;
  final List<String> images;
  final String? savedTime;
  final bool isCurrent;
  final TextEditingController? textController;
  final VoidCallback? onTextChanged;
  final VoidCallback? onMoodTap;
  final VoidCallback? onWeatherTap;
  final VoidCallback? onAddImage;
  final ValueChanged<int>? onRemoveImage;

  const _DiaryContent({
    required this.date, required this.content, required this.mood,
    required this.moodLabel, required this.weather, required this.weatherLabel,
    required this.images, this.savedTime, required this.isCurrent,
    this.textController, this.onTextChanged, this.onMoodTap,
    this.onWeatherTap, this.onAddImage, this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 主卡片 (90%宽度, 24px圆角)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.lg,
              boxShadow: const [AppShadows.card],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：日期 + 心情/天气标签
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日',
                      style: AppTypography.subtitle),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onMoodTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tagPink,
                              borderRadius: AppRadius.capsule,
                            ),
                            child: Text('$mood $moodLabel', style: AppTypography.caption.copyWith(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onWeatherTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tagBlue,
                              borderRadius: AppRadius.capsule,
                            ),
                            child: Text(weatherLabel, style: AppTypography.caption.copyWith(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // "今日想说" 标题
                Text('今日想说', style: AppTypography.subtitle.copyWith(fontSize: 16)),
                const SizedBox(height: 12),

                // 编辑区
                if (isCurrent && textController != null)
                  TextField(
                    controller: textController,
                    maxLines: null,
                    minLines: 6,
                    style: AppTypography.body,
                    onChanged: (_) => onTextChanged?.call(),
                    decoration: const InputDecoration(
                      hintText: '今天发生了什么...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  )
                else
                  Text(content.isEmpty ? '空白日记' : content,
                    style: content.isEmpty
                        ? AppTypography.body.copyWith(color: AppColors.textHint)
                        : AppTypography.body,
                  ),

                // 图片区
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: images.asMap().entries.map((e) => Stack(
                      children: [
                        Container(
                          width: (MediaQuery.of(context).size.width - 80) / 3,
                          height: (MediaQuery.of(context).size.width - 80) / 3,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.md,
                          ),
                          child: const Center(child: Icon(Icons.image, color: AppColors.textHint, size: 32)),
                        ),
                        if (isCurrent)
                          Positioned(
                            top: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => onRemoveImage?.call(e.key),
                              child: Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.text.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),

          // 添加图片按钮
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              child: GestureDetector(
                onTap: onAddImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('添加图片', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
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

class _DayData {
  final String content;
  final String mood;
  final String moodLabel;
  final String weather;
  final String weatherLabel;
  final List<String> images;
  _DayData({required this.content, required this.mood, required this.moodLabel,
    required this.weather, required this.weatherLabel, required this.images});
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: const [AppShadows.card],
        ),
        child: Icon(icon, size: 22, color: AppColors.text),
      ),
    );
  }
}
