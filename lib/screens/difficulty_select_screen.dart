import 'package:flutter/material.dart';

class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncyButton({super.key, required this.child, required this.onTap});

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.9);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}


class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  // レベルでの色分け
  Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
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
    final difficulties = ['EASY', 'NORMAL', 'HARD'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MODE'),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: difficulties.map((difficulty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/stage-select',
                      arguments: {'difficulty': difficulty},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getDifficultyColor(difficulty),
                    foregroundColor: Colors.white,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(difficulty),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
