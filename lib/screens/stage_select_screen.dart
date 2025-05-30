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
          appBar: AppBar(
            title: Text('難易度: $difficulty'),
            backgroundColor: Colors.transparent.withValues(alpha: .2),
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x665EFCE8),
                  Color(0x66736EFE),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight + 12, left: 12, right: 12, bottom: 12),
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
                    color: isUnlocked
                        ? getDifficultyColor(difficulty)
                        : getDifficultyColor(difficulty).withAlpha(40),
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
                    size: 65,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}