import 'package:shared_preferences/shared_preferences.dart';

class ProgressManager {
  static const _keyPrefix = 'cleared_';

  static Future<int> getClearedStage(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyPrefix$difficulty') ?? 1; // 最初はステージ1だけ
  }

  static Future<void> setClearedStage(String difficulty, int stage) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getClearedStage(difficulty);
    if (stage > current) {
      await prefs.setInt('$_keyPrefix$difficulty', stage);
    }
  }
}
