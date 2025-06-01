import 'package:flutter/material.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:numfit/utils/difficulty_utils.dart';
import 'package:numfit/utils/progress_manager.dart';
import 'home_screen.dart';
import 'stage_select_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String difficulty = args?['difficulty'] ?? 'EASY';

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESULT'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x665EFCE8), Color(0x66736EFE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 24),
            child: FutureBuilder<int>(
              future: ProgressManager.getClearedStage(difficulty),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final cleared = snapshot.data!;
                final thresholdList = thresholds[difficulty]!;
                final stageIndex = getPlantStage(cleared, thresholdList);
                final imagePath = 'assets/plants/${difficulty.toLowerCase()}_$stageIndex.png';
                final int upperBound = thresholdList[stageIndex];
                final double progress = (cleared / upperBound).clamp(0.0, 1.0);
                final String label = '$difficulty  $cleared / $upperBound';

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(imagePath),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
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
                    ),
                    const SizedBox(height: 64),
                    _buildStyledButton(
                      context: context,
                      label: 'STAGE',
                      onPressed: () async {
                        await AudioManager.playSe('audio/tap.mp3');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StageSelectScreen(),
                            settings: RouteSettings(arguments: {'difficulty': difficulty}),
                          ),
                          ModalRoute.withName('/'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildStyledButton(
                      context: context,
                      label: 'HOME',
                      onPressed: () async {
                        await AudioManager.playSe('audio/tap.mp3');
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
