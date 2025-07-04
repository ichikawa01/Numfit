import 'package:flutter/material.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:numfit/widgets/hexagon_button.dart';
import 'package:numfit/utils/progress_manager.dart';
import 'package:numfit/utils/difficulty_utils.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class StageSelectScreen extends StatefulWidget {
  const StageSelectScreen({super.key});

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(difficulty),
        backgroundColor: getDifficultyColor(difficulty),
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
      extendBodyBehindAppBar: false,
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadStageDataAndProgress(difficulty, filePath),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final problems = snapshot.data!['problems'] as List;
                final clearedStage = snapshot.data!['clearedStage'] as int;
                final stages = List.generate(problems.length, (i) => i + 1);

                return Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 12,
                    right: 12,
                    bottom: 70, // バナー広告スペースを確保
                  ),
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
                            ? () async {
                                await AudioManager.playSe('audio/start.mp3');
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
