import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late final DateTime _focusedDay;
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  late final String _yyyymm;
  Set<String> _clearedDates = {};
  String? _flowerImage;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month);
    _firstDay = DateTime(now.year, now.month, 1);
    _lastDay = DateTime(now.year, now.month + 1, 0);
    _yyyymm = DateFormat('yyyyMM').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDailyState();
    });
  }

  Future<void> _initializeDailyState() async {
    await _loadClearedDays();
    _determineSelectedDay();
    if (!mounted) return;
    _updateFlowerImage();
  }

  Future<void> _loadClearedDays() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList('cleared_daily_days');
    final now = DateTime.now();

    final currentMonthDates = raw?.where((dateStr) {
      final date = DateTime.tryParse(dateStr);
      return date != null && date.year == now.year && date.month == now.month;
    }).toSet() ?? {};

    // 今月分だけ再保存（クリーニング）
    await prefs.setStringList('cleared_daily_days', currentMonthDates.toList());

    setState(() {
      _clearedDates = currentMonthDates;
    });
  }


  void _determineSelectedDay() {
    final now = DateTime.now();
    for (int i = 0; i < now.day; i++) {
      final candidate = DateTime(now.year, now.month, now.day - i);
      final candidateStr = DateFormat('yyyy-MM-dd').format(candidate);
      if (!_clearedDates.contains(candidateStr)) {
        _selectedDay = candidate;
        return;
      }
    }
    _selectedDay = null; // 全てクリア済み
  }

  void _updateFlowerImage() {
    final clearedCount = _clearedDates.length;
    print('🌱 Cleared count: $clearedCount');
    final lastDay = _lastDay.day;
    final int stage;

    if (clearedCount >= lastDay) {
      stage = 3;
    } else if (clearedCount >= 20) {
      stage = 2;
    } else if (clearedCount >= 10) {
      stage = 1;
    } else {
      stage = 0;
    }

    setState(() {
      _flowerImage = stage == 0
          ? 'assets/images/leaf.png'
          : 'assets/plants/${_yyyymm}_$stage.png';
    });
    print('🌸 Flower image path: $_flowerImage');
  }

  void _onStartDaily() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final clearedDates = prefs.getStringList('cleared_daily_days') ?? [];

    // 今日の日付
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    DateTime playDate;

    if (clearedDates.contains(todayStr)) {
      // 今日がクリア済み → 前日から遡って未クリアの日を探す
      playDate = _findLatestUnclearedDay(clearedDates, now);
    } else {
      // 今日が未クリア → 今日に挑戦
      playDate = today;
    }

    // 問題インデックス生成
    final baseDate = DateTime(2024, 1, 1);
    final dayDiff = playDate.difference(baseDate).inDays;
    final index = dayDiff % 100;

    final data = await DefaultAssetBundle.of(context).loadString('assets/problems/daily.json');
    final List<dynamic> questions = jsonDecode(data);
    final selected = questions[index % questions.length];

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/daily-play',
      arguments: {
        'problem': selected,
        'date': DateFormat('yyyy-MM-dd').format(playDate), // ← OK now
      },
    ).then((_) async {
      await _loadClearedDays();
      _determineSelectedDay();
      if (!mounted) return;
      _updateFlowerImage();

      print('Selected date: ${DateFormat('yyyy-MM-dd').format(playDate)}');
      print(clearedDates);
    });
  }

  Widget _buildCalendarDay(DateTime day, bool isToday) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final isCleared = _clearedDates.contains(dateKey);
    final isSelected = _selectedDay != null && DateFormat('yyyy-MM-dd').format(_selectedDay!) == dateKey;

    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = Colors.pink;
    } else if (isCleared) {
      bgColor = Colors.purple.shade200;
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  DateTime _findLatestUnclearedDay(List<String> clearedDates, DateTime now) {
    for (int i = now.day - 1; i >= 1; i--) {
      final candidate = DateTime(now.year, now.month, i);
      final candidateStr = DateFormat('yyyy-MM-dd').format(candidate);
      if (!clearedDates.contains(candidateStr)) {
        return candidate;
      }
    }
    // すべてクリア済みなら1日を返す
    return DateTime(now.year, now.month, 1);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAILY'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),


          // 初期化ボタン
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('cleared_daily_days');
              setState(() {
                _clearedDates = {};
                _selectedDay = null;
              });
              _determineSelectedDay(); // ← 再選択
              _updateFlowerImage();    // ← 花の状態も更新
              print('✅ デイリークリア情報を初期化しました');
            },
          ),



        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x665EFCE8), Color(0x66736EFE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight + 60),
                TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    leftChevronVisible: false,
                    rightChevronVisible: false,
                    titleCentered: true
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) => _buildCalendarDay(day, false),
                    todayBuilder: (context, day, _) => _buildCalendarDay(day, true),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: _flowerImage != null
                      ? Image.asset(_flowerImage!, fit: BoxFit.contain)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedDay != null ? _onStartDaily : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('PLAY', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 360,
            right: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/collection');
              },
              child: Image.asset(
                'assets/images/leaf.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
