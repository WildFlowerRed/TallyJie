/// TallyJie 常量定义
class AppConstants {
  AppConstants._();

  /// App 名称
  static const String appName = 'TallyJie';

  /// 数据库名称
  static const String dbName = 'tallyjie.db';

  /// 数据库版本
  static const int dbVersion = 1;

  /// 默认头像
  static const String defaultAvatar = '';

  /// 每日待办提醒时间 (暂未实现)
  static const String reminderTime = '09:00';
}

/// App 文案（中文）
class AppStrings {
  AppStrings._();

  // 导航
  static const String navDiary = '日记';
  static const String navLedger = '记账';
  static const String navProfile = '我的';

  // 日记页
  static const String diaryToday = '今天';
  static const String diaryTodayThoughts = '今天想说';
  static const String diaryEditorHint = '今天想说点什么...';
  static const String diaryTodaySpending = '今日消费';
  static const String diaryNoEntry = '今天还没有写日记';
  static const String diaryNoEntrySubtitle = '记录下今天发生的美好事情吧';

  // 记账页
  static const String ledgerTitle = '记账';
  static const String ledgerAddTransaction = '新增消费';
  static const String ledgerAmountHint = '0';
  static const String ledgerCategory = '分类';
  static const String ledgerNote = '备注';
  static const String ledgerNoteHint = '星巴克 冰美式';
  static const String ledgerSave = '保存';
  static const String ledgerCancel = '取消';
  static const String ledgerEmpty = '这个月还没有记录';
  static const String ledgerEmptySubtitle = '点击下方按钮开始记账';
  static const String ledgerAutoDetect = '检测到一笔消费';
  static const String ledgerIncome = '收入';
  static const String ledgerExpense = '支出';

  // 时间段
  static const String timeMorning = '上午';
  static const String timeAfternoon = '下午';
  static const String timeEvening = '晚上';

  // 统计
  static const String statsTitle = '统计';
  static const String statsLifeValue = '生活值';
  static const String statsCategoryBreakdown = '消费分类';
  static const String statsMonthlySummary = '月度总结';

  // 我的
  static const String profileTitle = '我的';
  static const String profileStreak = '连续记录';
  static const String profileDays = '天';
  static const String profileDiaries = '日记';
  static const String profileTransactions = '账单';
  static const String profilePhotos = '照片';
  static const String profileSettings = '设置';
  static const String profileBookMode = '翻看书本';

  // 通用
  static const String commonConfirm = '确定';
  static const String commonDelete = '删除';
  static const String commonEdit = '编辑';
  static const String commonBack = '返回';

  // 分类
  static const Map<String, String> categories = {
    'food': '🍜 餐饮',
    'transport': '🚗 交通',
    'shopping': '🛒 购物',
    'entertainment': '🎮 娱乐',
    'study': '📚 学习',
    'medical': '💊 医疗',
    'housing': '🏠 住房',
    'income': '💰 收入',
    'other': '📌 其他',
  };

  // 心情
  static const List<String> moods = ['😫', '😟', '😐', '😊', '😄'];

  // 天气
  static const Map<String, String> weathers = {
    'sunny': '☀️',
    'cloudy': '⛅',
    'rainy': '🌧️',
    'snowy': '❄️',
    'windy': '💨',
  };
}
