import 'package:flutter/material.dart';
import 'package:numfit/utils/audio_manager.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        backgroundColor: Colors.transparent.withValues(alpha: .2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu), // ← 歯車アイコン
            onPressed: () async{
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
            colors: [
              Color(0x665EFCE8),
              Color(0x66736EFE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              await AudioManager.playSe('audio/tap.mp3');
              Navigator.pushNamed(context, '/difficulty-select');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
            child: const Text('START'),
          ),
        ),
      ),
    );
  }
}