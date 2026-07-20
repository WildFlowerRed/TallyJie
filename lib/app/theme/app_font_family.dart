import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFontOption {
  final String key;
  final String label;
  final String description;
  final String sample;
  final String? family;

  const AppFontOption({
    required this.key,
    required this.label,
    required this.description,
    required this.sample,
    required this.family,
  });
}

class AppFontFamily {
  AppFontFamily._();

  static const String _storageKey = 'tallyjie_font_family';

  static const List<AppFontOption> options = [
    AppFontOption(
      key: 'system',
      label: '系统默认',
      description: '跟随手机系统，稳定清晰',
      sample: '记录生活',
      family: null,
    ),
    AppFontOption(
      key: 'noto_sans_sc',
      label: '思源黑体',
      description: '现代、干净，适合长文本阅读',
      sample: '今天想说',
      family: 'TallyJieNotoSansSC',
    ),
    AppFontOption(
      key: 'ma_shan_zheng',
      label: '马善政手写',
      description: '柔和手写感，适合日记手账',
      sample: '慢慢生活',
      family: 'TallyJieMaShanZheng',
    ),
    AppFontOption(
      key: 'zcool_xiaowei',
      label: '站酷小薇',
      description: '复古文艺，适合标题和记录氛围',
      sample: '生活账本',
      family: 'TallyJieZcoolXiaoWei',
    ),
  ];

  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static String currentKey = options.first.key;

  static AppFontOption get currentOption => optionByKey(currentKey);

  static String? get currentFamily => currentOption.family;

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved == null) return;
    apply(saved, persist: false);
  }

  static void apply(String key, {bool persist = true}) {
    final option = optionByKey(key);
    currentKey = option.key;
    version.value++;
    if (persist) {
      unawaited(_save(currentKey));
    }
  }

  static AppFontOption optionByKey(String key) {
    return options.firstWhere(
      (option) => option.key == key,
      orElse: () => options.first,
    );
  }

  static Future<void> _save(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, key);
  }
}
