import 'package:flutter/material.dart';
import 'difficulty_select_screen.dart';
import 'stage_select_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final difficulty = args?['difficulty'] ?? 'EASY';

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESULT'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStyledButton(
                      context: context,
                      label: 'STAGE',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StageSelectScreen(),
                            settings: RouteSettings(arguments: {'difficulty': difficulty}),
                          ),
                          ModalRoute.withName('/difficulty-select'),
                        );
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildStyledButton(
                      context: context,
                      label: 'MODE',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const DifficultySelectScreen()),
                          ModalRoute.withName('/'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStyledButton(
                  context: context,
                  label: 'HOME',
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false),
                ),
              ],
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
