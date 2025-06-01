import 'package:flutter/material.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:numfit/utils/progress_manager.dart';

class DifficultySelectScreen extends StatefulWidget {
  const DifficultySelectScreen({super.key});

  @override
  State<DifficultySelectScreen> createState() => _DifficultySelectScreenState();
}

class _DifficultySelectScreenState extends State<DifficultySelectScreen> {
  final List<String> difficulties = ['EASY', 'NORMAL', 'HARD', 'LEGEND'];
  final Map<String, int> clearedStages = {};
  final Map<String, List<int>> thresholds = {
    'EASY': [1, 10, 20, 30],
    'NORMAL': [1, 10, 20, 30],
    'HARD': [1, 10, 20, 30],
    'LEGEND': [1, 10, 20, 30],
  };
  
  bool _slideFromRight = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadClearedStages();
  }

  Future<void> _loadClearedStages() async {
    for (final difficulty in difficulties) {
      final count = await ProgressManager.getClearedStage(difficulty);
      clearedStages[difficulty] = count;
    }
    if (mounted) setState(() {});
  }

  Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return Colors.blue;
      case 'NORMAL':
        return Colors.green;
      case 'HARD':
        return Colors.red;
      case 'LEGEND':
        return Colors.lime;
      default:
        return Colors.grey;
    }
  }

  int getPlantStage(int clearedCount, List<int> thresholds) {
    for (int i = 0; i < thresholds.length; i++) {
      if (clearedCount < thresholds[i]) {
        return i;
      }
    }
    return thresholds.length;
  }

  @override
  Widget build(BuildContext context) {
    final String currentDifficulty = difficulties[currentIndex];
    final List<int> thresholdList = thresholds[currentDifficulty]!;
    final int cleared = clearedStages[currentDifficulty] ?? 0;
    final int stageIndex = getPlantStage(cleared, thresholdList);
    final String imagePath = 'assets/plants/${currentDifficulty.toLowerCase()}_$stageIndex.png';

    // 今のステージの開始ライン（前のしきい値）と次のライン
    // final int lowerBound = stageIndex == 0 ? 0 : thresholdList[stageIndex - 1];
    final int upperBound = thresholdList[stageIndex];
    // プログレスバーの値（0.0〜1.0）
    final double progress = (cleared / upperBound).clamp(0.0, 1.0);
    // 表示用ラベル（例: EASY  2 / 10）
    final String label = '$currentDifficulty  $cleared / $upperBound';



    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              await AudioManager.playSe('audio/tap.mp3');
              if (!mounted) return;
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x665EFCE8), Color(0x66736EFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 難易度ラベルと植物画像（左右に三角ボタン）
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 60, color: Colors.white),
                    // ← 左ボタン
                    onPressed: currentIndex > 0
                        ? () async {
                            await AudioManager.playSe('audio/tap.mp3');
                            setState(() {
                              _slideFromRight = false; // 左から入る
                              currentIndex--;
                            });
                          }
                        : null,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🌱 植物画像表示
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            final isNew = child.key == ValueKey(imagePath);

                            if (!isNew) {
                              return const SizedBox.shrink();
                            }

                            final slideIn = Tween<Offset>(
                              begin: _slideFromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation);

                            return SlideTransition(
                              position: slideIn,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },

                          child: Container(
                            key: ValueKey<String>(imagePath),
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/plants/${currentDifficulty.toLowerCase()}_7.png',
                            ),
                          ),
                        ),

                      // 難易度の進捗バー
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: 180,
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.lightGreenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 60, color: Colors.white),
                    // → 右ボタン
                    onPressed: currentIndex < difficulties.length - 1
                        ? () async {
                            await AudioManager.playSe('audio/tap.mp3');
                            setState(() {
                              _slideFromRight = true; // 右から入る
                              currentIndex++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),


            const SizedBox(height: 24),

            // 各難易度のSTARTボタン（常に全表示）
            Column(
              children: difficulties.map((difficulty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () async {
                      await AudioManager.playSe('audio/tap.mp3');
                      if (!mounted) return;
                      Navigator.pushNamed(
                        context,
                        '/stage-select',
                        arguments: {'difficulty': difficulty},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getDifficultyColor(difficulty),
                      foregroundColor: Colors.white,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: Text(difficulty),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
