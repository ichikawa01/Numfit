import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numfit/utils/progress_manager.dart';
import 'package:numfit/utils/difficulty_utils.dart';
import 'package:intl/intl.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final List<String> difficulties = ['EASY', 'NORMAL', 'HARD', 'LEGEND'];
  final Map<String, int> clearedStages = {};
  final Map<String, int> clearedDailyCounts = {};
  List<String> clearedDailyMonths = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    // 難易度別クリア数
    for (final diff in difficulties) {
      final count = await ProgressManager.getClearedStage(diff);
      clearedStages[diff] = count;
    }

    // デイリーの月別カウント
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('cleared_daily_days') ?? [];
    final Map<String, int> dailyCountMap = {};
    final Set<String> monthSet = {};

    for (final dateStr in raw) {
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        final yyyymm = DateFormat('yyyyMM').format(date);
        dailyCountMap[yyyymm] = (dailyCountMap[yyyymm] ?? 0) + 1;
        monthSet.add(yyyymm);
      }
    }

    clearedDailyMonths = monthSet.toList()..sort();
    clearedDailyCounts.addAll(dailyCountMap);
    setState(() => _loaded = true);
  }

  int getDailyStage(int clearedCount, int lastDay) {
    if (clearedCount >= lastDay) return 3;
    if (clearedCount >= 10) return 2;
    if (clearedCount >= 1) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('COLLECTION'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x665EFCE8), Color(0x66736EFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: kToolbarHeight + 60),
          children: [
            // 難易度別コレクション
            ...difficulties.map((difficulty) {
              final cleared = clearedStages[difficulty] ?? 0;
              final stage = getPlantStage(cleared, thresholds[difficulty]!);

              return ExpansionTile(
                title: Text(
                  difficulty,
                  style: TextStyle(
                    color: getDifficultyColor(difficulty),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(8, (i) {
                        final imagePath = (i <= stage)
                            ? 'assets/plants/${difficulty.toLowerCase()}_$i.png'
                            : 'assets/images/stage0.png';
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 64) / 2,
                          child: Image.asset(imagePath, height: 160),
                        );
                      }),
                    ),
                  ),
                ],
              );
            }),

            // デイリーコレクション
            ExpansionTile(
              title: const Text(
                'DAILY',
                style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
              ),
              children: clearedDailyMonths.map((yyyymm) {
                final formatted = '${yyyymm.substring(4)} ${yyyymm.substring(0, 4)}';
                final clearedCount = clearedDailyCounts[yyyymm] ?? 0;
                final int lastDay = DateTime(
                  int.parse(yyyymm.substring(0, 4)),
                  int.parse(yyyymm.substring(4)),
                  0,
                ).day;
                final stage = getDailyStage(clearedCount, lastDay);

                List<Widget> images = [];
                if (stage > 0) {
                  for (int i = 1; i <= stage; i++) {
                    final path = 'assets/plants/${yyyymm}_$i.png';
                    images.add(Image.asset(path, height: 200));
                  }
                } else {
                  images.add(Image.asset('assets/images/stage0.png', height: 200));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        formatted,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: images.map((img) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 64) / 3,
                            child: img,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
