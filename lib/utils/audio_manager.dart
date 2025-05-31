// lib/utils/audio_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sePlayer = AudioPlayer();

  static bool _bgmEnabled = true;
  static bool _seEnabled = true;
  static bool _isBgmPlaying = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmEnabled = prefs.getBool('bgm_enabled') ?? true;
    _seEnabled = prefs.getBool('se_enabled') ?? true;

    if (_bgmEnabled) await _startBgm();
  }

  static bool get isBgmEnabled => _bgmEnabled;
  static bool get isSeEnabled => _seEnabled;

  static Future<void> toggleBgm() async {
    _bgmEnabled = !_bgmEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bgm_enabled', _bgmEnabled);
    _bgmEnabled ? await _startBgm() : await _stopBgm();
  }

  static Future<void> toggleSe() async {
    _seEnabled = !_seEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('se_enabled', _seEnabled);
  }

  static Future<void> playSe(String assetPath) async {
    if (!_seEnabled) return;

    final player = AudioPlayer();
    await player.play(AssetSource(assetPath));

    // メモリ解放のために完了後に解放（遅延させる）
    player.onPlayerComplete.listen((event) {
      player.dispose();
    });
  }


  static Future<void> _startBgm() async {
    if (_isBgmPlaying) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    _isBgmPlaying = true;
  }

  static Future<void> _stopBgm() async {
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
  }
}
