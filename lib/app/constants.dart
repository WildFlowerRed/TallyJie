class AppConstants {
  AppConstants._();
  static const String appName = 'TallyJie';
  static const String dbName = 'tallyjie.db';
  static const int dbVersion = 3;
}

class AppStrings {
  AppStrings._();

  // 导航
  static const navDiary = '单页日记';
  static const navLedger = '记账';
  static const navStats = '统计';
  static const navSettings = '设置';

  // 日记
  static const diaryHint = '今天发生了什么...';
  static const diaryAddImage = '添加图片';
  static const diaryMoodLabel = '心情';
  static const diaryWeatherLabel = '天气';

  // 记账
  static const ledgerIncome = '收入';
  static const ledgerExpense = '支出';
  static const ledgerAmountHint = '0.00';
  static const ledgerCategory = '分类';
  static const ledgerAccount = '账户';
  static const ledgerNote = '备注';
  static const ledgerNoteHint = '例如：和朋友吃火锅';
  static const ledgerSave = '保存账单';
  static const ledgerReceipt = '凭证';

  // 统计
  static const statsBalance = '本月结余';
  static const statsIncome = '本月收入';
  static const statsExpense = '本月支出';
  static const statsNoData = '暂无数据';

  // 设置
  static const settingsTheme = '主题设置';
  static const settingsCategories = '分类管理';
  static const settingsAccounts = '账户管理';
  static const settingsMoods = '心情管理';
  static const settingsWeathers = '天气管理';
  static const settingsExport = '数据导出';
  static const settingsImport = '数据导入';
  static const settingsBackup = '备份管理';
  static const settingsCache = '图片缓存清理';
  static const settingsAbout = '关于';

  // 通用
  static const commonSave = '保存';
  static const commonCancel = '取消';
  static const commonDelete = '删除';
  static const commonEdit = '编辑';
  static const commonConfirm = '确定';
}
