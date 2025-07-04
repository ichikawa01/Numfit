import 'package:flutter/material.dart';
import 'package:numfit/utils/ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:numfit/widgets/hexagon_button.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DailyGameScreen extends StatefulWidget {
  const DailyGameScreen({super.key});

  @override
  State<DailyGameScreen> createState() => _DailyGameScreenState();
}

class _DailyGameScreenState extends State<DailyGameScreen> {
  List<bool> isSelected = List.filled(10, false);
  List<bool> isWrong = List.filled(10, false);
  List<bool> isCorrect = List.filled(10, false);
  List<int> selectedOrder = [];

  late int correctAnswer;
  late List<String> items;
  late List<int> solution;
  late String playDateStr;

  bool _initialized = false;
  bool showHint = false;
  bool hintUsed = false;


  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-7316649907762779/2445934972',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    AdManager.isAdsRemoved().then((noAds) {
      if (!noAds) {
        _bannerAd = BannerAd(
          adUnitId: 'ca-app-pub-7316649907762779/3779197946',
          size: AdSize.banner,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (_) {
              setState(() {
                _isBannerLoaded = true;
              });
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              print('Ad failed: $error');
            },
          ),
        )..load();
        _loadRewardedAd();
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
    _rewardedAd?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    playDateStr = args['date'] as String;

    final base = DateTime(2024, 1, 1);
    final playDate = DateTime.parse(playDateStr);
    final index = playDate.difference(base).inDays % 100;

    _loadDailyProblem(index).then((_) {
      setState(() => _initialized = true);
    });
  }

  Future<void> _loadDailyProblem(int index) async {
    final jsonStr = await rootBundle.loadString('assets/problems/daily.json');
    final List<dynamic> data = json.decode(jsonStr);
    final problem = data[index % data.length];
    correctAnswer = problem['target'];
    items = List<String>.from(problem['items']);
    solution = List<int>.from(problem['solution']);
  }

  void _handleButtonPress(int index) async {
    await AudioManager.playSe('audio/tap.mp3');
    if (isSelected[index]) {
      setState(() {
        isSelected[index] = false;
        selectedOrder.remove(index);
      });
      return;
    }

    if (selectedOrder.length >= 3) return;

    setState(() {
      isSelected[index] = true;
      selectedOrder.add(index);
    });

    if (selectedOrder.length == 3) {
      final selectedOps = selectedOrder.map((i) => items[i]).toList();
      final result = _evaluateWithPrecedence(selectedOps);

      if (result != null && result == correctAnswer.toDouble()) {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isCorrect[i] = isSelected[i];
          }
        });

        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getStringList('cleared_daily_days') ?? [];
        if (!existing.contains(playDateStr)) {
          existing.add(playDateStr);
          await prefs.setStringList('cleared_daily_days', existing);
        }

        await Future.delayed(const Duration(milliseconds: 500));
        await AudioManager.playSe('audio/ok.mp3');
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isWrong[i] = isSelected[i];
          }
        });

        await Future.delayed(const Duration(milliseconds: 500));
        await AudioManager.playSe('audio/ng.mp3');
        if (!mounted) return;
        setState(() {
          isSelected = List.filled(10, false);
          isWrong = List.filled(10, false);
          isCorrect = List.filled(10, false);
          selectedOrder.clear();
        });
      }
    }
  }

  double? _evaluateWithPrecedence(List<String> ops) {
    if (ops.isEmpty) return null;
    double? result = double.tryParse(ops[0].replaceAll(RegExp(r'[^\d]'), ''));
    if (result == null) return null;

    List<String> expression = [result.toString()];
    for (int i = 1; i < ops.length; i++) {
      final match = RegExp(r'^([+\-×÷])(\d+)$').firstMatch(ops[i]);
      if (match == null) return null;
      final op = match.group(1)!;
      final num = double.tryParse(match.group(2)!);
      if (num == null || (op == '÷' && num == 0)) return null;
      expression.add(op);
      expression.add(num.toString());
    }

    try {
      for (int i = 1; i < expression.length - 1; i++) {
        if (expression[i] == '×' || expression[i] == '÷') {
          double left = double.parse(expression[i - 1]);
          double right = double.parse(expression[i + 1]);
          double intermediate = expression[i] == '×' ? left * right : left / right;
          expression.replaceRange(i - 1, i + 2, [intermediate.toString()]);
          i -= 2;
        }
      }

      for (int i = 1; i < expression.length - 1; i++) {
        if (expression[i] == '+' || expression[i] == '-') {
          double left = double.parse(expression[i - 1]);
          double right = double.parse(expression[i + 1]);
          double intermediate = expression[i] == '+' ? left + right : left - right;
          expression.replaceRange(i - 1, i + 2, [intermediate.toString()]);
          i -= 2;
        }
      }

      double finalResult = double.parse(expression.first);
      if (finalResult % 1 != 0) return null;
      return finalResult;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DAILY CHALLENGE'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await AudioManager.playSe('audio/tap.mp3');
            Navigator.pop(context);
          },
        ),
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
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Answer\n$correctAnswer',
                      style: const TextStyle(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildRow([0]),
                  _buildRow([1, 2]),
                  _buildRow([3, 4, 5]),
                  _buildRow([6, 7, 8, 9]),
                ],
              ),
            ),
          ),
          Positioned(
            top:330,
            right: 28,
            child: GestureDetector(
              onTap: () async {
                if (await AdManager.isAdsRemoved()) {
                  setState(() {
                    showHint = true;
                    hintUsed = true;
                  });
                  return;
                }
                if (hintUsed) return;
                if (_isRewardedAdReady && _rewardedAd != null) {
                  _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
                    onAdShowedFullScreenContent: (ad) async {
                      await AudioManager.stopBgm(); // ← 広告が始まったら止める
                    },
                    onAdDismissedFullScreenContent: (ad) {
                      ad.dispose();
                      _loadRewardedAd(); // 次を読み込み
                    },
                    onAdFailedToShowFullScreenContent: (ad, error) {
                      ad.dispose();
                      _loadRewardedAd(); // 次を読み込み
                    },
                  );

                  _rewardedAd!.show(
                    onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
                      await AudioManager.forceRestartBgm();
                      setState(() {
                        showHint = true; // ← 報酬としてヒント表示
                        hintUsed = true; // ヒントを使用済みにする
                      });
                    },
                  );
                } else {
                  print('Rewarded ad is not ready yet.');
                  // Optional: ユーザーに「読み込み中」と通知
                }
              },
              child: Image.asset(
                hintUsed
                    ? 'assets/images/used_hint.png'
                    : 'assets/images/hint.png',
                width: 80,
                height: 80,
              ),
            ),
          ),
          if (_isBannerLoaded && _bannerAd != null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          if (showHint)
            Positioned(
            top: 410,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Text(
                '  Hint ${items[solution[0]]}  ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<int> indices) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: indices.map((i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: HexagonButton(
              text: items[i],
              selected: isSelected[i],
              wrong: isWrong[i],
              correct: isCorrect[i],
              onTap: () => _handleButtonPress(i),
            ),
          );
        }).toList(),
      ),
    );
  }
}
