import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('MODE')),
      body: Center(
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
    );
  }
}
