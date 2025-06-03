// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:numfit/utils/audio_manager.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    final howToText = lang == 'ja' ? '遊び方' : 'How to Play';
    final privacyText = lang == 'ja' ? 'プライバシーポリシー' : 'Privacy Policy';
    final bgmText = lang == 'ja' ? 'BGM' : 'BGM';
    final seText = lang == 'ja' ? '効果音' : 'Sound Effects';
    final urlError = lang == 'ja' ? 'URLを開けませんでした' : 'Could not open the URL';

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ja' ? '設定' : 'Settings'),
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
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(bgmText),
                  value: AudioManager.isBgmEnabled,
                  onChanged: (_) async {
                    await AudioManager.toggleBgm();
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(seText),
                  value: AudioManager.isSeEnabled,
                  onChanged: (_) async {
                    await AudioManager.toggleSe();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(howToText),
                  onTap: () async {
                    await AudioManager.playSe('audio/tap.mp3');
                    Navigator.pushNamed(context, '/how-to-play');
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text(privacyText),
                  onTap: () async {
                    const url = 'https://github.com/ichikawa01/privacy-policy';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(urlError)),
                      );
                    }
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
