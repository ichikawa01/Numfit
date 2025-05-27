import 'package:flutter/material.dart';
import 'package:numfit/widgets/hexagon_button.dart';
import 'dart:math';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  List<bool> isSelected = List.filled(10, false); // ← 長さ10に拡張
  List<bool> isWrong = List.filled(10, false);
  List<bool> isCorrect = List.filled(10, false);

  late int correctAnswer;

  @override
  void initState() {
    super.initState();
    final random = Random();
    correctAnswer = random.nextInt(22) + 6;
  }

  void _handleButtonPress(int index) async {
    // タップ済みならトグル解除（減らすのはOK）
    if (isSelected[index]) {
      setState(() {
        isSelected[index] = false;
      });
      return;
    }

    // 現在の選択数をカウント
    final selectedCount = isSelected.where((e) => e).length;

    // すでに3つ選ばれていたら何もせず
    if (selectedCount >= 3) return;

    // まだ押せる → 選択する
    setState(() {
      isSelected[index] = true;
    });

    // 選択が3つになったら答えをチェック
    final selectedNumbers = isSelected.asMap().entries
        .where((entry) => entry.value)
        .map((entry) => entry.key + 1) // 1-basedの数字
        .toList();

    if (selectedNumbers.length == 3) {
      final total = selectedNumbers.reduce((a, b) => a + b);

      if (total == correctAnswer) {
        // 緑に変える
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isCorrect[i] = isSelected[i]; // 選ばれてるボタンだけ緑に
          }
        });
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/result');
      } else {
        // 間違っていたら赤くする
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isWrong[i] = isSelected[i]; // 選ばれてるものを赤に
          }
        });
        // 間違っていたらリセット
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
      appBar: AppBar(title: const Text('ゲーム')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$correctAnswer',
              style: const TextStyle(fontSize: 18),
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
