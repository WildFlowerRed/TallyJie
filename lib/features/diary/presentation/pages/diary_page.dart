import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/constants.dart';
import '../../../../core/services/local_data_api.dart';
import '../../../../core/utils/date_helpers.dart';

String _formatDiaryHeaderDate(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日${DateHelpers.weekdayName(date)}';
}

String _formatDiaryCardYearWeekday(DateTime date) {
  return '${date.year}年 ${DateHelpers.weekdayName(date)}';
}

String _formatDiaryCardLunar(DateTime date) =>
    _LunarCalendar.fullLabelFor(date);

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
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _mood = '😊';
  String _moodLabel = '开心';
  String _weather = 'sunny';
  String _weatherLabel = '晴';
  List<String> _images = [];
  String? _draftLocationName;
  List<DiaryEntryDto> _entries = [];
  Set<String> _entryDateKeys = {};
  bool _loadingDiary = true;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadDiaryState();
    LocalDataApi.instance.diaryVersion.addListener(_handleDiaryChanged);
  }

  @override
  void dispose() {
    LocalDataApi.instance.diaryVersion.removeListener(_handleDiaryChanged);
    _textController.dispose();
    super.dispose();
  }

  void _handleDiaryChanged() => _loadDiaryState(keepDraftForToday: true);

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool get _isTodaySelected => DateHelpers.isToday(_currentDate);

  Future<void> _loadDiaryState({bool keepDraftForToday = false}) async {
    final dates = await LocalDataApi.instance.listDiaryEntryDates();
    final entries = await LocalDataApi.instance.listDiaryEntries(_currentDate);
    final latestEntry = entries.isEmpty ? null : entries.first;
    if (!mounted) return;
    setState(() {
      _entryDateKeys = dates.map(_dateKey).toSet();
      _entries = entries;
      _loadingDiary = false;
      _mood = latestEntry?.moodIcon ?? '😊';
      _moodLabel = latestEntry?.moodLabel ?? '开心';
      _weather = latestEntry?.weatherKey ?? 'sunny';
      _weatherLabel = latestEntry?.weatherLabel ?? '晴';
      if (!_isTodaySelected || !keepDraftForToday) {
        _textController.clear();
        _images = [];
        _draftLocationName = null;
      }
    });
  }

  Future<void> _loadDate(DateTime date) async {
    setState(() {
      _currentDate = DateTime(date.year, date.month, date.day);
      _loadingDiary = true;
      _draftLocationName = null;
    });
    await _loadDiaryState();
  }

  List<DateTime> get _navigableDates {
    final dates = _entryDateKeys
        .map(DateTime.parse)
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (!dates.any((date) => DateHelpers.isSameDay(date, todayOnly))) {
      dates.add(todayOnly);
    }
    dates.sort();
    return dates;
  }

  void _goToPrevDay() {
    DateTime? previous;
    for (final date in _navigableDates) {
      if (date.isBefore(_currentDate)) previous = date;
    }
    if (previous == null) return;
    _loadDate(previous);
  }

  void _goToNextDay() {
    if (_isTodaySelected) {
      _showTodayBoundaryWarning();
      return;
    }
    DateTime? next;
    for (final date in _navigableDates) {
      if (date.isAfter(_currentDate)) {
        next = date;
        break;
      }
    }
    if (next == null) {
      _showTodayBoundaryWarning();
      return;
    }
    _loadDate(next);
  }

  Future<void> _showTodayBoundaryWarning() {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.navSelected,
                size: 34,
              ),
              const SizedBox(height: 14),
              Text(
                '已经是今日日记',
                style: AppTypography.subtitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                '明天的故事，等明天再写。',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                style: AppTheme.primaryFilledButtonStyle,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('我知道了', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _jumpToDate(DateTime date) {
    _loadDate(date);
  }

  Future<void> _showCalendarPicker() async {
    final selected = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => _CalendarDialog(
        selectedDate: _currentDate,
        diaryDateKeys: _entryDateKeys,
      ),
    );
    if (selected != null) {
      _jumpToDate(selected);
    }
  }

  Future<void> _saveTodayDiary() async {
    final draftText = _textController.text.trim();
    if (draftText.isEmpty && _images.isEmpty && _draftLocationName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('先写一点今天的内容吧')));
      return;
    }
    final entry = await LocalDataApi.instance.saveDiaryEntry(
      SaveDiaryEntryInput(
        entryDate: _currentDate,
        content: draftText,
        moodKey: _moodLabel,
        moodLabel: _moodLabel,
        moodIcon: _mood,
        weatherKey: _weather,
        weatherLabel: _weatherLabel,
        weatherIcon: _weatherGlyph(_weather, _weatherLabel),
        lunarDate: _LunarCalendar.fullLabelFor(_currentDate),
        locationName: _draftLocationName,
        images: _images,
      ),
    );
    if (!mounted) return;
    setState(() {
      _entries = [entry, ..._entries];
      _entryDateKeys = {..._entryDateKeys, _dateKey(_currentDate)};
      _textController.clear();
      _images = [];
      _draftLocationName = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('日记已保存')));
  }

  Future<DiaryEntryDto?> _openEditDiaryDialog(DiaryEntryDto entry) async {
    final controller = TextEditingController(text: entry.content);
    final draftImages = List<String>.of(entry.images);
    final locationController = TextEditingController(
      text: entry.locationName ?? '',
    );
    final updated = await showDialog<_DiaryEditResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 540),
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '编辑日记',
                      style: AppTypography.subtitle.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller,
                      maxLines: null,
                      minLines: 6,
                      style: AppTypography.body.copyWith(fontSize: 26),
                      decoration: InputDecoration(
                        hintText: '今天发生了什么...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ImagePreviewWrap(
                      images: draftImages,
                      editable: true,
                      onRemove: (index) =>
                          setDialogState(() => draftImages.removeAt(index)),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: locationController,
                      style: AppTypography.body.copyWith(fontSize: 23),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.place_outlined,
                          color: AppColors.navSelected,
                          size: 30,
                        ),
                        hintText: '添加更详细的位置',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onPressed: () async {
                            final image = await _pickOneImage();
                            if (image == null) return;
                            setDialogState(() => draftImages.add(image));
                          },
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 28,
                          ),
                          label: const Text(
                            '添加图片',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            '取消',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        FilledButton.icon(
                          style: AppTheme.primaryFilledButtonStyle.copyWith(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(
                            _DiaryEditResult(
                              content: controller.text,
                              images: draftImages,
                              locationName: locationController.text,
                            ),
                          ),
                          icon: const Icon(Icons.save_outlined, size: 28),
                          label: const Text(
                            '保存',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
    locationController.dispose();
    if (updated == null) return null;
    final saved = await LocalDataApi.instance.saveDiaryEntry(
      SaveDiaryEntryInput(
        id: entry.id,
        entryDate: entry.entryDate,
        content: updated.content,
        moodKey: entry.moodKey,
        moodLabel: entry.moodLabel,
        moodIcon: entry.moodIcon,
        weatherKey: entry.weatherKey,
        weatherLabel: entry.weatherLabel,
        weatherIcon: entry.weatherIcon,
        lunarDate: entry.lunarDate,
        locationName: updated.locationName,
        images: updated.images,
      ),
    );
    if (!mounted) return null;
    setState(() {
      _entries = _entries
          .map((entry) => entry.id == saved.id ? saved : entry)
          .toList();
      if (DateHelpers.isSameDay(saved.entryDate, _currentDate) &&
          _isTodaySelected) {
        _textController.text = saved.content;
        _images = List.of(saved.images);
      }
    });
    return saved;
  }

  Future<bool> _confirmDeleteDiary(DiaryEntryDto entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          '删除这篇日记？',
          style: AppTypography.subtitle.copyWith(fontSize: 32),
        ),
        content: Text(
          '删除后这一天的文本和图片记录都会移除。',
          style: AppTypography.body.copyWith(fontSize: 24),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消', style: TextStyle(fontSize: 22)),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.expense,
              size: 30,
            ),
            label: Text(
              '删除',
              style: TextStyle(color: AppColors.expense, fontSize: 22),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    await LocalDataApi.instance.deleteDiaryEntryById(entry.id);
    if (!mounted) return true;
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
      _entryDateKeys = {..._entryDateKeys};
      if (_entries.isEmpty) {
        _entryDateKeys.remove(_dateKey(entry.entryDate));
      }
      if (_isTodaySelected) {
        _textController.clear();
        _images = [];
      }
    });
    return true;
  }

  Future<void> _openDiaryDetail(DiaryEntryDto entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _DiaryDetailPage(
          entry: entry,
          onEdit: _openEditDiaryDialog,
          onDelete: _confirmDeleteDiary,
        ),
      ),
    );
  }

  // Placeholder builders for the 3 pages in PageView
  Widget _buildDayPage(DateTime date) {
    final isToday = DateHelpers.isToday(date);

    return _DiaryContent(
      date: date,
      entries: _entries,
      loading: _loadingDiary,
      draftImages: _images,
      draftLocationName: _draftLocationName,
      mood: _mood,
      moodLabel: _moodLabel,
      weather: _weather,
      weatherLabel: _weatherLabel,
      isToday: isToday,
      textController: isToday ? _textController : null,
      onMoodTap: _showMoodPicker,
      onWeatherTap: _showWeatherPicker,
      onAddImage: isToday ? _addImage : null,
      onLocationTap: isToday ? _openLocationEditor : null,
      onSave: isToday ? _saveTodayDiary : null,
      onOpenEntry: _openDiaryDetail,
      onRemoveImage: isToday
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
          resizeToAvoidBottomInset: false,
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
          const SizedBox(width: 8),
          // 居中标题
          Expanded(
            child: Column(
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
              ],
            ),
          ),
          const SizedBox(width: 8),
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

  Future<String?> _pickOneImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<void> _addImage() async {
    final image = await _pickOneImage();
    if (image == null || !mounted) return;
    setState(() => _images.add(image));
  }

  Future<void> _openLocationEditor() async {
    final controller = TextEditingController(text: _draftLocationName ?? '');
    var locating = false;
    final value = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: AppColors.card,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '记录位置',
                  style: AppTypography.subtitle.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: controller,
                  style: AppTypography.body.copyWith(fontSize: 24),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.place_outlined,
                      color: AppColors.navSelected,
                      size: 30,
                    ),
                    hintText: '国家 / 城市 / 区县 / 街道',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          foregroundColor: AppColors.navSelected,
                          side: BorderSide(color: AppColors.divider),
                        ),
                        onPressed: locating
                            ? null
                            : () async {
                                setDialogState(() => locating = true);
                                final location =
                                    await _resolveCurrentLocation();
                                setDialogState(() {
                                  locating = false;
                                  if (location != null) {
                                    controller.text = location;
                                  }
                                });
                              },
                        icon: Icon(
                          locating
                              ? Icons.hourglass_empty_rounded
                              : Icons.my_location_outlined,
                          size: 28,
                        ),
                        label: Text(
                          locating ? '定位中' : '获取定位',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    FilledButton.icon(
                      style: AppTheme.primaryFilledButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text.trim()),
                      icon: const Icon(Icons.check_rounded, size: 28),
                      label: const Text('确定', style: TextStyle(fontSize: 22)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    setState(() => _draftLocationName = value.isEmpty ? null : value);
  }

  Future<String?> _resolveCurrentLocation() async {
    try {
      var permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
      }
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('定位权限未开启')));
        }
        return null;
      }

      final position = await geolocator.Geolocator.getCurrentPosition(
        locationSettings: const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
        ),
      );
      final placemarks = await geocoding.Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      }
      final mark = placemarks.first;
      final parts = <String?>[
        mark.country,
        mark.administrativeArea,
        mark.locality,
        mark.subLocality,
      ];
      return parts
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' · ');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('定位失败，请手动填写位置')));
      }
      return null;
    }
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
  final List<DiaryEntryDto> entries;
  final bool loading;
  final List<String> draftImages;
  final String? draftLocationName;
  final String mood;
  final String moodLabel;
  final String weather;
  final String weatherLabel;
  final bool isToday;
  final TextEditingController? textController;
  final VoidCallback? onMoodTap;
  final VoidCallback? onWeatherTap;
  final VoidCallback? onAddImage;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSave;
  final ValueChanged<DiaryEntryDto>? onOpenEntry;
  final ValueChanged<int>? onRemoveImage;

  const _DiaryContent({
    required this.date,
    required this.entries,
    required this.loading,
    required this.draftImages,
    this.draftLocationName,
    required this.mood,
    required this.moodLabel,
    required this.weather,
    required this.weatherLabel,
    required this.isToday,
    this.textController,
    this.onMoodTap,
    this.onWeatherTap,
    this.onAddImage,
    this.onLocationTap,
    this.onSave,
    this.onOpenEntry,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final latestEntry = entries.isEmpty ? null : entries.first;
    final shownMood = isToday ? mood : latestEntry?.moodIcon ?? mood;
    final shownMoodLabel = isToday
        ? moodLabel
        : latestEntry?.moodLabel ?? moodLabel;
    final shownWeather = isToday ? weather : latestEntry?.weatherKey ?? weather;
    final shownWeatherLabel = isToday
        ? weatherLabel
        : latestEntry?.weatherLabel ?? weatherLabel;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        bottomInset > 0 ? bottomInset + 24 : 46,
      ),
      child: Column(
        children: [
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            _formatDiaryCardYearWeekday(date),
                            style: AppTypography.caption.copyWith(
                              fontSize: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatDiaryCardLunar(date),
                            style: AppTypography.caption.copyWith(
                              fontSize: 17,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.82,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _IconBubble(
                          label: shownMood,
                          tooltip: shownMoodLabel,
                          background: AppColors.tagWarm,
                          onTap: onMoodTap,
                        ),
                        const SizedBox(width: 18),
                        _IconBubble(
                          label: _weatherGlyph(shownWeather, shownWeatherLabel),
                          tooltip: shownWeatherLabel,
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

                if (loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 52),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.navSelected,
                      ),
                    ),
                  )
                else if (isToday)
                  _TodayDiaryComposer(
                    controller: textController!,
                    images: draftImages,
                    locationName: draftLocationName,
                    onAddImage: onAddImage,
                    onLocationTap: onLocationTap,
                    onSave: onSave,
                    onRemoveImage: onRemoveImage,
                  )
                else
                  _HistoryDiaryBody(entries: entries, onOpen: onOpenEntry),
              ],
            ),
          ),
          if (!loading && isToday && entries.isNotEmpty) ...[
            const SizedBox(height: 18),
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SavedDiaryCard(
                  entry: entry,
                  onOpen: () => onOpenEntry?.call(entry),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayDiaryComposer extends StatelessWidget {
  final TextEditingController controller;
  final List<String> images;
  final String? locationName;
  final VoidCallback? onAddImage;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSave;
  final ValueChanged<int>? onRemoveImage;

  const _TodayDiaryComposer({
    required this.controller,
    required this.images,
    this.locationName,
    this.onAddImage,
    this.onLocationTap,
    this.onSave,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _PenSvgIcon(),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                '今日想说',
                style: AppTypography.subtitle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _LocationIconButton(onTap: onLocationTap),
          ],
        ),
        const SizedBox(height: 34),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 7,
          style: AppTypography.body.copyWith(fontSize: 21),
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
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 21),
          ),
        ),
        _ImagePreviewWrap(
          images: images,
          editable: true,
          onRemove: onRemoveImage,
        ),
        if (locationName != null && locationName!.isNotEmpty) ...[
          const SizedBox(height: 18),
          _LocationRow(locationName: locationName!),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _DiaryActionPill(
                label: '添加图片',
                icon: Icons.photo_library_outlined,
                foreground: AppColors.textSecondary,
                background: AppColors.card,
                borderColor: AppColors.divider,
                onTap: onAddImage,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _DiaryActionPill(
                label: '保存',
                icon: Icons.save_outlined,
                foreground: AppColors.white,
                background: AppColors.navSelected,
                borderColor: Colors.transparent,
                onTap: onSave,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HistoryDiaryBody extends StatelessWidget {
  final List<DiaryEntryDto> entries;
  final ValueChanged<DiaryEntryDto>? onOpen;

  const _HistoryDiaryBody({required this.entries, this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 46),
        child: Center(
          child: Text(
            '这一天还没有日记',
            style: AppTypography.body.copyWith(
              color: AppColors.textHint,
              fontSize: 21,
            ),
          ),
        ),
      );
    }

    return Column(
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SavedDiaryCard(
                entry: entry,
                onOpen: () => onOpen?.call(entry),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SavedDiaryCard extends StatelessWidget {
  final DiaryEntryDto entry;
  final VoidCallback? onOpen;

  const _SavedDiaryCard({required this.entry, this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DiaryBodyText(entry.content),
            _ImagePreviewWrap(images: entry.images),
            if ((entry.locationName ?? '').isNotEmpty) ...[
              const SizedBox(height: 18),
              _LocationRow(locationName: entry.locationName!),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiaryDetailPage extends StatefulWidget {
  final DiaryEntryDto entry;
  final Future<DiaryEntryDto?> Function(DiaryEntryDto entry) onEdit;
  final Future<bool> Function(DiaryEntryDto entry) onDelete;

  const _DiaryDetailPage({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<_DiaryDetailPage> {
  late DiaryEntryDto _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _edit() async {
    final saved = await widget.onEdit(_entry);
    if (saved == null || !mounted) return;
    setState(() => _entry = saved);
  }

  Future<void> _delete() async {
    final deleted = await widget.onDelete(_entry);
    if (deleted && mounted) Navigator.of(context).pop();
  }

  void _openImageViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            _ImageViewerPage(images: _entry.images, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                      child: Row(
                        children: [
                          _PlainIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            color: AppColors.text,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Text(
                            '日记详情',
                            style: AppTypography.title.copyWith(fontSize: 34),
                          ),
                          const Spacer(),
                          _PlainIconButton(
                            icon: Icons.edit_outlined,
                            color: AppColors.navSelected,
                            onTap: _edit,
                          ),
                          const SizedBox(width: 18),
                          _PlainIconButton(
                            icon: Icons.delete_outline,
                            color: AppColors.expense,
                            onTap: _delete,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 46),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
                          decoration: BoxDecoration(
                            color: AppColors.card.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_entry.entryDate.month} / ${_entry.entryDate.day}',
                                          style: AppTypography.date42.copyWith(
                                            fontSize: 58,
                                            fontWeight: FontWeight.w300,
                                            height: 1.05,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _formatDiaryCardYearWeekday(
                                            _entry.entryDate,
                                          ),
                                          style: AppTypography.caption.copyWith(
                                            fontSize: 20,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _formatDiaryCardLunar(
                                            _entry.entryDate,
                                          ),
                                          style: AppTypography.caption.copyWith(
                                            fontSize: 17,
                                            color: AppColors.textSecondary
                                                .withValues(alpha: 0.82),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _IconBubble(
                                    label: _entry.moodIcon,
                                    tooltip: _entry.moodLabel,
                                    background: AppColors.tagWarm,
                                  ),
                                  const SizedBox(width: 18),
                                  _IconBubble(
                                    label: _weatherGlyph(
                                      _entry.weatherKey,
                                      _entry.weatherLabel,
                                    ),
                                    tooltip: _entry.weatherLabel,
                                    background: AppColors.tagBlue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const Divider(height: 1),
                              const SizedBox(height: 24),
                              _DiaryBodyText(_entry.content),
                              _ImagePreviewWrap(
                                images: _entry.images,
                                onImageTap: _openImageViewer,
                              ),
                              if ((_entry.locationName ?? '').isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _LocationRow(
                                  locationName: _entry.locationName!,
                                ),
                              ],
                            ],
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
      },
    );
  }
}

class _PlainIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PlainIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(icon, color: color, size: 34),
      ),
    );
  }
}

class _ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageViewerPage({required this.images, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(
                    child: _DiaryImagePreview(
                      path: widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
            Positioned(
              bottom: 22,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.38),
                    borderRadius: AppRadius.capsule,
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.images.length}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
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

class _LocationIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _LocationIconButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '添加定位',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.navSelected.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.my_location_outlined,
            color: AppColors.navSelected,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String locationName;

  const _LocationRow({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.place_outlined, color: AppColors.navSelected, size: 26),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatLocationLabel(locationName),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 18,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatLocationLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.contains(',')) return trimmed;
  return trimmed
      .split(RegExp(r'[\s·]+'))
      .where((part) => part.trim().isNotEmpty)
      .join(' · ');
}

class _DiaryActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final VoidCallback? onTap;

  const _DiaryActionPill({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.md,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: foreground),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: foreground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryBodyText extends StatelessWidget {
  final String content;

  const _DiaryBodyText(this.content);

  @override
  Widget build(BuildContext context) {
    final empty = content.trim().isEmpty;
    return Text(
      empty ? '这一天只留下了图片。' : content,
      style: AppTypography.body.copyWith(
        color: empty ? AppColors.textHint : AppColors.text,
        fontSize: 21,
        height: 1.72,
      ),
    );
  }
}

class _ImagePreviewWrap extends StatefulWidget {
  final List<String> images;
  final bool editable;
  final ValueChanged<int>? onRemove;
  final ValueChanged<int>? onImageTap;

  const _ImagePreviewWrap({
    required this.images,
    this.editable = false,
    this.onRemove,
    this.onImageTap,
  });

  @override
  State<_ImagePreviewWrap> createState() => _ImagePreviewWrapState();
}

class _ImagePreviewWrapState extends State<_ImagePreviewWrap> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant _ImagePreviewWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.length < 2 ||
        widget.images.length != oldWidget.images.length) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final canFold = widget.images.length >= 2;
    final shouldFold = canFold && !_expanded;
    if (shouldFold) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: _buildFoldedImageStack(context),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.images
                .asMap()
                .entries
                .map(_buildImageTile)
                .toList(),
          ),
          if (canFold) ...[
            const SizedBox(height: 12),
            _CompactStackToggle(
              label: '收起',
              icon: Icons.unfold_less_rounded,
              onTap: () => setState(() => _expanded = false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageTile(MapEntry<int, String> e) {
    final tileSize = _tileSize(context);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.md,
          child: GestureDetector(
            onTap: () => widget.onImageTap?.call(e.key),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: tileSize,
              height: tileSize,
              color: AppColors.surface,
              child: _DiaryImagePreview(path: e.value),
            ),
          ),
        ),
        if (widget.editable)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onRemove?.call(e.key),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 21, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFoldedImageStack(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTileSize = _tileSize(context).clamp(82.0, 180.0).toDouble();
        final availableTileSize = constraints.maxWidth.isFinite
            ? constraints.maxWidth - 92
            : maxTileSize;
        final tileSize = availableTileSize.clamp(82.0, maxTileSize).toDouble();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: tileSize + 46,
              height: tileSize + 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (widget.images.length > 2)
                    _StackedImageCard(
                      path: widget.images[2],
                      size: tileSize,
                      left: 32,
                      top: 0,
                      opacity: 0.42,
                      rotation: 0.06,
                      onTap: () => widget.onImageTap?.call(2),
                    ),
                  _StackedImageCard(
                    path: widget.images[1],
                    size: tileSize,
                    left: 16,
                    top: 13,
                    opacity: 0.68,
                    rotation: -0.035,
                    onTap: () => widget.onImageTap?.call(1),
                  ),
                  _StackedImageCard(
                    path: widget.images[0],
                    size: tileSize,
                    left: 0,
                    top: 26,
                    opacity: 1,
                    rotation: 0,
                    onTap: () => widget.onImageTap?.call(0),
                  ),
                  Positioned(
                    left: 12,
                    top: 38,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.52),
                        borderRadius: AppRadius.capsule,
                      ),
                      child: Text(
                        '${widget.images.length} 张',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CompactStackToggle(
              label: '展开 ${widget.images.length}',
              icon: Icons.unfold_more_rounded,
              onTap: () => setState(() => _expanded = true),
            ),
          ],
        );
      },
    );
  }

  double _tileSize(BuildContext context) {
    return (MediaQuery.of(context).size.width - 96) / 3;
  }
}

class _CompactStackToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CompactStackToggle({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.navSelected.withValues(alpha: 0.1),
          borderRadius: AppRadius.capsule,
          border: Border.all(
            color: AppColors.navSelected.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.navSelected, size: 22),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.navSelected,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StackedImageCard extends StatelessWidget {
  final String path;
  final double size;
  final double left;
  final double top;
  final double opacity;
  final double rotation;
  final VoidCallback? onTap;

  const _StackedImageCard({
    required this.path,
    required this.size,
    required this.left,
    required this.top,
    required this.opacity,
    required this.rotation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
                boxShadow: AppShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: _DiaryImagePreview(path: path),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiaryImagePreview extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const _DiaryImagePreview({required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }
    return FutureBuilder(
      future: XFile(path).readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return _imageFallback();
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _imageFallback(),
        );
      },
    );
  }

  Widget _imageFallback() {
    return Center(
      child: Icon(Icons.image_outlined, color: AppColors.textHint, size: 34),
    );
  }
}

class _DiaryEditResult {
  final String content;
  final List<String> images;
  final String? locationName;

  const _DiaryEditResult({
    required this.content,
    required this.images,
    this.locationName,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
  final Set<String> diaryDateKeys;

  const _CalendarDialog({
    required this.selectedDate,
    required this.diaryDateKeys,
  });

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
                      diaryDateKeys: widget.diaryDateKeys,
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
  final Set<String> diaryDateKeys;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.diaryDateKeys,
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
              hasDiary: diaryDateKeys.contains(
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              ),
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
  final bool hasDiary;
  final VoidCallback onTap;

  const _DateCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.hasDiary,
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
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: hasDiary
                        ? (selected ? AppColors.white : AppColors.navSelected)
                        : Colors.transparent,
                    shape: BoxShape.circle,
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
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: background.withValues(alpha: 0.72),
            shape: BoxShape.circle,
            boxShadow: AppShadows.card,
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(fontSize: 28)),
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
