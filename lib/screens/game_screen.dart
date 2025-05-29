import 'dart:math';
import 'package:flutter/material.dart';
import 'package:numfit/widgets/hexagon_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  List<bool> isSelected = List.filled(10, false);
  List<bool> isWrong = List.filled(10, false);
  List<bool> isCorrect = List.filled(10, false);

  late int correctAnswer;
  String difficulty = 'EASY';
  int stage = 1;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      difficulty = args?['difficulty'] ?? 'EASY';
      stage = args?['stage'] ?? 1;

      final random = Random();

      // 難易度で出題の幅を変える（例）
      switch (difficulty) {
        case 'EASY':
          correctAnswer = random.nextInt(10) + 6; // 6〜15
          break;
        case 'NORMAL':
          correctAnswer = random.nextInt(12) + 10; // 10〜21
          break;
        case 'HARD':
          correctAnswer = random.nextInt(10) + 18; // 18〜27
          break;
        default:
          correctAnswer = random.nextInt(22) + 6;
      }

      _initialized = true;
    }
  }

  void _handleButtonPress(int index) async {
    if (isSelected[index]) {
      setState(() {
        isSelected[index] = false;
      });
      return;
    }

    final selectedCount = isSelected.where((e) => e).length;
    if (selectedCount >= 3) return;

    setState(() {
      isSelected[index] = true;
    });

    final selectedNumbers = isSelected.asMap().entries
        .where((entry) => entry.value)
        .map((entry) => entry.key + 1)
        .toList();

    if (selectedNumbers.length == 3) {
      final total = selectedNumbers.reduce((a, b) => a + b);

      if (total == correctAnswer) {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isCorrect[i] = isSelected[i];
          }
        });

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/result',
          arguments: {
            'difficulty': difficulty
          },
          );
      } else {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isWrong[i] = isSelected[i];
          }
        });

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        setState(() {
          isSelected = List.filled(10, false);
          isWrong = List.filled(10, false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('STAGE $stage（$difficulty）')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TARGET\n$correctAnswer',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildRow([0]),
            _buildRow([1, 2]),
            _buildRow([3, 4, 5]),
            _buildRow([6, 7, 8, 9]),
          ],
        ),
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
              text: '${i + 1}',
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
