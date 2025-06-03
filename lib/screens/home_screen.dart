import 'package:flutter/material.dart';
import 'package:numfit/utils/ad_manager.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:numfit/utils/progress_manager.dart';
import 'package:numfit/utils/difficulty_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<String> difficulties = ['EASY', 'NORMAL', 'HARD', 'LEGEND'];
  final Map<String, int> clearedStages = {};
  
  bool _slideFromRight = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadClearedStages();
    _checkFirstLaunch();
  }

  Future<void> _loadClearedStages() async {
    for (final difficulty in difficulties) {
      final count = await ProgressManager.getClearedStage(difficulty);
      clearedStages[difficulty] = count;
    }
    if (mounted) setState(() {});
  }
  
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHowToPlay = prefs.getBool('hasSeenHowToPlay') ?? false;

    if (!hasSeenHowToPlay) {
      await prefs.setBool('hasSeenHowToPlay', true);
      if (mounted) {
        Navigator.pushNamed(context, '/how-to-play');
      }
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentDifficulty = difficulties[currentIndex];
    final List<int> thresholdList = thresholds[currentDifficulty]!;
    final int cleared = clearedStages[currentDifficulty] ?? 0;
    final int stageIndex = getPlantStage(cleared, thresholdList);
    final String imagePath = 'assets/plants/${currentDifficulty.toLowerCase()}_$stageIndex.png';

    // 難易度ごとの上限値
    final int upperBound = (stageIndex == 7)
      ? 100
      : thresholdList[stageIndex];

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
      body: Stack(
        children: [
          // 背景 + メインUI
          Container(
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
                const SizedBox(height: 30),
                // 難易度ラベルと植物画像（左右に三角ボタン）
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  imagePath,
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
                                    style: TextStyle(
                                      color: getDifficultyColor(currentDifficulty),
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


                const SizedBox(height: 16),

                // 難易度＆デイリーボタンレイアウト
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // デイリーボタン（上）
                      ElevatedButton(
                        onPressed: () async {
                          await AudioManager.playSe('audio/tap.mp3');
                          if (!mounted) return;
                          Navigator.pushNamed(context, '/daily');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('DAILY'),
                      ),

                      const SizedBox(height: 42),

                      // 難易度ボタン（2×2配置）
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 24,
                          runSpacing: 24,
                          children: difficulties.map((difficulty) {
                            return SizedBox(
                              width: 140,
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
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                child: Text(difficulty),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                ),
              ],
            ),
          ),
          Positioned(
            top: kToolbarHeight + 90,
            right: 30,
            child: GestureDetector(
              onTap: () async {
                await AudioManager.playSe('audio/tap.mp3');
                if (!mounted) return;
                Navigator.pushNamed(context, '/collection');
              },
              child: Image.asset(
                'assets/images/leaf.png',
                width: 70,
                height: 70,
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 90,
            left: 30,
            child: GestureDetector(
              onTap: () async {
                await AudioManager.playSe('audio/tap.mp3');

                // ダミーで広告削除フラグをONにする
                await AdManager.setNoAds(true);
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('広告を削除しました')),
                );
              },
              child: Image.asset(
                'assets/images/NoAD.png', 
                width: 70,
                height: 70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
