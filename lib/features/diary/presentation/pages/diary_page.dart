import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';
import '../../../../core/utils/date_helpers.dart';

String _formatDiaryHeaderDate(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日${DateHelpers.weekdayName(date)}';
}

String _formatDiaryCardSubtitle(DateTime date) {
  return '${date.year}年 ${DateHelpers.weekdayName(date)} · ${_LunarCalendar.fullLabelFor(date)}';
}

String _weatherGlyph(String weather, String label) {
  switch (weather) {
    case 'sunny':
      return '☀️';
    case 'cloudy':
      return '⛅';
    case 'overcast':
      return '☁️';
    case 'light_rain':
      return '🌧️';
    case 'heavy_rain':
      return '⛈️';
    case 'snow':
      return '❄️';
    case 'fog':
      return '🌫️';
  }
  return label;
}

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
    _content = _textController.text;
    _cache[_dateKey(_currentDate)] = _DayData(
      content: _content,
      mood: _mood,
      moodLabel: _moodLabel,
      weather: _weather,
      weatherLabel: _weatherLabel,
      images: List.from(_images),
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

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      _content = _textController.text;
      _saveCurrent();
      setState(() {
        _savedTime =
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      });
    });
  }

  void _goToPrevDay() {
    _saveCurrent();
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      _loadDate(_currentDate);
    });
  }

  void _goToNextDay() {
    _saveCurrent();
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      _loadDate(_currentDate);
    });
  }

  void _jumpToDate(DateTime date) {
    _saveCurrent();
    setState(() {
      _currentDate = DateTime(date.year, date.month, date.day);
      _loadDate(_currentDate);
    });
  }

  Future<void> _showCalendarPicker() async {
    final selected = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => _CalendarDialog(selectedDate: _currentDate),
    );
    if (selected != null) {
      _jumpToDate(selected);
    }
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
      onRemoveImage: isCurrent
          ? (int i) {
              setState(() {
                _images.removeAt(i);
              });
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // For now, use a simpler approach - show current day with navigation buttons
    // PageView with 3 pages (prev, current, next) would need more complex state management
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.themeVersion,
      builder: (context, themeVersion, child) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              const Positioned.fill(child: _PaperBackdrop()),
              SafeArea(
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavHeader() {
    return Container(
      height: 138,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
      child: Row(
        children: [
          // 上一天
          _CircleBtn(icon: Icons.chevron_left, onTap: _goToPrevDay),
          const Spacer(),
          // 居中标题
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.navDiary,
                style: AppTypography.title.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w500,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 12),
              _HeaderDateHotspot(
                date: _currentDate,
                onTap: _showCalendarPicker,
              ),
              if (_savedTime != null) ...[
                const SizedBox(height: 4),
                Text(
                  '已保存 $_savedTime',
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    color: AppColors.accent,
                  ),
                ),
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
                spacing: 12,
                runSpacing: 12,
                children: _defaultMoods
                    .map(
                      (m) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _mood = m[0];
                            _moodLabel = m[1];
                          });
                          _saveCurrent();
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _mood == m[0]
                                ? AppColors.accentLight
                                : AppColors.surface,
                            borderRadius: AppRadius.capsule,
                          ),
                          child: Text(
                            '${m[0]} ${m[1]}',
                            style: AppTypography.body.copyWith(fontSize: 15),
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
                spacing: 12,
                runSpacing: 12,
                children: _defaultWeathers
                    .map(
                      (w) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _weather = w[0];
                            _weatherLabel = w[2];
                          });
                          _saveCurrent();
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _weather == w[0]
                                ? AppColors.accentLight
                                : AppColors.surface,
                            borderRadius: AppRadius.capsule,
                          ),
                          child: Text(
                            '${w[1]} ${w[2]}',
                            style: AppTypography.body.copyWith(fontSize: 15),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addImage() {
    // TODO: image_picker integration
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('图片功能即将接入系统相册')));
  }

  static const _defaultMoods = [
    ['😊', '开心'],
    ['😌', '平静'],
    ['😢', '难过'],
    ['😡', '生气'],
    ['😫', '疲惫'],
    ['😲', '惊喜'],
    ['😰', '焦虑'],
    ['🥰', '满足'],
  ];

  static const _defaultWeathers = [
    ['sunny', '☀️', '晴'],
    ['cloudy', '⛅', '多云'],
    ['overcast', '☁️', '阴天'],
    ['light_rain', '🌧️', '小雨'],
    ['heavy_rain', '⛈️', '大雨'],
    ['snow', '❄️', '雪天'],
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
    required this.date,
    required this.content,
    required this.mood,
    required this.moodLabel,
    required this.weather,
    required this.weatherLabel,
    required this.images,
    this.savedTime,
    required this.isCurrent,
    this.textController,
    this.onTextChanged,
    this.onMoodTap,
    this.onWeatherTap,
    this.onAddImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          // 主卡片：日期作为页面内容的第一视觉层级
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：大日期 + 心情/天气
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month} / ${date.day}',
                            style: AppTypography.date42.copyWith(
                              fontSize: 58,
                              fontWeight: FontWeight.w300,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatDiaryCardSubtitle(date),
                            style: AppTypography.caption.copyWith(
                              fontSize: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _IconBubble(
                          label: mood,
                          tooltip: moodLabel,
                          background: AppColors.tagWarm,
                          onTap: onMoodTap,
                        ),
                        const SizedBox(width: 18),
                        _IconBubble(
                          label: _weatherGlyph(weather, weatherLabel),
                          tooltip: weatherLabel,
                          background: AppColors.tagBlue,
                          onTap: onWeatherTap,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 24),

                // "今日想说" 标题
                Row(
                  children: [
                    const _PenSvgIcon(),
                    const SizedBox(width: 9),
                    Text(
                      '今日想说',
                      style: AppTypography.subtitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),

                // 编辑区
                if (isCurrent && textController != null)
                  TextField(
                    controller: textController,
                    maxLines: null,
                    minLines: 7,
                    style: AppTypography.body.copyWith(fontSize: 21),
                    onChanged: (_) => onTextChanged?.call(),
                    decoration: InputDecoration(
                      hintText: '今天发生了什么...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 21,
                      ),
                    ),
                  )
                else
                  Text(
                    content.isEmpty ? '空白日记' : content,
                    style: content.isEmpty
                        ? AppTypography.body.copyWith(
                            color: AppColors.textHint,
                            fontSize: 21,
                          )
                        : AppTypography.body.copyWith(fontSize: 21),
                  ),

                // 图片区
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: images.asMap().entries.map((e) {
                      return Stack(
                        children: [
                          Container(
                            width: (MediaQuery.of(context).size.width - 80) / 3,
                            height:
                                (MediaQuery.of(context).size.width - 80) / 3,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.md,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.textHint,
                                size: 32,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => onRemoveImage?.call(e.key),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.text.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // 添加图片按钮
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 46),
              child: GestureDetector(
                onTap: onAddImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.md,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 28,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '添加图片',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 20,
                        ),
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

class _DayData {
  final String content;
  final String mood;
  final String moodLabel;
  final String weather;
  final String weatherLabel;
  final List<String> images;
  _DayData({
    required this.content,
    required this.mood,
    required this.moodLabel,
    required this.weather,
    required this.weatherLabel,
    required this.images,
  });
}

class _HeaderDateHotspot extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _HeaderDateHotspot({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prefix = DateHelpers.isToday(date) ? '今日 ' : '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          '$prefix${_formatDiaryHeaderDate(date)}',
          style: AppTypography.caption.copyWith(
            fontSize: 21,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PenSvgIcon extends StatelessWidget {
  const _PenSvgIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _PenSvgIconPainter(color: AppColors.textSecondary),
    );
  }
}

class _PenSvgIconPainter extends CustomPainter {
  final Color color;

  const _PenSvgIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 16, size.height / 16);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final body = Path()
      ..moveTo(4.1, 11.9)
      ..lineTo(10.9, 5.1)
      ..lineTo(12.9, 7.1)
      ..lineTo(6.1, 13.9)
      ..lineTo(3.2, 14.8)
      ..lineTo(4.1, 11.9)
      ..close();
    canvas.drawPath(body, paint);
    canvas.drawLine(const Offset(9.8, 4.0), const Offset(12.9, 7.1), paint);
    canvas.drawLine(const Offset(11.2, 2.6), const Offset(13.4, 4.8), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PenSvgIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CalendarDialog extends StatefulWidget {
  final DateTime selectedDate;

  const _CalendarDialog({required this.selectedDate});

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  late DateTime _visibleMonth;
  late int _visibleYear;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _visibleYear = widget.selectedDate.year;
  }

  void _movePrevious() {
    setState(() {
      if (_tabIndex == 0) {
        _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
        _visibleYear = _visibleMonth.year;
      } else {
        _visibleYear = (_visibleYear - 1).clamp(1900, 2100);
        _visibleMonth = DateTime(_visibleYear, _visibleMonth.month);
      }
    });
  }

  void _moveNext() {
    setState(() {
      if (_tabIndex == 0) {
        _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
        _visibleYear = _visibleMonth.year;
      } else {
        _visibleYear = (_visibleYear + 1).clamp(1900, 2100);
        _visibleMonth = DateTime(_visibleYear, _visibleMonth.month);
      }
    });
  }

  void _setYear(int? year) {
    if (year == null) return;
    setState(() {
      _visibleYear = year;
      _visibleMonth = DateTime(year, _visibleMonth.month);
    });
  }

  void _setMonth(int? month) {
    if (month == null) return;
    setState(() {
      _tabIndex = 0;
      _visibleMonth = DateTime(_visibleYear, month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CalendarToolbar(
              tabIndex: _tabIndex,
              year: _visibleYear,
              month: _visibleMonth.month,
              onPrevious: _movePrevious,
              onNext: _moveNext,
              onYearChanged: _setYear,
              onMonthChanged: _setMonth,
            ),
            const SizedBox(height: 12),
            _CalendarTabs(
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeOutQuart,
              child: _tabIndex == 0
                  ? _MonthCalendar(
                      key: ValueKey(
                        'month-${_visibleMonth.year}-${_visibleMonth.month}',
                      ),
                      visibleMonth: _visibleMonth,
                      selectedDate: widget.selectedDate,
                      onDateSelected: (date) => Navigator.of(context).pop(date),
                    )
                  : _YearCalendar(
                      key: ValueKey('year-$_visibleYear'),
                      year: _visibleYear,
                      selectedMonth: _visibleMonth.month,
                      onMonthSelected: (month) {
                        setState(() {
                          _tabIndex = 0;
                          _visibleMonth = DateTime(_visibleYear, month);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarToolbar extends StatelessWidget {
  final int tabIndex;
  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onMonthChanged;

  const _CalendarToolbar({
    required this.tabIndex,
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CalendarIconButton(icon: Icons.chevron_left, onTap: onPrevious),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '快速跳转',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                _CalendarDropdown<int>(
                  value: year,
                  items: List.generate(201, (i) => 1900 + i),
                  labelBuilder: (value) => '$value年',
                  onChanged: onYearChanged,
                ),
                const SizedBox(width: 8),
                _CalendarDropdown<int>(
                  value: month,
                  items: List.generate(12, (i) => i + 1),
                  labelBuilder: (value) => '$value月',
                  onChanged: onMonthChanged,
                ),
              ],
            ),
          ),
        ),
        _CalendarIconButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _CalendarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CalendarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 24, color: AppColors.text),
      ),
    );
  }
}

class _CalendarDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  const _CalendarDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sm,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          borderRadius: AppRadius.md,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.card,
          style: AppTypography.caption.copyWith(
            color: AppColors.text,
            fontSize: 13,
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CalendarTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CalendarTabs({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          _CalendarTab(
            label: '月',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _CalendarTab(
            label: '年',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CalendarTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuart,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.card : Colors.transparent,
            borderRadius: AppRadius.sm,
            boxShadow: selected ? AppShadows.card : null,
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: selected ? AppColors.text : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = firstDay.weekday % 7;
    final totalCells = leadingEmpty + daysInMonth <= 35 ? 35 : 42;

    return Column(
      children: [
        Row(
          children: const ['日', '一', '二', '三', '四', '五', '六'].map((label) {
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final day = index - leadingEmpty + 1;
            if (day < 1 || day > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(visibleMonth.year, visibleMonth.month, day);
            final selected = DateHelpers.isSameDay(date, selectedDate);
            final today = DateHelpers.isToday(date);
            return _DateCell(
              date: date,
              selected: selected,
              today: today,
              onTap: () => onDateSelected(date),
            );
          },
        ),
      ],
    );
  }
}

class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  const _DateCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lunar = _LunarCalendar.labelFor(date);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
        decoration: BoxDecoration(
          color: selected ? AppColors.text : Colors.transparent,
          borderRadius: AppRadius.sm,
          border: today && !selected
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.42))
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: AppTypography.body.copyWith(
                    fontSize: 15,
                    height: 1.15,
                    color: selected ? AppColors.white : AppColors.text,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lunar,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    height: 1.1,
                    color: selected
                        ? AppColors.white.withValues(alpha: 0.78)
                        : AppColors.textSecondary,
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

class _YearCalendar extends StatelessWidget {
  final int year;
  final int selectedMonth;
  final ValueChanged<int> onMonthSelected;

  const _YearCalendar({
    super.key,
    required this.year,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.28,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;
        final firstDay = DateTime(year, month);
        final selected = month == selectedMonth;
        return GestureDetector(
          onTap: () => onMonthSelected(month),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuart,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? AppColors.text : AppColors.surface,
              borderRadius: AppRadius.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$month月',
                  style: AppTypography.body.copyWith(
                    fontSize: 16,
                    height: 1.2,
                    color: selected ? AppColors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '首日 ${DateHelpers.weekdayName(firstDay)}',
                  style: AppTypography.caption.copyWith(
                    fontSize: 12,
                    color: selected
                        ? AppColors.white.withValues(alpha: 0.78)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LunarCalendar {
  _LunarCalendar._();

  static final DateTime _baseDate = DateTime(1900, 1, 31);

  static const List<int> _lunarInfo = [
    0x04bd8,
    0x04ae0,
    0x0a570,
    0x054d5,
    0x0d260,
    0x0d950,
    0x16554,
    0x056a0,
    0x09ad0,
    0x055d2,
    0x04ae0,
    0x0a5b6,
    0x0a4d0,
    0x0d250,
    0x1d255,
    0x0b540,
    0x0d6a0,
    0x0ada2,
    0x095b0,
    0x14977,
    0x04970,
    0x0a4b0,
    0x0b4b5,
    0x06a50,
    0x06d40,
    0x1ab54,
    0x02b60,
    0x09570,
    0x052f2,
    0x04970,
    0x06566,
    0x0d4a0,
    0x0ea50,
    0x06e95,
    0x05ad0,
    0x02b60,
    0x186e3,
    0x092e0,
    0x1c8d7,
    0x0c950,
    0x0d4a0,
    0x1d8a6,
    0x0b550,
    0x056a0,
    0x1a5b4,
    0x025d0,
    0x092d0,
    0x0d2b2,
    0x0a950,
    0x0b557,
    0x06ca0,
    0x0b550,
    0x15355,
    0x04da0,
    0x0a5b0,
    0x14573,
    0x052b0,
    0x0a9a8,
    0x0e950,
    0x06aa0,
    0x0aea6,
    0x0ab50,
    0x04b60,
    0x0aae4,
    0x0a570,
    0x05260,
    0x0f263,
    0x0d950,
    0x05b57,
    0x056a0,
    0x096d0,
    0x04dd5,
    0x04ad0,
    0x0a4d0,
    0x0d4d4,
    0x0d250,
    0x0d558,
    0x0b540,
    0x0b5a0,
    0x195a6,
    0x095b0,
    0x049b0,
    0x0a974,
    0x0a4b0,
    0x0b27a,
    0x06a50,
    0x06d40,
    0x0af46,
    0x0ab60,
    0x09570,
    0x04af5,
    0x04970,
    0x064b0,
    0x074a3,
    0x0ea50,
    0x06b58,
    0x055c0,
    0x0ab60,
    0x096d5,
    0x092e0,
    0x0c960,
    0x0d954,
    0x0d4a0,
    0x0da50,
    0x07552,
    0x056a0,
    0x0abb7,
    0x025d0,
    0x092d0,
    0x0cab5,
    0x0a950,
    0x0b4a0,
    0x0baa4,
    0x0ad50,
    0x055d9,
    0x04ba0,
    0x0a5b0,
    0x15176,
    0x052b0,
    0x0a930,
    0x07954,
    0x06aa0,
    0x0ad50,
    0x05b52,
    0x04b60,
    0x0a6e6,
    0x0a4e0,
    0x0d260,
    0x0ea65,
    0x0d530,
    0x05aa0,
    0x076a3,
    0x096d0,
    0x04afb,
    0x04ad0,
    0x0a4d0,
    0x1d0b6,
    0x0d250,
    0x0d520,
    0x0dd45,
    0x0b5a0,
    0x056d0,
    0x055b2,
    0x049b0,
    0x0a577,
    0x0a4b0,
    0x0aa50,
    0x1b255,
    0x06d20,
    0x0ada0,
    0x14b63,
    0x09370,
    0x049f8,
    0x04970,
    0x064b0,
    0x168a6,
    0x0ea50,
    0x06aa0,
    0x1a6c4,
    0x0aae0,
    0x092e0,
    0x0d2e3,
    0x0c960,
    0x0d557,
    0x0d4a0,
    0x0da50,
    0x05d55,
    0x056a0,
    0x0a6d0,
    0x055d4,
    0x052d0,
    0x0a9b8,
    0x0a950,
    0x0b4a0,
    0x0b6a6,
    0x0ad50,
    0x055a0,
    0x0aba4,
    0x0a5b0,
    0x052b0,
    0x0b273,
    0x06930,
    0x07337,
    0x06aa0,
    0x0ad50,
    0x14b55,
    0x04b60,
    0x0a570,
    0x054e4,
    0x0d160,
    0x0e968,
    0x0d520,
    0x0daa0,
    0x16aa6,
    0x056d0,
    0x04ae0,
    0x0a9d4,
    0x0a2d0,
    0x0d150,
    0x0f252,
    0x0d520,
  ];

  static const _monthLabels = [
    '正月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '冬月',
    '腊月',
  ];

  static const _dayLabels = [
    '初一',
    '初二',
    '初三',
    '初四',
    '初五',
    '初六',
    '初七',
    '初八',
    '初九',
    '初十',
    '十一',
    '十二',
    '十三',
    '十四',
    '十五',
    '十六',
    '十七',
    '十八',
    '十九',
    '二十',
    '廿一',
    '廿二',
    '廿三',
    '廿四',
    '廿五',
    '廿六',
    '廿七',
    '廿八',
    '廿九',
    '三十',
  ];

  static String labelFor(DateTime date) {
    final lunar = _resolve(date);
    if (lunar == null) return '';
    return _dayLabels[lunar.day - 1];
  }

  static String fullLabelFor(DateTime date) {
    final lunar = _resolve(date);
    if (lunar == null) return '';
    final month = '${lunar.isLeap ? '闰' : ''}${_monthLabels[lunar.month - 1]}';
    return '农历$month${_dayLabels[lunar.day - 1]}';
  }

  static _LunarDate? _resolve(DateTime date) {
    if (date.isBefore(_baseDate) || date.year > 2100) {
      return null;
    }

    var offset = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(_baseDate).inDays;
    var lunarYear = 1900;

    while (lunarYear <= 2100) {
      final days = _yearDays(lunarYear);
      if (offset < days) break;
      offset -= days;
      lunarYear++;
    }

    final leap = _leapMonth(lunarYear);
    var isLeap = false;
    var lunarMonth = 1;
    var daysOfMonth = 0;

    while (lunarMonth <= 12) {
      if (leap > 0 && lunarMonth == leap + 1 && !isLeap) {
        lunarMonth--;
        isLeap = true;
        daysOfMonth = _leapDays(lunarYear);
      } else {
        daysOfMonth = _monthDays(lunarYear, lunarMonth);
      }

      if (offset < daysOfMonth) break;
      offset -= daysOfMonth;

      if (isLeap && lunarMonth == leap) {
        isLeap = false;
      }
      lunarMonth++;
    }

    final lunarDay = offset + 1;
    return _LunarDate(month: lunarMonth, day: lunarDay, isLeap: isLeap);
  }

  static int _yearDays(int year) {
    var sum = 348;
    var mask = 0x8000;
    final info = _lunarInfo[year - 1900];
    while (mask > 0x8) {
      if ((info & mask) != 0) sum++;
      mask >>= 1;
    }
    return sum + _leapDays(year);
  }

  static int _leapMonth(int year) => _lunarInfo[year - 1900] & 0xf;

  static int _leapDays(int year) {
    if (_leapMonth(year) == 0) return 0;
    return (_lunarInfo[year - 1900] & 0x10000) != 0 ? 30 : 29;
  }

  static int _monthDays(int year, int month) {
    return (_lunarInfo[year - 1900] & (0x10000 >> month)) != 0 ? 30 : 29;
  }
}

class _LunarDate {
  final int month;
  final int day;
  final bool isLeap;

  const _LunarDate({
    required this.month,
    required this.day,
    required this.isLeap,
  });
}

class _IconBubble extends StatelessWidget {
  final String label;
  final String tooltip;
  final Color background;
  final VoidCallback? onTap;

  const _IconBubble({
    required this.label,
    required this.tooltip,
    required this.background,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: background.withValues(alpha: 0.72),
            shape: BoxShape.circle,
            boxShadow: AppShadows.card,
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
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
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 38, color: AppColors.text),
      ),
    );
  }
}

class _PaperBackdrop extends StatelessWidget {
  const _PaperBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PaperBackdropPainter(color: AppColors.divider),
      child: const SizedBox.expand(),
    );
  }
}

class _PaperBackdropPainter extends CustomPainter {
  final Color color;

  const _PaperBackdropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    const step = 16.0;

    for (double y = 6; y < size.height; y += step) {
      for (double x = 6; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.65, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PaperBackdropPainter oldDelegate) =>
      oldDelegate.color != color;
}
