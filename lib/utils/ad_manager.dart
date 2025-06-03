import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  static const _keyNoAds = 'no_ads';

  static Future<void> setNoAds(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNoAds, value);
  }

  static Future<bool> isAdsRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNoAds) ?? false;
  }
}
