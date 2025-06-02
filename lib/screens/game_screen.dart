import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:numfit/widgets/hexagon_button.dart';
import 'package:numfit/utils/progress_manager.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ← カウント保存用
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  List<bool> isSelected = List.filled(10, false);
  List<bool> isWrong = List.filled(10, false);
  List<bool> isCorrect = List.filled(10, false);
  List<int> selectedOrder = [];

  late int correctAnswer;
  late List<String> items;

  String difficulty = 'EASY';
  int stage = 1;
  bool _initialized = false;


  // 広告関連
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/4411468910', // テスト用 ID（本番では置換）
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/2934735716', // テスト用ID
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
          _isBannerLoaded = false;
          print('Ad failed to load: $error');
        },
      ),
    )..load();

    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadProblem() async {
    final fileName = 'assets/problems/${difficulty.toLowerCase()}.json';
    final jsonStr = await rootBundle.loadString(fileName);
    final List<dynamic> data = json.decode(jsonStr);
    final problem = data[stage - 1];

    correctAnswer = problem['target'];
    items = List<String>.from(problem['items']);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      difficulty = args?['difficulty'] ?? 'EASY';
      stage = args?['stage'] ?? 1;

      _loadProblem().then((_) {
        setState(() {
          _initialized = true;
        });
      });
    }
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

        await ProgressManager.setClearedStage(difficulty, stage);
        await Future.delayed(const Duration(milliseconds: 500));
        await AudioManager.playSe('audio/ok.mp3');
        if (!mounted) return;

        // インタースティシャルカウント処理
        final prefs = await SharedPreferences.getInstance();
        int count = prefs.getInt('clear_count') ?? 0;
        count += 1;
        await prefs.setInt('clear_count', count);

        if (count >= 9 && count % 3 == 0 && _isInterstitialAdReady) {
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // 次の読み込み
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd(); // 次の読み込み
            },
          );
          _interstitialAd?.show();
        }

        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: {'difficulty': difficulty},
        );
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
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('STAGE $stage（$difficulty）'),
        backgroundColor: Colors.transparent.withAlpha(50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await AudioManager.playSe('audio/tap.mp3');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              await AudioManager.playSe('audio/tap.mp3');
              Navigator.pushNamed(context, '/settings');
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
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
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
