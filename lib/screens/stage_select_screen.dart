import 'package:flutter/material.dart';
import 'package:numfit/widgets/hexagon_button.dart';
import 'package:numfit/utils/progress_manager.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


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

  Future<Map<String, dynamic>> _loadStageDataAndProgress(String difficulty, String filePath) async {
    final jsonStr = await rootBundle.loadString(filePath);
    final List<dynamic> jsonData = json.decode(jsonStr);
    final clearedStage = await ProgressManager.getClearedStage(difficulty);
    return {
      'problems': jsonData,
      'clearedStage': clearedStage,
    };
  }
    
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String difficulty = (args?['difficulty'] ?? 'EASY').toString().toUpperCase();
    final String filePath = 'assets/problems/${difficulty.toLowerCase()}.json';

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadStageDataAndProgress(difficulty, filePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final problems = snapshot.data!['problems'] as List;
        final clearedStage = snapshot.data!['clearedStage'] as int;
        final stages = List.generate(problems.length, (i) => i + 1);

        return Scaffold(
          appBar: AppBar(title: Text('難易度: $difficulty')),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
              children: stages.map((stage) {
                final isUnlocked = stage <= clearedStage + 1;

                return HexagonButton(
                  text: '$stage',
                  selected: false,
                  wrong: false,
                  correct: false,
                  color: isUnlocked ? getDifficultyColor(difficulty): getDifficultyColor(difficulty).withValues(alpha: 0.1),
                  onTap: isUnlocked
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/game',
                            arguments: {
                              'stage': stage,
                              'difficulty': difficulty,
                            },
                          );
                        }
                      : null,
                  size: 60,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}