import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/models/todo_item.dart';
import '../widgets/diary_header.dart';
import '../widgets/diary_grid_cards.dart';
import '../widgets/diary_todo_strip.dart';
import '../widgets/diary_editor.dart';
import '../widgets/diary_quick_entries.dart';
import '../widgets/diary_bottom_bar.dart';

/// 日记页 — 模块化、轻量化、网格化设计
class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  final ScrollController _scrollController = ScrollController();

  // 状态
  String _weather = 'sunny';
  int _mood = 3;
  final double _todayExpense = 128;
  final int _exerciseMinutes = 30;
  String _luckyThing = '试了新软件';
  String _progress = '定好风格基调';
  String _todaySay = '';
  final List<TodoItem> _todos = [
    TodoItem(title: '晨跑', isCompleted: true),
    TodoItem(title: '读论文', isCompleted: true),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addTodo(String title) {
    setState(() {
      _todos.insert(0, TodoItem(title: title, isCompleted: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Column(
        children: [
          // 可滚动内容区
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. 日期头部
                SliverToBoxAdapter(
                  child: DiaryHeader(
                    date: today,
                    weather: _weather,
                    mood: _mood,
                    weekNumber: 30,
                    onWeatherChanged: (w) => setState(() => _weather = w),
                    onMoodChanged: (m) => setState(() => _mood = m),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // 2. 四宫格数据卡片
                SliverToBoxAdapter(
                  child: DiaryGridCards(
                    todayExpense: _todayExpense,
                    exerciseMinutes: _exerciseMinutes,
                    luckyThing: _luckyThing,
                    progress: _progress,
                    onExpenseTap: () {},
                    onExerciseTap: () {},
                    onLuckyTap: () {},
                    onProgressTap: () {},
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // 3. 今日完成待办标签条
                SliverToBoxAdapter(
                  child: DiaryTodoStrip(
                    items: _todos,
                    onAdd: _addTodo,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // 4. 今天想说编辑器
                SliverToBoxAdapter(
                  child: DiaryEditor(
                    initialText: _todaySay,
                    onSave: (text) => setState(() => _todaySay = text),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 5. 小幸运/小进步快捷入口
                SliverToBoxAdapter(
                  child: DiaryQuickEntries(
                    luckyThing: _luckyThing,
                    progress: _progress,
                    onLuckySaved: (v) => setState(() => _luckyThing = v),
                    onProgressSaved: (v) => setState(() => _progress = v),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // 6. 底部毛玻璃双按钮栏
          DiaryBottomBar(
            onPreview: () {
              // TODO: 预览日记详情页
            },
            onCalendar: () {
              // TODO: 日历视图
            },
          ),
        ],
      ),
    );
  }
}
