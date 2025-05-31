// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:numfit/utils/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await AudioManager.playSe('audio/tap.mp3');
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/stone_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('BGM'),
                  value: AudioManager.isBgmEnabled,
                  onChanged: (_) async {
                    await AudioManager.toggleBgm();
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('SE（効果音）'),
                  value: AudioManager.isSeEnabled,
                  onChanged: (_) async {
                    await AudioManager.toggleSe();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
