import 'package:flutter/material.dart';
import 'package:numfit/widgets/hexagon_button.dart'; // HexagonButton を定義しているファイル

class StageSelectScreen extends StatelessWidget {
  const StageSelectScreen({super.key});

  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return Colors.lime;
      case 'NORMAL':
        return Colors.green;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String difficulty = (args?['difficulty'] ?? 'EASY').toString().toUpperCase();

    final List<int> stages = List.generate(100, (i) => i + 1); // 1〜100

    return Scaffold(
      appBar: AppBar(title: Text('難易度: $difficulty')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 5, // 横5個
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1, // 正六角形に近づける
          children: stages.map((stage) {
            return HexagonButton(
              text: '$stage',
              selected: false,
              wrong: false,
              correct: false,
              color: getDifficultyColor(difficulty),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/game',
                  arguments: {
                    'stage': stage,
                    'difficulty': difficulty,
                  },
                );
              },
              size: 60, // サイズ調整（必要に応じて）
            );
          }).toList(),
        ),
      ),
    );
  }
}
