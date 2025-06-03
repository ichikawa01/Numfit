import 'package:flutter/material.dart';
import 'package:numfit/utils/ad_manager.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';
import 'package:numfit/utils/audio_manager.dart';

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

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

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

    AdManager.isAdsRemoved().then((noAds) {
      if (!noAds) {
        _loadRewardedAd();
      }
    });
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdReady = false;
        },
      ),
    );
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
    _selectedDay = null;
  }

  void _updateFlowerImage() {
    final clearedCount = _clearedDates.length;
    final lastDay = _lastDay.day;
    final int stage;

    if (clearedCount >= lastDay) {
      stage = 3;
    } else if (clearedCount >= 10) {
      stage = 2;
    } else if (clearedCount >= 1) {
      stage = 1;
    } else {
      stage = 0;
    }

    setState(() {
      _flowerImage = stage == 0
          ? 'assets/images/stage0.png'
          : 'assets/plants/${_yyyymm}_$stage.png';
    });
  }

  void _onStartDaily() async {
    if (_selectedDay == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final selectedStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);

    if (await AdManager.isAdsRemoved() || selectedStr == today) {
      _navigateToPlay(_selectedDay!);
      return;
    } else {
      if (_isRewardedAdReady && _rewardedAd != null) {
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) async {
            await AudioManager.stopBgm(); // ← 広告が始まったら止める
          },
          onAdDismissedFullScreenContent: (ad) async{
            ad.dispose();
            _loadRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) async {
            ad.dispose();
            _loadRewardedAd();
          },
        );
        _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) async{
            await AudioManager.forceRestartBgm();
            _navigateToPlay(_selectedDay!);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('広告の読み込みに失敗しました')),
        );
      }
    }
  }

  void _navigateToPlay(DateTime playDate) async {
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
        'date': DateFormat('yyyy-MM-dd').format(playDate),
      },
    ).then((_) async {
      await _loadClearedDays();
      _determineSelectedDay();
      if (!mounted) return;
      _updateFlowerImage();
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

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('cleared_daily_days');
              setState(() {
                _clearedDates = {};
                _selectedDay = null;
              });
              _determineSelectedDay();
              _updateFlowerImage();
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
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) => _buildCalendarDay(day, false),
                    todayBuilder: (context, day, _) => _buildCalendarDay(day, true),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: _flowerImage != null
                      ? Image.asset(_flowerImage!, fit: BoxFit.contain)
                      : const SizedBox.shrink(),
                ),
                // 達成度バー
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        Text(
                          '${_clearedDates.length} / ${_lastDay.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _clearedDates.length / _lastDay.day,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedDay != null ? _onStartDaily : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedDay != null &&
                          !_isSameDate(_selectedDay!, DateTime.now()))
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.ondemand_video, size: 30), // 🎥 アイコン
                        ),
                      const Text('PLAY', style: TextStyle(fontSize: 20)),
                    ],
                  ),
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
